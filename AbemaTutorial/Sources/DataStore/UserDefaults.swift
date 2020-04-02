import Foundation

protocol UserDefaultsType {
    func get<T: Decodable>(key: UserDefaultsKey, of type: T.Type) throws -> T
    func set<T: Encodable>(key: UserDefaultsKey, newValue: T)
}

extension UserDefaults: UserDefaultsType {
    func get<T: Decodable>(key: UserDefaultsKey, of type: T.Type) throws -> T {
        guard let value = self.data(forKey: key.rawValue) else {
            throw UserDefaultsError.notFoundError
        }

        return try JSONDecoder().decode(T.self, from: value)
    }

    func set<T: Encodable>(key: UserDefaultsKey, newValue: T) {
        let data = try? JSONEncoder().encode(newValue)
        self.set(data, forKey: key.rawValue)
    }
}
