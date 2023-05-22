public struct Repository: Decodable, Equatable {
    public let id: Int64
    public let name: String
    public let description: String
    public let owner: User

    public init(
        id: Int64,
        name: String,
        description: String,
        owner: User
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.owner = owner
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case owner
    }
}

public extension Repository {

    static func mock(
        id: Int64 = 123,
        name: String = "mock-repo",
        description: String = "mock repository",
        owner: User = .mock()
    ) -> Repository {
        .init(id: id, name: name, description: description, owner: owner)
    }
}

