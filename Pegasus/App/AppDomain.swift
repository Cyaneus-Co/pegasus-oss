import ComposableArchitecture
import Combine

class UserStore: ObservableObject {
    static let shared = UserStore()
    @Published private(set) var currentUser : Account?
    @Published private(set) var isLoggedIn = false

    func successfulLogin(_ user: Account) {
        currentUser = user
        isLoggedIn = true
    }
}
