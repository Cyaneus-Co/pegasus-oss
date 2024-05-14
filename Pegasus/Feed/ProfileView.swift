import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: StoreOf<FeedFeature>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    HStack {
                        Button {
                            viewStore.send(.homeTapped)
                        } label: {
                            Image(systemName: "arrow.backward.circle")
                                .font(.system(size: 20, weight:  .light))
                                .foregroundColor(.white)
                            Text("Back")
                                .font(.system(size: 20, weight:  .light))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .offset(x: 3, y: -40.0)
                    
                    
                    VStack {
                        ThumbnailView(
                            image: (viewStore.profileUser ?? viewStore.signedInUser).avatar,
                            size: 100,
                            clipShape: .circle,
                            color: .white
                        )
                        HStack {
                            Spacer()
                            Text("@\((viewStore.profileUser ?? viewStore.signedInUser).account.username)")
                                .font(.system(size: 15, weight:  .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
                DividerView(color: .white)
                VStack{
                    ScrollablePostsView(store: self.store)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            ProfileView(store: FeedView_Previews.testStore)
        }
    }
}
