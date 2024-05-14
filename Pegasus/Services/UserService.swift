

//
// API :
// static : UserService.getSignedInUser() -> UserProfile?
//          UserService.isSignedIn() -> return getLIU() != nil
//          UserService.signOut()
//
//
//

struct UserService {
    var currentUser: UserProfile?

    func signedInUser() -> UserProfile? {
        return currentUser
    }

    func isSignedIn() -> Bool {
        return currentUser != nil
    }

    mutating func signOut() -> Void {
        self.currentUser = nil
    }

    mutating func setSignedIn(user: UserProfile) {
        self.currentUser = user
    }
}

// static API i.e., UserService.instance.isSignedIn()
extension UserService {
    static var instance = UserService()
}
