import SwiftUI
import ComposableArchitecture

struct AuthNLandingView: View {
    
    let store: StoreOf<UserAuthFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                switch viewStore.authStep {
                case .initial:
                    OnBoardingView(
                        store:
                            self.store.scope(
                                state: \.onBoardingState,
                                action: UserAuthFeature.Action.onBoarding))
                    SignInView(store: self.store)
                case .registered:
                    Screen {
                        SignInView(store: self.store)
                    }
                case .signedIn:
                    Screen {
                        UserInfoView(store: self.store)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct UserInfoView: View {

    let store: StoreOf<UserAuthFeature>

    var body: some View {
        WithViewStore(store) { viewStore in
            // @todo(jasper) we need to redirect to Feed/Home
            Text("Welcome, \(viewStore.userInfo!.username)")
            List {
                HStack {
                    Text("first").bold()
                    Text("\(viewStore.userInfo!.firstName)")
                    Spacer()
                }
                HStack {
                    Text("last").bold()
                    Text("\(viewStore.userInfo!.lastName)")
                    Spacer()
                }
                HStack {
                    Text("email").bold()
                    Text("\(viewStore.userInfo!.email)")
                    Spacer()
                }
                HStack {
                    Text("phone").bold()
                    Text("\(viewStore.userInfo!.phone)")
                    Spacer()
                }
            }
        }
    }
}

struct AuthNLandingView_Previews: PreviewProvider {
    static let store = StoreOf<UserAuthFeature>(
        initialState: UserAuthFeature.State(),
        reducer: userAuthReducer)
    
    static var previews: some View {
        Screen {
            AuthNLandingView(store: store)
        }
    }
}
