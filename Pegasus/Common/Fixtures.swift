import SwiftUI
import ComposableArchitecture

/**
 *
 * Provide fixtures for development:
 *  - Existing  4 users in UserProfile
 *  - Create N Posts for each
 */

let __FIXTURES__ = Fixtures()

struct Fixtures {
    var posts : [PostFeature.State] = []
    var postIdSequence = 0
    var images = [
        "alberta",
        "avenue",
        "beach",
        "bird",
        "fantasy",
        "field",
        "lake",
        "mountains",
        "owl",
        "tree"
    ].shuffled()
    var imgIndex : Int = -1
    var users = [UserProfile.Chrysaor,
                 UserProfile.Medusa,
                 UserProfile.Pegasus,
                 UserProfile.Poseidon]

    init() {
        users.enumerated().forEach { (index, user) in
            (1...Int.random(in: 2..<5)).forEach { _ in
                postIdSequence += 1
                posts.append(
                    newPost(forProfile: user)
                )
            }
        }
    }

    var shuffledPosts : IdentifiedArrayOf<PostFeature.State> {
        get {
            return IdentifiedArrayOf<PostFeature.State>(uniqueElements: posts.shuffled())
        }
    }

    mutating func newPost(forProfile: UserProfile) -> PostFeature.State {
        var postState = PostFeature.State(
            from:
                Post(id: postIdSequence,
                     userId: postIdSequence * 100,
                     image:
                        UIImage(named: sampleImage())?
                        .jpegData(compressionQuality: 1.0),
                     caption: Lorem.words(3..<20),
                     likes: genLikes(postId: postIdSequence),
                     imageUri: "https://medusa.cyaneus.co/img/123"),
            by: forProfile)

        postState.isLiked = flipCoins(3)
        postState.isTrashed = false
        postState.isFlagged = flipCoins(1)

        return postState
    }

    func genLikes(postId: Int) -> [Like] {
        return (1...(Int.random(in: 4..<200))).map {i in
            return Like(userId: Int.random(in: 1..<1000000), postId: postId)
        }
    }

    func flipCoins(_ bias: Int = 5) -> Bool {
        return Int.random(in: 1...10) <= 5
    }

    mutating func sampleImage() -> String {
        if imgIndex == (images.endIndex - 1) {
            images.shuffle()
            imgIndex = -1
        }
        imgIndex += 1

        return images[imgIndex]
    }
}
