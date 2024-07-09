public protocol ContentfulMessage {
    var content: String { get }
    var role: Role { get }
}

enum ContentfulMessageCodingKeys: String, CodingKey {
    case role, content
}