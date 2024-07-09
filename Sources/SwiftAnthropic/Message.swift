public struct Message: ContentfulMessage {
    public init(_ content: String, role: Role = .user) {
        self.content = content
        self.role = role
    }

    public let content: String
    public let role: Role
}