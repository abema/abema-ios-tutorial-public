struct Repository: Decodable, Equatable {
    let id: Int64
    let name: String
    let description: String
    let owner: User

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case owner
    }
}
