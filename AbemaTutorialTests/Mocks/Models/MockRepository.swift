@testable import AbemaTutorial

extension Repository {
    static func mock(id: Int64 = 0) -> Repository {
        return Repository(id: id,
                          name: "mock-repo",
                          description: "mock repository",
                          owner: .mock())
    }
}
