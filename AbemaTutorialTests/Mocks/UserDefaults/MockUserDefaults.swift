import Foundation

@testable import AbemaTutorial

class MockUserDefaults: UserDefaultsType {
    private var data: [UserDefaultsKey: Any] = [:]

    func get<T>(key: UserDefaultsKey, of type: T.Type) throws -> T where T : Decodable {
        guard let value = data[key] as? T else {
            throw UserDefaultsError.notFoundError
        }

        return value
    }

    func set<T>(key: UserDefaultsKey, newValue: T) where T : Encodable {
        data[key] = newValue
    }
}
