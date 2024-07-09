/// A message from a user with content.
/// 
/// In cases where you need instances of `ContentfulMessage`, ``Message`` can usually be used. However, because ``Response``
/// conforms to `ContentfulMessage`, you can also use responses directly in your prompts.
/// ```swift
/// let messages: [any ContentfulMessage] = [Message("Hello, Claude!")]
/// messages.append(
///     anthropic.sendRequest(messages: messages)
/// )
/// 
/// // Hello! How can I assist you today?
/// print(messages[1].content)
/// 
/// messages.append(Message("What's 1 + 1?"))
/// 
/// messages.append(
///     anthropic.sendRequest(messages: messages)
/// )
/// 
/// // 1 + 1 = 2
/// print(messages[3].content)
/// ```
public protocol ContentfulMessage {
    /// The content of the message.
    var content: String { get }

    /// Who sent the message.
    var role: Role { get }
}

enum ContentfulMessageCodingKeys: String, CodingKey {
    case role, content
}
