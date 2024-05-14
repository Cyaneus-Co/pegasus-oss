import ComposableArchitecture
import SwiftUI

struct ScrollablePostsView: View {
    let store: StoreOf<FeedFeature>
    
    var body: some View {
        ScrollView {
            VStack {
                ForEachStore(self.store.scope(
                    state: { $0.posts },
                    action: FeedFeature.Action.post(id:action:))) { postStore in
                        HStack {
                            PostRootView(store: postStore)
                        }
                    }
            }
        }
    }
}

struct ScrollablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            ScrollablePostsView(store: FeedView_Previews.testStore)
        }
    }
}
