import SwiftUI
import ComposableArchitecture

struct PostView: View {
    var store: StoreOf<PostFeature>
    
    init(_ store: StoreOf<PostFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack (alignment: .leading ) {
                HStack {
                    img(viewStore)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Layout.imageWidth, height: Layout.imageHeight)
                        .clipped()
                        .overlay(thumbnailOverlay(viewStore), alignment: .topLeading)
                }
                VStack {
                    HStack {
                        Text(viewStore.profile.account.username)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .frame(width: Layout.contentWidth * 0.5, alignment: .topLeading)
        //TODO: Fix username wrapping to new line when the caption is short
                        Button {
                            viewStore.send(.tapLikeButton)
                        } label: {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(viewStore.state.isLiked ? .red : .white)
                                .font(.system(size: 40))
                                .frame(width: Layout.contentWidth * 0.1, alignment: .topLeading)
                        }
                        Text("\(viewStore.state.numberOfLikes) likes")
                            .frame(width: Layout.contentWidth * 0.2, alignment: .topLeading)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        if viewStore.isAllowedToTrash {
                            Button {
                                viewStore.send(.tapTrashButton)
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(viewStore.state.isTrashed ? .red.darker() : .white)
                                    .font(.system(size: 40))
                                    .frame(width: Layout.contentWidth * 0.1, alignment: .topLeading)
                            }.alert(
                                self.store.scope(state: \.alert),
                                dismiss: .alertCancelTapped
                            )
                        } else {
                            Button {
                                // TOOD: add animation back
//                                withAnimation {
                                    viewStore.send(.tapReportButton)
//                                }
                            } label: {
                                Image(systemName: "flag.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 40))
                                    .frame(width: Layout.contentWidth * 0.1, alignment: .topLeading)
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Text("\(viewStore.caption)")
                            .frame(width: Layout.contentWidth, alignment: .topLeading)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: Layout.contentWidth)
            }
        }
    }
    
    func img(_ viewStore: ViewStoreOf<PostFeature>) -> Image {
        if let imgData = viewStore.imageData {
            return Image(uiImage: UIImage(data: imgData)!)
        } else if let imgPath = viewStore.imagePath {
            return Image(imgPath)
        }
        
        return Image(systemName: "questionmark.diamond.fill")
    }
    
    func thumbnailOverlay(_ store: ViewStoreOf<PostFeature>) -> some View {
        return Button {
            store.send(.avatarTapped(store.profile))
        } label: {
            ThumbnailView (
                image: store.profile.avatar,
                size: 75,
                clipShape: ClipShape.circle,
                color: .white)
                .padding(5)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        Screen {
            VStack{
                PostView(StoreOf<PostFeature>(
                    initialState:  __FIXTURES__.posts.first!,
                    reducer: postReducer))
            }
        }
    }
}
