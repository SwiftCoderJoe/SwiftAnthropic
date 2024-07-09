/// A generated message from an AI model.
/// 
/// Because it inherits from ``ContentfulMessage``, this structure can also be used directly in lists of messages passed to a model.
public struct Response: ContentfulMessage, Decodable, Equatable {
    /// An ID for the response, assigned by Anthropic.
    public let id: String

    /// The content of the response.
    /// 
    ///  The current model does not support tools at all and only respects a single content block with text content
    public let content: String

    /// Who sent the message.
    /// 
    /// In a response, `role` is always ``Role/assistant``
    public let role: Role

    /// The model that generated the response.
    public let model: Model

    /// The reason the model stopped generation.
    public let stopReason: StopReason

    /// Usage information about this request.
    public let usage: Usage

    /// The reason a model stopped generating.
    /// 
    /// Depending on the request, a model can stop generating for a number of reasons.
    public enum StopReason: Decodable, Equatable {
        /// The model reached a natural stopping point.
        case endTurn

        /// The model exceeded the requested `maxTokens` or the model's maximum.
        case maxTokens

        /// One of the provided custom stopSequences was generated.
        case stopSequence(String)

        /// The model invoked one or more tools.
        case toolUse

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let internalName = try container.decode(String.self, forKey: .stopReason)
            switch internalName {
            case "end_turn":
                self = .endTurn
            case "max_tokens":
                self = .maxTokens
            case "stop_sequence":
                let stopSequence = try container.decode(String.self, forKey: .stopSequence)
                self = .stopSequence(stopSequence)
            case "tool_use":
                self = .toolUse
            default:
                fatalError("API gave unknown stop reason.")
            }
        }

        private enum CodingKeys: String, CodingKey {
            case stopReason = "stop_reason"
            case stopSequence = "stop_sequence"
        }
    }

    /// Information about the cost and token use of a request.
    public struct Usage: Decodable, Equatable {
        /// The number of input tokens used for this request.
        let inputTokens: Int
        /// The number of output tokens used for this request.
        let outputTokens: Int

        private enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case content
        case role
        case model
        case stopReason = "stop_reason"
        case usage
    }

    private struct ContentBlock: Decodable {
        let type: String
        let text: String
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        var contentBlockContainer = try container.nestedUnkeyedContainer(forKey: .content)
        let contentBlock = try contentBlockContainer.decode(ContentBlock.self)
        guard contentBlock.type == "text" else { fatalError("Tools are not supported.") }
        content = contentBlock.text
        role = try container.decode(Role.self, forKey: .role)

        model = try container.decode(Model.self, forKey: .model)
        stopReason = try decoder.singleValueContainer().decode(StopReason.self)

        usage = try container.decode(Usage.self, forKey: .usage)
    }
}

/// For testing use only.
extension Response {
    /// A manual way to generate a Response.
    /// 
    /// For testing use only.
    init(
        id: String,
        content: String,
        role: Role,
        model: Model,
        stopReason: Response.StopReason,
        usage: Response.Usage
    ) {
        self.id = id
        self.content = content
        self.role = role
        self.model = model
        self.stopReason = stopReason
        self.usage = usage
    }
}
