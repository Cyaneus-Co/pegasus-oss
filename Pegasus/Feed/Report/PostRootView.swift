import SwiftUI
import ComposableArchitecture

struct PostRootView: View {
    let store: StoreOf<PostFeature>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                switch viewStore.state.screen {
                case .post:
                    Screen {
                        PostView(self.store)
                    }
                    .transition(.move(edge: .leading))
                case .report:
                    Screen {
                        ReportView(store: self.store)
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .trailing))
                case .flagged:
                    Screen {
                        FlaggedPostView()
                    }
                    .transition(.slide)
                }
            }
        }
    }
}

struct PostRootView_Previews: PreviewProvider {
    static let store = StoreOf<PostFeature>(
        initialState:  __FIXTURES__.posts.first!,
        reducer: postReducer)
    static var previews: some View {
        Screen {
            PostRootView(store: store)
        }
    }
}

