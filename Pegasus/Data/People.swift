import Foundation

struct People {
    static let everyone: [Person] = [
        Person(id: "0", first_name: "Test", last_name: "User", birthday: Formatting.asDate(d: "1/1/2000")!, email: "test.user@example.org", phone: "212-555-1212", username:"testusername"),
        Person(id: "1", first_name: "Jasper", last_name: "Mayone", birthday: Formatting.asDate(d: "8/5/2006")!, email: "test.user@example.org", phone: "802-279-3128", username: "JasperMayone" ),
        Person(id: "2", first_name: "Stella", last_name: "Mayone", birthday: Formatting.asDate(d: "2/3/2008")!, email: "test.user@example.org", phone: "212-555-1212", username: "StellaMayone" ),
        Person(id: "3", first_name: "Matt", last_name: "McManus", birthday: Formatting.asDate(d: "11/21/1977")!, email: "test.user@example.org", phone: "212-555-1212", username: "MattMcManus"),
        Person(id: "4", first_name: "Jill", last_name: "McManus", birthday: Formatting.asDate(d: "3/25/1977")!, email: "test.user@example.org", phone: "212-555-1212", username: "JillMcManus"),
        Person(id: "5", first_name: "Hudson", last_name: "Lincoln", birthday: Formatting.asDate(d: "10/4/2015")!, email: "test.user@example.org", phone: "212-555-1212", username: "HudsonLincoln")
    ]

    static let noone: [Person] = []

    static let TestPerson: Person = everyone[0]
    static let Jasper: Person = everyone[1]
    static let Stella: Person = everyone[2]
    static let Matt: Person = everyone[3]
    static let Jill: Person = everyone[4]
    static let Hudson: Person = everyone[5]
}
