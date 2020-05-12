@testable import AbemaTutorial

extension Repository {
    static func mock() -> Repository {
        return Repository(id: 123,
                          name: "mock-repo",
                          description: "mock repository",
                          owner: .mock())
    }
}
