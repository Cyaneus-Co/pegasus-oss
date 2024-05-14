struct Account: Codable, Equatable {
    static let TestAccount = Account(firstName: "test", lastName: "account", email: "test@example.com", phone: "212-555-1212", username: "test.account", password: "*******")
    internal init(firstName: String, lastName: String, email: String, phone: String, username: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.username = username
        self.password = password
        self.id = nil
    }
    let id: Int?
    let firstName, lastName, email, phone, username, password: String
}
extension Account {
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
