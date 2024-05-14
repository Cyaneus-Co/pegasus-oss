import SwiftUI

struct UserProfile: Equatable, Identifiable {
    let id = UUID()
    let account: Account
    let avatar: UIImage
}

extension UserProfile {
    static let System =
    UserProfile(account: Account(
        firstName: "Offical",
        lastName: "System Account",
        email: "system@system.com",
        phone: "212-555-1274",
        username: "Offical_System_Account",
        password: "123dk556789"),
        avatar: UIImage(named: "PegasusAvatar")!)
    
    static let Poseidon =
    UserProfile(account: Account(
        firstName: "Poseidon",
        lastName: "O'Lympia",
        email: "neptune@yahoo.com",
        phone: "212-555-1212",
        username: "TheRealGodOfTheSea",
        password: "1234556789"),
        avatar: UIImage(named: "PoseidonAvatar")!)
    
    static let Chrysaor =
    UserProfile(account: Account(
        firstName: "Chrysaor",
        lastName: "O'Lympia",
        email: "medusawasframed@yahoo.com",
        phone: "212-555-1212",
        username: "whenpigsfly",
        password: "1234556789"),
        avatar: UIImage(named: "ChrysaorAvatar")!)
    
    static let Pegasus =
    UserProfile(account: Account(
        firstName: "Pegasus",
        lastName: "O'Lympia",
        email: "medusawasframed@yahoo.com",
        phone: "212-555-1212",
        username: "rainbowbreath",
        password: "1234556789"),
        avatar: UIImage(named: "PegasusAvatar")!)
    
    static let Medusa = UserProfile(account: Account(
        firstName: "Medusa",
        lastName: "O'Lympia",
        email: "medusawasframed@yahoo.com",
        phone: "212-555-1212",
        username: "deadlocks",
        password: "1234556789"),
        avatar: UIImage(named: "MedusaAvatar")!)
    
    static let StressTestUser = UserProfile(account: Account(

        firstName: "Stress",
        lastName: "Test",
        email: "stressesout@yahoo.com",
        phone: "212-355-1412",
        username: "WWWWWWWWWWWWWW",
        password: "1234556789"),
        avatar: UIImage(named: "MedusaAvatar")!)
}

extension UserProfile {
    static func randomSystemUser() -> UserProfile {
        return [.Medusa, .Poseidon, .Chrysaor, .Pegasus, .System].randomElement()!
    }
}

