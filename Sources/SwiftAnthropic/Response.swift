public struct Response: ContentfulMessage, Decodable, Equatable {
    public let id: String

    // The current model does not support tools at all and only respects a single content block with text content
    public let content: String
    public let role: Role

    public let model: Model
    public let stopReason: StopReason

    let usage: Usage

    public enum StopReason: Decodable, Equatable {
        case endTurn, maxTokens, stopSequence(String), toolUse

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

    public struct Usage: Decodable, Equatable {
        let inputTokens: Int
        let outputTokens: Int

        private enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
        }

        internal init(inputTokens: Int, outputTokens: Int) {
            self.inputTokens = inputTokens
            self.outputTokens = outputTokens
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

/// For testing use
extension Response {
    internal init(id: String, content: String, role: Role, model: Model, stopReason: Response.StopReason, usage: Response.Usage) {
        self.id = id
        self.content = content
        self.role = role
        self.model = model
        self.stopReason = stopReason
        self.usage = usage
    }
}