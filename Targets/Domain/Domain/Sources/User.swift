public struct User: Decodable, Equatable {
    public let id: Int64
    public let login: String

    public init(id: Int64, login: String) {
        self.id = id
        self.login = login
    }

    enum CodingKeys: String, CodingKey {
        case id
        case login
    }
}

public extension User {

    static func mock(
        id: Int64 = 123,
        login: String = "mockowner"
    ) -> User {
        .init(id: id, login: login)
    }
}
