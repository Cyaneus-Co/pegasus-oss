import SwiftUI
import ComposableArchitecture
import NavigationStack

struct ReportView: View {
    let store: StoreOf<PostFeature>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                // Title HStack
                HStack {
                    Spacer()
                    Button {
                        // TODO: re-enable animation
//                        withAnimation {
                        viewStore.send(.reportCancelTapped)
//                        }
                    } label: {
                        Image(systemName: "arrow.backward.circle")
                            .font(.system(size: 40, weight:  .light, design: .serif))
                            .foregroundColor(.white)
                    }
                    Text("Report Post:")
                        .font(.system(size: 40, weight:  .medium))
                        .foregroundColor(.white)
                        .underline()
                        .lineLimit(1)
                    Spacer()
                }
                
                ThumbnailView(
                    image: UIImage(
                        data: viewStore.imageData!)!,
                    size: 225,
                    clipShape: .roundedRectangle,
                    color: .black
                )

                TextFieldView(store: self.store.scope(
                    state: \.reportedPostUsername,
                    action: PostFeature.Action.readOnlyField)).disabled(true)
                TextFieldView(store: self.store.scope(
                    state: \.reportedPostCaption,
                    action: PostFeature.Action.readOnlyField)).disabled(true)
                TextFieldView(store: self.store.scope(
                    state: \.otherReportingInfo,
                    action: PostFeature.Action.otherReportingInfo))
                
                Button {
                    viewStore.send(PostFeature.Action.reportSubmitTapped)
                } label: {
                    HStack {
                        Text("Submit Report")
                            .fontWeight(.light)
                            .font(.system(size: 28, weight:  .ultraLight, design: .serif))
                    }
                }.buttonStyle(PegasusButtonStyle())
            }
            .padding()
            .background(
                Image("leaves")
                    .resizable()
                    .scaledToFill()
            )
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            ReportView(store: StoreOf<PostFeature>(
                initialState: __FIXTURES__.shuffledPosts.first!,
                reducer: postReducer)
            )
        }
    }
}
