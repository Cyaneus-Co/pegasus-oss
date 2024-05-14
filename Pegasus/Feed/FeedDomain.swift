import ComposableArchitecture
import SwiftUI
import CoreMedia

enum CreatePostStep {
    case selectImage
    case addCaption
    case done
}

struct CreatePostFeature: ReducerProtocol {
    struct State: Equatable {
        var image: UIImage?
        @BindableState var caption: String = ""
        var step: CreatePostStep = .selectImage
    }

    enum Action: Equatable, BindableAction {
        case selectImageTapped
        case imageSelected(UIImage)
        case binding(BindingAction<State>)
        case cancelPostTapped
        case createPostTapped
        case createPostResponse(Result<Post, MedusaError>)
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .selectImageTapped:
                return .none
            case .imageSelected(let img):
                state.step = .addCaption
                state.image = img
                return .none
            case .cancelPostTapped:
                state.image = nil
                state.caption = ""
                state.step = .selectImage
                return .none
            case .createPostTapped:
                return Effect(
                    value: Action.createPostResponse(
                        Result.success(
                            Post(
                                userId: 2,
                                image: state.image!.jpegData(compressionQuality: 1.0)!,
                                caption: state.caption,
                                likes: []))))
            case .binding(\.$caption):
                // TODO: mrm add remote call
                return .none
            case .binding(_):
                return .none
            case .createPostResponse(.failure):
                return .none
            case .createPostResponse(.success):
                state.image = nil
                state.caption = ""
                state.step = .selectImage
                return .none
            }
        }
    }
}

enum ReasonForReporting: Equatable {
    case inaproprateContent
    case harasment
    case iDontLikeThis
}

enum PostScreen: Equatable {
    case post
    case report
    case flagged
}

extension PostFeature.State {
    var image: Image {
        get {
            if let imgData = self.imageData {
                return Image(uiImage: UIImage(data: imgData)!)
            } else if let imgPath = self.imagePath {
                return Image(systemName: imgPath)
            }
            return Image(systemName: "questionmark.diamond.fill")
        }
    }
    var isAllowedToTrash: Bool {
        get {
            return UserService.instance.signedInUser() == self.profile
        }
    }
}

struct PostFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID
        var postId: Int?
        var imagePath: String?
        var imageUri: String?
        var imageData: Data?
        var isLiked: Bool
        var isTrashed: Bool
        var isFlagged: Bool
        var numberOfLikes: Int
        var profile: UserProfile
        var caption: String
        var alert: AlertState<Action>?
        var reasonForReporting: ReasonForReporting?
        var otherReportingInfo = TextFieldFeature.State(
            id: UUID(),
            rawValue: "",
            isValid: true,
            placeholder: "Any other information",
            imageName: "doc.text.image.fill"
        )
        var reportedPostUsername = TextFieldFeature.State(
            id: UUID(),
            rawValue: "",
            isValid: true,
            placeholder: "Username of reported post",
            imageName: "person.crop.circle.fill"
        )
        var reportedPostCaption = TextFieldFeature.State(
            id: UUID(),
            rawValue: "",
            isValid: true,
            placeholder: "Caption of reported post",
            imageName: "text.bubble.fill"
        )
        var screen = PostScreen.post
        
        init(id: UUID, postId: Int, imagePath: String, isLiked: Bool, isTrashed: Bool, isFlagged: Bool, numberOfLikes: Int, profile: UserProfile, caption: String) {
            self.id = id
            self.postId = postId
            self.imagePath = imagePath
            self.isLiked = isLiked
            self.isTrashed = isTrashed
            self.isFlagged = isFlagged
            self.numberOfLikes = numberOfLikes
            self.profile = profile
            self.caption = caption
        }
        
        init(from: Post, by: UserProfile) {
            self.id = UUID()
            self.postId = from.id
            self.imageData = from.image
            self.isLiked = false
            self.isTrashed = false
            self.isFlagged = false
            self.numberOfLikes = from.likes.count
            self.profile = by
            self.caption = from.caption
            self.imageUri = from.imageUri
        }
        
    }
    
    enum Action: Equatable {
        case setCurrentScreen(screen: PostScreen)
        case tapLikeButton
        case tapTrashButton
        case tapReportButton
        case alertConfirmTapped
        case alertCancelTapped
        case otherReportingInfo(action: TextFieldFeature.Action)
        case reportCancelTapped
        case reportSubmitTapped
        case readOnlyField(action: TextFieldFeature.Action)
        case avatarTapped(_ profile: UserProfile)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setCurrentScreen(let screen):
            state.screen = screen
            return .none
        case .tapLikeButton:
            if state.isLiked {
                state.numberOfLikes -= 1
            } else {
                state.numberOfLikes += 1
            }
            state.isLiked.toggle()
            return .none
        case .tapTrashButton:
            state.isTrashed = true
            state.alert = AlertState(
                title: TextState("Delete"),
                message: TextState("Are you sure you want to delete this post? It cannot be undone."),
                primaryButton: .default(TextState("Confirm"), send: .alertConfirmTapped),
                secondaryButton: .cancel()
            )
            return .none
        case .tapReportButton:
            state.reportedPostUsername.rawValue = state.profile.account.username
            state.reportedPostCaption.rawValue = state.caption
            state.screen = .report
            return .none
        case .alertConfirmTapped:
            state.alert = nil
            return .none
        case .alertCancelTapped:
            state.alert = nil
            state.isTrashed = false
            return .none
        case .otherReportingInfo(action:):
            return .none
        case .reportCancelTapped:
            state.reportedPostUsername.rawValue = ""
            state.reportedPostCaption.rawValue = ""
            state.screen = .post
            return .none
        case .reportSubmitTapped:
            state.screen = .flagged
            state.isFlagged = true
            return .none
        case .readOnlyField(action:):
            return .none
        case .avatarTapped:
            return .none
        }

    }
}

let postReducer = PostFeature()

enum FeedScreen: Equatable {
    case feed
    case addPost
    case profile
    //   case report
}

struct FeedFeature: ReducerProtocol {
    struct State: Equatable {
        var currentScreen: FeedScreen = .feed
        var posts: IdentifiedArrayOf<PostFeature.State> = [ ]
        var createPost = CreatePostFeature.State()
        var signedInUser : UserProfile
        var profileUser : UserProfile?
        
    }

    enum Action: Equatable {
        case addPostTapped
        case homeTapped
        case profileTapped
        case post(id: PostFeature.State.ID, action: PostFeature.Action)
        case createPost(action: CreatePostFeature.Action)
        case loadPosts
        case postsLoaded(Result<[Post], MedusaError>)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.createPost, action: /Action.createPost) {
            CreatePostFeature()
        }

        Reduce { state, action in
            switch action {
            case .post(id: let id, action: PostFeature.Action.alertConfirmTapped):
                state.posts.remove(id: id)
                return .none
            case .post(id: let id, action: PostFeature.Action.avatarTapped(let profile)):
                state.currentScreen = .profile
                state.profileUser = profile
                return Effect(value: .loadPosts)
            case .post(id: _, action: _):
                return .none
            case .homeTapped:
                state.currentScreen = .feed
                state.profileUser = nil
                state.posts = __FIXTURES__.shuffledPosts
                return .none
            case .addPostTapped:
                state.currentScreen = .addPost
                return .none
            case .profileTapped:
                state.currentScreen = .profile
                state.posts = __FIXTURES__.shuffledPosts.filter { post in
                    post.profile == state.signedInUser
                }
                return .none
            case .createPost(action: CreatePostFeature.Action.createPostResponse(.success(let post))):
                state.posts.insert(
                    PostFeature.State(
                        from: post,
                        by: UserService.instance.signedInUser()!),
                    at: 0)
                state.currentScreen = .feed
                return .none
            case .createPost(action: CreatePostFeature.Action.cancelPostTapped):
                if (state.createPost.image == nil) {
                    state.currentScreen = .feed
                }
                return .none
            case .createPost(action: _):
                return .none
            case .postsLoaded(.success(let posts)) :
                //            var postStates = posts.map { post in
                //                PostState(
                //                    from: post,
                //                    by: state.profileUser ?? state.signedInUser)
                //            }
                //            state.posts = IdentifiedArrayOf<PostState>(postStates)
                state.posts = __FIXTURES__.shuffledPosts.filter { post in
                    post.profile == state.profileUser ?? state.signedInUser
                }
                return .none
            case .postsLoaded(.failure(let error)) :
                return .none
            case .loadPosts:
                /*
                 return MedusaApi
                 .posts(state.profileUser!.account.id!)
                 .contentPublisher()
                 .map { (posts:[Post]) in
                 return FeedAction.postsLoaded(Result.success(posts))
                 }
                 .eraseToEffect()
                 .cancellable(id: MedusaRequestId())
                 */
                return Effect(value: .postsLoaded(.success([])))
                
            }
        }.forEach(\.posts, action: /Action.post) {
            PostFeature()
        }
    }
}

let feedReducer = FeedFeature()
