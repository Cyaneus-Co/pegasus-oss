import SwiftUI
import ComposableArchitecture

struct CreatePostView: View {
    var store: StoreOf<CreatePostFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                switch (viewStore.step) {
                case .selectImage:
                    HStack {
                        Spacer()
                        createPost(viewStore)
                        Spacer()
                    }
                case .addCaption:
                    confirmPost(viewStore)
                case .done:
                    done(viewStore)
                }
                Spacer()
            }
        }
    }
    
    func createPost(_ viewStore: ViewStoreOf<CreatePostFeature>) -> some View {
        return VStack {
            ImageSelectorView(showingImagePicker: true,
                              label: Text("")) { (img: UIImage?) -> Void in
                guard let selectedImg = img else {
                    viewStore.send(.cancelPostTapped)
                    return
                }
                viewStore.send(.imageSelected(selectedImg))
            }.eraseToAnyView()
        }
    }
    
    func done(_ viewStore: ViewStoreOf<CreatePostFeature>) -> some View {
        return VStack {
            HStack {
                Spacer()
                Text("All Set! go to your feed")
                Spacer()
            }
        }.eraseToAnyView()
    }
    
    func confirmPost(_ viewStore: ViewStoreOf<CreatePostFeature>) -> some View {
        return Group {
            HStack{
                Spacer()
                ThumbnailView(
                    image: viewStore.image!,
                    size: Layout.contentWidth,
                    clipShape: .roundedRectangle,
                    color: .black
                )
                Spacer()
            }
            Divider()
            HStack {
                Spacer()
                
                let placeholder = "Enter a caption"
                ZStack(alignment: .topLeading) {
//                    TextEditor(text: viewStore.binding(
//                        keyPath: \.caption,
//                        send: CreatePostAction.captionUpdated)
//                    )
//                        .frame(width: Layout.contentWidth, height: 100, alignment: .leading)
//                        .cornerRadius(8.0)
//                        .keyboardType(.twitter)
//                        .foregroundColor(Color(.label))
//                        .multilineTextAlignment(.leading)
                    Text(viewStore.caption.isEmpty ? placeholder : viewStore.caption)
                        .padding(.leading, 5)
                        .foregroundColor(Color(.placeholderText))
                        .opacity(viewStore.caption.isEmpty ? 1 : 0)
                        .padding(.top, 8)
                }
                .font(.body)
                Spacer()
            }
            HStack {
                Text("Upload this picture?")
                    .font(.system(size: 30, weight:  .light))
            }
            .padding(.top)
            .padding(.bottom)
            HStack {
                Spacer()
                Button {
                    viewStore.send(.cancelPostTapped)
                } label: {
                    StyledLabel(text: "No",
                                imageName: "trash.fill",
                                backgroundColor: Color.red)
                }
                Spacer()
                Button {
                    viewStore.send(.createPostTapped)
                } label: {
                    StyledLabel(text: "Yes",
                                imageName: "photo.fill",
                                backgroundColor: Color.green)
                }
                Spacer()
            }
            Spacer()
        }.eraseToAnyView()
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            CreatePostView(
                store: StoreOf<CreatePostFeature>(
                    initialState: CreatePostFeature.State(),
                    reducer: CreatePostFeature()))
        }
    }
}
