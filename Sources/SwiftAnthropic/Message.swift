/// A minimal implementation of ``ContentfulMessage``
/// 
/// Use this struct to send messages to Anthropic's models.
/// ```swift
/// let message = Message("Hello, Claude!")
/// let response = anthropic.sendRequest(messages: [message])
/// 
/// // Hello! How can I assist you today?
/// print(response.content)
public struct Message: ContentfulMessage {
    /// Create a `Message` with the given information.
    /// 
    /// - Parameters:
    ///   - content: The content of the message.
    ///   - role: Who sent the message.
    public init(_ content: String, role: Role = .user) {
        self.content = content
        self.role = role
    }

    public let content: String
    public let role: Role
}
