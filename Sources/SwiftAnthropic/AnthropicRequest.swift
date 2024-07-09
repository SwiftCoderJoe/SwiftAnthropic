public struct Request: Encodable {
    public init(
        model: Model,
        messages: [any ContentfulMessage],
        maxTokens: Int,
        metadata: Metadata? = nil,
        stopSequences: [String] = [],
        stream: Bool = false,
        system: String = "",
        temperature: Double = 1.0,
        // toolChoice: Something? = nil,
        // tools: [Tool]? = []
        topK: Int? = nil,
        topP: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.maxTokens = maxTokens
        self.metadata = metadata
        self.stopSequences = stopSequences
        self.stream = stream
        self.system = system
        self.temperature = temperature
        // self.toolChoice = toolChoice
        // self.tools = tools
        self.topK = topK
        self.topP = topP
    }

    let model: Model
    let messages: [any ContentfulMessage]
    let maxTokens: Int
    let metadata: Metadata?
    let stopSequences: [String]
    let stream: Bool
    let system: String
    let temperature: Double
    // let toolChoice: Something?
    // let tools: [Tool]?
    let topK: Int?
    let topP: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case metadata = "metadata"
        case stopSequences = "stop_sequences"
        case stream
        case system
        case temperature
        // case toolChoice = "tool_choice"
        // case tools
        case topK = "top_k"
        case topP = "top_p"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(model, forKey: .model)
        // Messages handled below.
        try container.encode(maxTokens, forKey: .maxTokens)
        if let metadata {
            try container.encode(metadata, forKey: .metadata)
        }
        try container.encode(stopSequences, forKey: .stopSequences)
        try container.encode(stream, forKey: .stream)
        try container.encode(system, forKey: .system)
        try container.encode(temperature, forKey: .temperature)
        if let topK {
            try container.encode(topK, forKey: .topK)
        }
        if let topP {
            try container.encode(topP, forKey: .topP)
        }

        // Include the list of messages
        var messagesContainer = container.nestedUnkeyedContainer(forKey: .messages)
        for message in messages {
            var messageContainer = messagesContainer.nestedContainer(keyedBy: ContentfulMessageCodingKeys.self)
            try messageContainer.encode(message.content, forKey: .content)
            try messageContainer.encode(message.role, forKey: .role)
        }

    }
}