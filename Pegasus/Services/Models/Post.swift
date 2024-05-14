import SwiftUI
import Siesta

struct Post: Equatable, Codable {
    var id: Int?
    var userId: Int
    var image: Data?
    var caption: String
    var likes: [Like] = []
    var imageUri: String?
    func toDictionary() -> Dictionary<String, Any> {
        return [
            "user_id": userId,
            "caption": caption
        ]
    }
}
extension Post {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case caption = "caption"
        case likes = "likes"
        case imageUri = "image_uri"
    }
}
struct Like: Equatable, Codable {
    var id: Int?
    var userId: Int
    var postId: Int
}
extension Like {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case postId = "post_id"
    }
}
