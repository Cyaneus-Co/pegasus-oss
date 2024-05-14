import SwiftUI
import NavigationStack
import ComposableArchitecture

class DebugRouter {
    private let stack: NavigationStackCompat
    
    init(stack: NavigationStackCompat) {
        self.stack = stack
    }
    
    func signIn() {
        self.stack.push(
            AuthNLandingView(store: StoreOf<UserAuthFeature>(
                initialState: UserAuthFeature.State(),
                reducer: UserAuthFeature())))
    }

    func createAccount() {
        self.stack.push(
            OnBoardingView(store: Store(
                initialState: OnBoardingFeature.State(),
                reducer: OnBoardingFeature(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
        )
    }
    
    func viewFeed() {
        self.stack.push(
            FeedRootView(
                store: Store(
                    initialState:
                        FeedFeature.State(signedInUser: UserProfile.Poseidon),
                    reducer: feedReducer)))
    }
    
    func push(target: AnyView) {
        self.stack.push(target)
    }
    
    func pop() {
        self.stack.pop()
    }
}

enum Domain {
    case landing
    case feed
    case onBoarding
    case medusaClient
    case userAuth
}

struct Application: ReducerProtocol {
    struct State: Equatable {
        var currentDomain: Domain = .landing
        var onBoarding: OnBoardingFeature.State = OnBoardingFeature.State()
        var feed: FeedFeature.State
        var userAuth: UserAuthFeature.State
    }

    enum Action: Equatable {
        case onBoarding(OnBoardingFeature.Action)
        case feed(FeedFeature.Action)
        case navigate(Domain)
        case userAuth(UserAuthFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \Application.State.onBoarding, action: /Action.onBoarding) {
            OnBoardingFeature(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        }

        Scope(state: \.feed, action: /Action.feed) {
            FeedFeature()
        }

        Scope(state: \.userAuth, action: /Action.userAuth) {
            UserAuthFeature()
        }

        Reduce { state, action in
            switch(action) {
            case .onBoarding(OnBoardingFeature.Action.onBoardingComplete):
                state.currentDomain = .feed
                return .none
            case .navigate(let page):
                state.currentDomain = page
                return .none
            case .onBoarding(_):
                return .none
            case .feed(_):
                return .none
            case .userAuth(_):
                return .none
            }
        }
    }
}

struct AppEnvironment {
    init() {
        // TODO: (mrm) fixme
        UserService.instance.setSignedIn(user: UserProfile.Poseidon)
    }
}

struct DebugView: View {
    var store: StoreOf<Application>

    var body: some View {
        WithViewStore(store) {viewStore in
            selectView(viewStore)
        }
    }

    func selectView(_ viewStore: ViewStoreOf<Application>) -> some View {
        switch viewStore.currentDomain {
        case .landing:
            return landing(viewStore).eraseToAnyView()
        case .feed:
            return feed(viewStore).eraseToAnyView()
        case .onBoarding:
            return onBoarding(viewStore).eraseToAnyView()
        case .userAuth:
            return userAuth(viewStore).eraseToAnyView()
        case .medusaClient:
            return medusaClient(viewStore).eraseToAnyView()
        }
    }

    func feed(_ viewStore: ViewStoreOf<Application>) -> some View {
        return Screen {
            FeedRootView(
                store: self.store.scope(
                    state: { $0.feed },
                    action: { Application.Action.feed($0) }))
        }
    }

    func onBoarding(_ viewStore: ViewStoreOf<Application>) -> some View {
        return Screen {
            OnBoardingView(
                store: self.store.scope(
                    state: { $0.onBoarding},
                    action: { Application.Action.onBoarding($0) }))
        }
    }
    func medusaClient(_ viewStore: ViewStoreOf<Application>) -> some View {
        return Screen {
            MedusaUserView(store: medusaUserStore)
        }
    }

    func userAuth(_ viewStore: ViewStoreOf<Application>) -> some View {
        return Screen {
            AuthNLandingView(store: self.store.scope(
                state: { $0.userAuth },
                action: { Application.Action.userAuth($0)}))
        }
    }

    func landing(_ viewStore: ViewStoreOf<Application>) -> some View {
        return Screen {
            VStack {
                Spacer()
                HStack {
                    Text("Select a waypoint...")
                        .foregroundColor(Color.white)
                        .font(.largeTitle)
                        .underline()
                        .italic()
                }
                .padding()
                Group {
                    domainLink(label: "Feed", domain: Domain.feed, store: viewStore).eraseToAnyView()
                    Divider()
                    domainLink(label: "Medusa Client", domain: Domain.medusaClient, store: viewStore).eraseToAnyView()
                    Divider()
                    domainLink(label: "Authentication", domain: Domain.userAuth, store: viewStore).eraseToAnyView()
                    Divider()
                }
                Spacer()
            }
        }
    }
    
    func domainLink(label: String, domain: Domain, store: ViewStoreOf<Application>) -> some View {
        return HStack {
            Spacer()
            Button {
                store.send(Application.Action.navigate(domain))
            } label: {
                Text(label)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }
            Spacer()
        }.eraseToAnyView()
    }
}

struct RootView: View {
    var stack: NavigationStackCompat
    
    var body: some View {
        let store =
        StoreOf<Application>(
            initialState:
                Application.State(feed:
                                FeedFeature.State(
                                posts: __FIXTURES__.shuffledPosts,
                                signedInUser: UserProfile.Poseidon),
                                  userAuth: UserAuthFeature.State()),
            reducer:
                Application()._printChanges())
        
        NavigationStackView(navigationStack: stack) {
            DebugView(store: store)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        //  Screen {
        RootView(stack: NavigationStackCompat())
    }
    //  }
}
