// TODO: We should consider making this struct's props public, and putting explanations into those docs
/// A struct to configure a request to an Anthropic model.
/// 
/// `Request` exposes all configuration options offered by Anthropic for their [Message API](https://docs.anthropic.com/en/api/messages).
/// 
/// ## Configuration Options
/// 
/// #### model
/// 
/// The model that will complete your prompt. See [models](https://docs.anthropic.com/en/docs/models-overview) for additional details and options.
/// 
/// #### messages
/// 
/// Input messages.
/// 
/// Anthropic's models are trained to operate on alternating ``Role/user`` and ``Role/assistant`` conversational turns. When generating a response, 
/// you specify the prior conversational turns with the `messages` parameter, and the model then generates the next message in the conversation.
/// 
/// You can specify a single user-role message, or you can include multiple user and assistant messages. The first message must always use the user role.
/// 
/// If the final message uses the ``Role/assistant`` role, the response content will continue immediately from the content in that message. This can be used to constrain part of the model's response.
/// ```swift
/// let response = anthropic.sendRequest(
///     messages: [
///         Message("What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun", role: .user)
///         Message("The best answer is (", role: .assistant)
///     ]
/// )
/// 
/// // B)
/// print(response.content)
/// ```
/// 
/// Note that if you want to include a system prompt, you can use the system parameter — there is no "system" role for input messages.
/// 
/// #### maxTokens
/// 
/// The maximum number of tokens to generate before stopping.
/// 
/// Note that Anthropic's models may stop before reaching this maximum. This parameter only specifies the absolute maximum number of tokens to generate.
/// 
/// Different models have different maximum values for this parameter. See [Anthropic's docs](https://docs.anthropic.com/en/docs/models-overview) for details.
/// 
/// #### metadata
/// 
/// An object describing metadata about the request. Anthropic may use the ID in this object to help detect abuse.
/// 
/// #### stopSequences
/// 
/// Custom text sequences that will cause the model to stop generating.
/// 
/// Anthropic's models will normally stop when they have naturally completed their turn, which will result in a response stopReason of ``Response/StopReason/endTurn``.
/// 
/// If you want the model to stop generating when it encounters custom strings of text, you can use the stopSequences parameter. 
/// If the model encounters one of the custom sequences, the response stopReason value will be ``Response/StopReason/stopSequence(_:)``, containing the matched stop sequence.
/// 
/// #### stream
/// 
/// Streams are not yet supported.
/// 
/// #### system
/// 
/// A system prompt is a way of providing context and instructions to Claude, such as specifying a particular goal or role. 
/// See [Anthropic's guide](https://docs.anthropic.com/en/docs/system-prompts) to system prompts.
/// 
/// #### temperature
/// 
/// Amount of randomness injected into the response. Ranges from `0.0` to `1.0`. 
/// Use temperature closer to `0.0` for analytical / multiple choice, and closer to `1.0` for creative and generative tasks.
/// 
/// Note that even with temperature of `0.0`, the results will not be fully deterministic.
/// 
/// #### tool_choice and tools
/// 
/// Tools are not yet supported.
/// 
/// #### topK
/// 
/// Only sample from the top K options for each subsequent token. Used to remove "long tail" low probability responses. [Learn more technical details here.](https://towardsdatascience.com/how-to-sample-from-language-models-682bceb97277)
/// 
/// Recommended for advanced use cases only. You usually only need to use `temperature`.
/// 
/// #### topP
/// 
/// Use nucleus sampling. In nucleus sampling, Anthropic computes the cumulative distribution over all the options for each subsequent token
/// in decreasing probability order and cut it off once it reaches a particular probability specified by top_p. 
/// You should either alter `temperature` or `top_p`, but not both.
public struct Request: Encodable {
    /// Create a Request object.
    /// 
    /// See ``Request`` for a description of each parameter.
    /// - Parameters:
    ///   - model: The model that will complete your prompt.
    ///   - messages: Input messages.
    ///   - maxTokens: The maximum number of tokens to generate before stopping. 
    ///   - metadata: An object describing metadata about the request.
    ///   - stopSequences: Custom text sequences that will cause the model to stop generating.
    ///   - system: A system prompt: a way of providing context and instructions to Claude, such as specifying a particular goal or role.
    ///   - temperature: Amount of randomness injected into the response, from 0.0 to 1.0.
    ///   - topK: Only sample from the top K options for each subsequent token.
    ///   - topP: Use nucleus sampling.
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
