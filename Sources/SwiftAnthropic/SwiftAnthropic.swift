import AsyncHTTPClient
import Foundation
import NIOCore
import NIOFoundationCompat

/// Documentation needed
@available(macOS 10.15, *)
public class Anthropic {
    private var apiKey: String
    /// When this becomes user-definable, we need to throw an error if v2023_01 is chosen.
    private var apiVersion: AnthropicAPIVersion = .v2023_06

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func sendRequest(
        model: Model = .claude3_5Sonnet, 
        maxTokens: Int = 1024, 
        messages: [any ContentfulMessage],
        metadata: Metadata? = nil,
        stopSequences: [String] = [],
        // stream: Bool? = false
        system: String = "",
        temperature: Double = 1.0,
        // tool_choice: SomeEnum?
        // tools: [AnthropicTool]?
        topK: Int? = nil,
        topP: Int? = nil
    ) async throws -> Response? {
        return try await send(request: Request(
            model: model, 
            messages: messages, 
            maxTokens: maxTokens,
            metadata: metadata,
            stopSequences: stopSequences,
            stream: false,
            system: system,
            temperature: temperature,
            topK: topK,
            topP: topP
        ))
    }

    public func send(request anthropicRequest: Request) async throws -> Response? {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        var httpRequest = HTTPClientRequest(url: "https://api.anthropic.com/v1/messages")
        httpRequest.method = .POST
        httpRequest.headers.add(name: "content-type", value: "application/json")
        httpRequest.headers.add(name: "x-api-key", value: apiKey)
        httpRequest.headers.add(name: "anthropic-version", value: apiVersion.rawValue)
        httpRequest.body = .bytes(try JSONEncoder().encodeAsByteBuffer(anthropicRequest, allocator: ByteBufferAllocator()))

        // debug

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(anthropicRequest)
        print(String(data: data, encoding: .utf8)!)

        // end debug

        let httpResponse = try await httpClient.execute(httpRequest, timeout: .seconds(40))
        print("HTTP head", httpResponse)
        let body = try await httpResponse.body.collect(upTo: 1024 * 1024) // 1 MB
        // we use an overload defined in `NIOFoundationCompat` for `decode(_:from:)` to
        // efficiently decode from a `ByteBuffer`
        try await httpClient.shutdown()
        let anthropicResponse = try JSONDecoder().decode(Response.self, from: body)
        dump(anthropicResponse)
        return anthropicResponse
    }
}