import SwiftUI
import ComposableArchitecture

struct FeedView: View {
    let store: StoreOf<FeedFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack {
                    HStack {
                        Button {
                            viewStore.send(.profileTapped)
                        } label: {
                            ThumbnailView(
                                image: viewStore.signedInUser.avatar,
                                size: 60,
                                clipShape: .circle,
                                color: .white
                            )
                        }
                        Spacer()
                        Button {
                            viewStore.send(.addPostTapped)
                        } label: {
                            Image(systemName: "plus.app.fill")
                                .font(.system(size: 55, weight:  .light))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 1)
                    DividerView(color: .white)
                }
                .frame(width: Layout.contentWidth)
                if viewStore.posts.isEmpty {
                    ZeroPostView()
                } else {
                    ScrollablePostsView(store: self.store)
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static let testStore: StoreOf<FeedFeature> = Store(
        initialState: FeedFeature.State(signedInUser: UserProfile.Poseidon),
        reducer: feedReducer)
    
    static var previews: some View {
        Screen {
            VStack {
                FeedView(store: testStore)
            }
        }
    }
}
