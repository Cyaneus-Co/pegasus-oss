import SwiftUI

struct Person : Codable, Identifiable {
    var id: String
    var first_name: String
    var last_name: String
    var birthday: Date
    var email: String
    var phone: String
    var username: String?
    var key: String

    init(id: String, first_name: String, last_name: String, birthday: Date, email: String, phone: String, username: String ) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.birthday = birthday
        self.email = email
        self.phone = phone
        self.username = username
        self.key = UUID().uuidString
    }

    func getAge() -> DateComponents {
        let now = Date()
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: self.birthday, to: now)
        return ageComponents
    }

    func getTimeTilBirthday() -> DateComponents {
        let now = Date()
        let calendar = Calendar.current
        var thisYearsBirthday = DateComponents()
        thisYearsBirthday.month = calendar.component(.month, from:self.birthday)
        thisYearsBirthday.day = calendar.component(.day, from:self.birthday)
        thisYearsBirthday.year = calendar.component(.year, from: now)

        let birthdayThisYear: Date = calendar.date(from:thisYearsBirthday)!
        if birthdayThisYear < now {
            thisYearsBirthday.year = thisYearsBirthday.year! + 1
        }

        return calendar.dateComponents([.year, .month, .day], from: now, to: calendar.date(from:thisYearsBirthday)!)
    }

    func serialize() -> [String : Any] {
        return [
            "id": id,
            "first_name": first_name,
            "last_name": last_name,
            "birthday": birthday,
            "email": email,
            "phone": phone,
            "username": username
        ]
    }
}
