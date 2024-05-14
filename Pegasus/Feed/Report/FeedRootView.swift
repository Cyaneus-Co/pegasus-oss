import SwiftUI
import ComposableArchitecture

struct FeedRootView: View {
    let store: StoreOf<FeedFeature>
    
    var body: some View {
        VStack {
            WithViewStore(self.store) { viewStore in
                selectView(viewStore: viewStore)
            }
        }
    }
    
    func selectView(viewStore: ViewStoreOf<FeedFeature>) -> some View {
        switch viewStore.state.currentScreen {
        case .feed:
            return Screen {
                FeedView(store: self.store)
            }.eraseToAnyView()
        case .addPost:
            return Screen {
                VStack {
                    CreatePostView(
                        store: self.store.scope(
                            state: \.createPost,
                            action: FeedFeature.Action.createPost))
                    Divider()
                }
            }.eraseToAnyView()
        case .profile:
            return Screen {
                ProfileView(store: self.store)
            }.eraseToAnyView()
        }
    }
}

struct FeedRootView_Previews: PreviewProvider {
    static let store = StoreOf<FeedFeature>(
        initialState:
            FeedFeature.State(
                posts: IdentifiedArrayOf<PostFeature.State>(__FIXTURES__.posts),
                signedInUser: UserProfile.Poseidon),
        reducer: feedReducer)
    static var previews: some View {
        Screen {
            FeedRootView(store: store)
        }
    }
}
