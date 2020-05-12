struct User: Decodable, Equatable {
    let id: Int64
    let login: String

    enum CodingKeys: String, CodingKey {
        case id
        case login
    }
}
