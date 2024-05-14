import Siesta
import SiestaUI
import Foundation
import SwiftUI
import ComposableArchitecture
import Combine

import UIKit
import ImageIO

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, PNG, JPEG, GIF, TIFF
}


extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else if buffer == ImageHeaderData.GIF
        {
            return .GIF
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else{
            return .Unknown
        }
    }
}

let CyaneusImgStore = _CyaneusImgStoreApi()

class _CyaneusImgStoreApi: NSObject {
    private let service = Service(
        baseURL: "https://plutoimagestore.nyc3.digitaloceanspaces.com", //https://plutoimagestore.nyc3.digitaloceanspaces.com/post-93.jpg
        standardTransformers: [.image])
    
    fileprivate override init() {
        super.init()
#if DEBUG
        SiestaLog.Category.enabled = .all // [.network] .common .detailed
#endif
    }
    
    func img(_ post: PostFeature.State) -> Resource {
        return service.resource(absoluteURL: post.imageUri)
    }
}

let MedusaApi = _MedusaApi()

class _MedusaApi: NSObject {
    private let service = Service(
        baseURL: "http://api.medusa.com:8989",
        standardTransformers: [.text, .image])
    
    fileprivate override init() {
        super.init()
#if DEBUG
        // Bare-bones logging of which network calls Siesta makes:
        //SiestaLog.Category.enabled = [.network]
        
        // For more info about how Siesta decides whether to make a network call,
        // and which state updates it broadcasts to the app:
        
        //SiestaLog.Category.enabled = .common
        
        // For the gory details of what Siesta’s up to:
        
        //SiestaLog.Category.enabled = .detailed
        
        // To dump all requests and responses:
        // (Warning: may cause Xcode console overheating)
        
        SiestaLog.Category.enabled = .all
#endif
        
        let jsonDecoder = JSONDecoder()
        
        // –––––– Resource-specific configuration ––––––
        
        service.configure("/users/**") {
            // Refresh search results after 10 seconds (Siesta default is 30)
            $0.expirationTime = 10
        }
        
        service.configureTransformer("/users/*") {
            // Input type inferred because the from: param takes Data.
            // Output type inferred because jsonDecoder.decode() will return User
            try jsonDecoder.decode(User.self, from: $0.content)
        }
        
        service.configureTransformer("/users/*/posts", requestMethods: [.get]) {
            try jsonDecoder.decode([Post].self, from: $0.content)
        }
        
        service.configureTransformer("/users/*/posts", requestMethods: [.post]) {
            try jsonDecoder.decode(Post.self, from: $0.content)
        }
        
        service.configureTransformer("/users/*/posts/*/likes", requestMethods: [.get]) {
            try jsonDecoder.decode([Like].self, from: $0.content)
        }
        
        service.configureTransformer("/users/*/posts/*/likes", requestMethods: [.post]) {
            try jsonDecoder.decode(Like.self, from: $0.content)
        }
        
        service.configureTransformer("/users/*/posts/*/img", requestMethods: [.post]) {
            try jsonDecoder.decode(MedusaBoolResult.self, from: $0.content)
        }
    }
    
    var users: Resource {
        return service.resource("/users")
    }
    
    func user(_ id: Int) -> Resource {
        return users.child(String(id))
    }
    
    func posts(_ userId: Int) -> Resource {
        return user(userId).child("/posts")
    }
    
    func post(userId: Int, postId: Int) -> Resource {
        return posts(userId).child(String(postId))
    }
    
    func likes(userId: Int, postId: Int) -> Resource {
        return post(userId: userId, postId: postId).child("/likes")
    }
    
    func like(userId: Int, postId: Int, likeId: Int) -> Resource {
        return likes(userId: userId, postId: postId).child(String(likeId))
    }
    
    func img(userId: Int, postId: Int) -> Resource {
        return post(userId: userId, postId: postId).child("/img")
    }
    
    func createPost(user: User, post: Post) -> Request {
        return posts(user.id!)
            .request(.post, json: post.toDictionary())
    }
}

// Domain

struct User: Codable, Equatable {
    let id: Int?
    let firstName, lastName, email, phone, username, password: String
}

extension User {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case phone = "phone"
        case username = "username"
        case password = "password"
        case id = "id"
    }
}

struct MedusaUserState: Equatable {
    var user: User?
    var userIdQuery: String = ""
    var errorMessage: String?
    var newCaption: String = ""
    var posts: IdentifiedArrayOf<PostFeature.State> = []
    var currentImg: Resource?
}

struct MedusaUserEnvironment {}

enum MedusaUserAction: Equatable {
    case userIdChanged(BindingAction<MedusaUserState>)
    case newCaptionChanged(BindingAction<MedusaUserState>)
    case userLoaded(Result<User?, MedusaError>)
    case loadPosts
    case postsLoaded(Result<[Post], MedusaError>)
    case createPost
    case postCreated(Result<Post, MedusaError>)
    case deletePost(UUID)
    case postDeleted(Result<UUID, MedusaError>)
    case likePost(UUID)
    case postLiked(Result<Like, MedusaError>)
    case imgUploaded(Result<MedusaBoolResult, MedusaError>)
    case showImg(UUID)
    case imgDismissed
}

struct MedusaRequestId: Hashable {}

let medusaUserReducer: Reducer<MedusaUserState, MedusaUserAction, MedusaUserEnvironment> =
Reducer { state, action, env in
    switch action {
    case .userIdChanged:
        return MedusaApi
            .user(state.userIdQuery.isEmpty ? 0 : Int(state.userIdQuery)!)
            .statePublisher()
            .map { (resourceState: ResourceState<User>) in
                if let err = resourceState.latestError {
                    return Result.failure(MedusaError.fromError(err))
                } else if let user = resourceState.content {
                    return Result.success(user)
                }
                
                // still loading
                return Result.failure(MedusaError.withMessage("Resource is still loading"))
            }
            .map { result in
                return MedusaUserAction.userLoaded(result)
            }
            .eraseToEffect()
            .cancellable(id: MedusaRequestId(), cancelInFlight: true)
        
    case .userLoaded(.success(let user)):
        state.user = user
        state.errorMessage = nil
        return Effect(value: MedusaUserAction.loadPosts)
    case .userLoaded(.failure(let err)):
        state.user = nil
        state.errorMessage = err.localizedDescription
        state.posts = []
        return .none
    case .loadPosts:
        return MedusaApi
            .posts(state.user!.id!)
            .contentPublisher()
            .map { (posts:[Post]) in
                return MedusaUserAction.postsLoaded(Result.success(posts))
            }
            .eraseToEffect()
            .cancellable(id: MedusaRequestId())
        
    case .postsLoaded(.success(let posts)):
        state.posts.removeAll()
        posts.forEach { p in
            state.posts.append(PostFeature.State(from: p, by: UserProfile.Medusa))
        }
        return .none
    case .postsLoaded(.failure(let err)):
        return .none
    case .createPost:
        guard let user = state.user, let userId = user.id else {
            return .none
        }
        let caption = state.newCaption
        
        return MedusaApi
            .posts(userId)
            .dataRequestPublisher {
                $0.request(.post,
                           json: Post(userId: userId,
                                      caption: caption,
                                      likes: [])
                            .toDictionary())
            }
            .mapError(MedusaError.fromError)
            .catchToEffect()
            .map(MedusaUserAction.postCreated)
            .cancellable(id: MedusaRequestId())
        
    case .postCreated(.success(let post)):
        state.posts.append(PostFeature.State(from: post, by: UserProfile.Pegasus))
        state.newCaption = ""
        
        let filename = "img_\(post.id!)"
        let data = UserService
            .instance
            .signedInUser()!
            .avatar
            .jpegData(compressionQuality: 1.0)
        
        return MedusaApi
            .img(userId: post.userId, postId: post.id!)
            .dataRequestPublisher {
                $0.request(.post,
                           multipart: [:],
                           files: [filename : FilePart(filename: filename, type: "image/jpeg", data: data!)],
                           order: [filename])
            }
            .mapError(MedusaError.fromError)
            .catchToEffect()
            .map(MedusaUserAction.imgUploaded)
            .cancellable(id: MedusaRequestId())
        
    case .postCreated(.failure(let err)):
        state.errorMessage = err.errorDescription
        
        return .none
    case .newCaptionChanged:
        return .none
    case .deletePost(let uuid):
        // TODO: (mrm) this is gross, unexpected state
        guard let post = state.posts.first(where: { $0.id == uuid }),
              let postId = post.postId,
              let user = state.user,
              let userId = user.id else {
                  return .none
              }
        
        return MedusaApi
            .post(userId: userId, postId: postId)
            .requestPublisher {
                $0.request(.delete)
            }
            .mapError(MedusaError.fromError)
            .catchToEffect()
            .map { _ in
                MedusaUserAction.postDeleted(.success(uuid))
            }
            .cancellable(id: MedusaRequestId())
        
    case .postDeleted(.success(let uuid)):
        state.posts.remove(id: uuid)
        
        return .none
    case .likePost(let uuid):
        guard let post = state.posts.first(where: { $0.id == uuid }),
              let postId = post.postId,
              let user = state.user,
              let userId = user.id else {
                  state.errorMessage = "Unable to find post that was liked \(uuid.uuidString.prefix(6))"
                  return .none
              }
        
        return MedusaApi
            .likes(userId: userId, postId: postId)
            .dataRequestPublisher {
                $0.request(.post, json: ["user_id": userId, "post_id": postId])
            }
            .mapError(MedusaError.fromError)
            .catchToEffect()
            .map(MedusaUserAction.postLiked)
            .cancellable(id: MedusaRequestId())
        
    case .postLiked(.success(let like)):
        MedusaApi
            .post(userId: like.userId,
                  postId: like.postId)
            .invalidate()
        
        for (i, p) in state.posts.enumerated() {
            if (p.postId == like.postId) {
                //state.posts[i].numberOfLikes += 1
                return .none
            }
        }
        
        state.errorMessage = "Ooops, cannot find the post that was liked \(like)"
        
        return .none
    case .postLiked(.failure(let err)),
            .postDeleted(.failure(let err)):
        state.errorMessage = err.errorDescription
        return .none
    case .imgUploaded(.success(let result)):
        guard let metadata = result.metadata,
              let postId = metadata["post"],
              let uri = metadata["uri"] else {
                  state.errorMessage = "Unable to retrieve result metadata"
                  return .none
              }
        
        for (i, p) in state.posts.enumerated() {
            if (p.postId == Int(postId)) {
// TODO:               state.posts[i].imageUri = uri
                return .none
            }
        }
        
        return .none
    case .imgUploaded(.failure(let err)):
        state.errorMessage = err.errorDescription
        return .none
    case .showImg(let postUuid):
        guard let post = state.posts.first(where: { $0.id == postUuid }) else {
            return .none
        }
        
        state.currentImg = CyaneusImgStore.img(post)
        
        return .none
    case .imgDismissed:
        state.currentImg = nil
        return .none
    }
}
.binding(action: /MedusaUserAction.userIdChanged)
.binding(action: /MedusaUserAction.newCaptionChanged)
//.debug()

struct ResourceImageView: UIViewRepresentable {
    var imgResource : Resource?
    
    func makeUIView(context: Context) -> RemoteImageView {
        let imgView = RemoteImageView()
        imgView.imageResource = self.imgResource
        
        return imgView
    }
    
    func updateUIView(_ uiView: RemoteImageView, context: Context) {
        
    }
}

struct MedusaUserView: View {
    let store: Store<MedusaUserState, MedusaUserAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "ladybug.fill").foregroundColor(.white)
                    Text("Medusa API Client")
                        .underline()
                    Image(systemName: "ladybug.fill").foregroundColor(.white)
                    Spacer()
                }
                .font(.largeTitle)
                .foregroundColor(.white)
                Divider()
                HStack {
                    TextField("enter a post caption",
                              text: viewStore.binding(
                                keyPath: \.newCaption,
                                send: MedusaUserAction.newCaptionChanged
                              ))
                        .frame(width: 340, height: 30, alignment: .center)
                        .padding()
                }
                .background(Color.white)
                .padding(.horizontal)
                if let user = viewStore.user {
                    HStack {
                        Text("username: \(user.username)")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack {
                        Text("name: \(user.firstName) \(user.lastName)")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack {
                        Text("email: \(user.email)")
                            .foregroundColor(.white)
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("No User Loaded...")
                            .foregroundColor(.white)
                            .italic()
                            .underline()
                        Spacer()
                    }
                }
                if viewStore.currentImg == nil {
                    postListing(viewStore)
                } else {
                    VStack {
                        ResourceImageView(imgResource: viewStore.currentImg)
                            .frame(width: 200, height: 200, alignment: .center)
                        HStack {
                            Spacer()
                            Button {
                                viewStore.send(.imgDismissed)
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Text(viewStore.errorMessage ?? "Looking good...")
                    Spacer()
                }
                .frame(width: 370, height: 28)
                .background(viewStore.errorMessage == nil ? Color.green.lighter() : Color.red.lighter())
                Spacer()
            }
        }
    }
    
    func postListing(_ viewStore: ViewStore<MedusaUserState, MedusaUserAction>) -> some View {
        return VStack {
            ForEach(viewStore.posts) {post in
                HStack {
                    Text("[\( String(post.id.uuidString.prefix(6)) )]")
                    Text(post.caption).fontWeight(.bold)
                    Spacer()
                    Button {
                        viewStore.send(MedusaUserAction.showImg(post.id))
                    } label: {
                        Image(systemName: "photo.fill").foregroundColor(.blue)
                    }
                    Button {
                        viewStore.send(MedusaUserAction.deletePost(post.id))
                    } label: {
                        Image(systemName: "trash.fill").foregroundColor(.red)
                    }
                    Button {
                        viewStore.send(MedusaUserAction.likePost(post.id))
                    } label: {
                        Image(systemName: "hand.thumbsup.fill").foregroundColor(.green)
                    }
                    Text("[\(post.numberOfLikes)]")
                }
                .padding([.leading, .trailing], 10)
            }
            Divider()
            HStack {
                Spacer()
//                TextField("enter a post caption",
//                          text: viewStore.binding(
//                            keyPath: \.newCaption,
//                            send: MedusaUserAction.newCaptionChanged
//                          ))
//                    .padding()
                Spacer()
            }
            .background(Color.white)
            Divider()
            Button {
                viewStore.send(MedusaUserAction.createPost)
            } label: {
                HStack {
                    Spacer()
                    Text("Create Post")
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }.background(Color.blue.darker())
            }
        }
        .padding([.leading, .trailing], 10)
        .eraseToAnyView()
    }
}

let medusaUserStore = Store<MedusaUserState, MedusaUserAction>(
    initialState: MedusaUserState(),
    reducer: medusaUserReducer,
    environment: MedusaUserEnvironment()
)

struct MedusaUserView_Previews: PreviewProvider {
    static var previews: some View {
        MedusaUserView(store: medusaUserStore)
    }
}
