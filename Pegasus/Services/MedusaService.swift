import Foundation
import ComposableArchitecture
import Siesta

protocol MedusaServiceProtocol {
    func findById(id: Int) -> Account
    func create(account: Account) -> Account
    func update(account: Account) -> Account
    func delete(account: Account) -> Void
}
let ExistingUsernames: [String] = ["jasper", "matt"]
typealias RestCallReturnBlock<T> = ((T?, Error?) -> Void)?
enum MedusaError: Error, Equatable {
    static func == (lhs: MedusaError, rhs: MedusaError) -> Bool {
        guard let left = lhs.errorDescription, let right = rhs.errorDescription else {
            return false
        }
        return left == right
    }
    case fromError(_ e: Error)
    case withMessage(_ msg: String)
    case runtime
}
extension MedusaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fromError(let e):
            return e.localizedDescription
        case .withMessage(let msg):
            return msg
        case .runtime:
            return "Runtime Exception"
        }
    }
}
struct MedusaBoolResult: Codable, Equatable {
    var result: Bool
    var metadata: [String:String]?
}
struct MedusaService: MedusaServiceProtocol {
    func findById(id: Int) -> Account {
        Account.TestAccount
    }
    func create(account: Account) -> Account {
        print("Creating account")
        Self.createAccount(account: account) { (account, error) in
            guard let account = account, error == nil else {
                print("failed to create accounut: \(error?.localizedDescription ?? "No data")")
                return
            }
            print("Recieving reponse from backend: \(account)")
        }
        return account
    }
    func update(account: Account) -> Account {
        Account.TestAccount
    }
    func delete(account: Account) {
    }
    static func isUsernameAvailable(_ username: String) -> Effect<Bool, MedusaError> {
        return MedusaClient.local.isUsernameAvailable(username)
    }

    /*
     - re-point account registration to medusa
     - medusa will register w/ KC
     - user will have to log in again?
     - medusa needs to host an authed endpoint /register
     */
    static func createAccount(account: Account, completion: RestCallReturnBlock<Account>) {
        guard let final = URL(string: "http://localhost:8080/account") else { return }
        var request = URLRequest(url: final,
                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                                 timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(account)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    completion?(nil, error)
                } else {
                    completion?(nil, nil)
                }
                return
            }
            let decoder =  JSONDecoder()
            do {
                let account = try decoder.decode(Account.self, from: data)
                completion?(account, nil)
            } catch let error {
                completion?(nil, error)
            }
        }.resume()
    }
    func client() -> MedusaClient {
        return MedusaClient.local
    }
}
struct MedusaClient {
    var create: (Account) -> Effect<Account, MedusaError>
    var isUsernameAvailable: (String) -> Effect<Bool, MedusaError>
    var createPost: (Post) -> Effect<Post, MedusaError>
}
extension MedusaClient {
    static let local = MedusaClient { account in
        var request = URLRequest(url: URL(string: "http://localhost:8989/users")!,
                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                                 timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(account)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map {data, _ in
                print("received the response for MedusaClient.create():")
                print("\(data)")

                return data
            }
            .decode(type: Account.self, decoder: JSONDecoder())
            .mapError(MedusaError.fromError)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }

    isUsernameAvailable: { username in
        return Effect(value: true)
//        var request = URLRequest(url: URL(string: "http://localhost:8989/check-username/\(username)")!,
//                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
//                                 timeoutInterval: 15.0)
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .map {data, _ in data}
//            .decode(type: MedusaBoolResult.self, decoder: JSONDecoder())
//            .map {wrapped in
//                return !wrapped.result
//            }
//            .mapError(MedusaError.fromError)
//            .receive(on: DispatchQueue.main)
//            .eraseToEffect()
    }

    createPost: {post in
        var request = URLRequest(url: URL(string: "http://localhost:8989/users/\(String(describing: post.userId))/posts")!,
                                 cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                                 timeoutInterval: 15.0)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(post)

        return URLSession.shared.dataTaskPublisher(for: request)
            .map {data, _ in data}
            .decode(type: Post.self, decoder: JSONDecoder())
            .mapError(MedusaError.fromError)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }
}
