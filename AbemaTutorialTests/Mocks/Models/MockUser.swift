@testable import AbemaTutorial

extension User {
    static func mock() -> User {
        return User(id: 123, login: "mockowner")
    }
}
