import XCTest
@testable import SwiftAnthropic

final private class SwiftAnthropicTests: XCTestCase {
    func testRealAPIExpensive() async throws {
        let anthropic = Anthropic(apiKey: "Your API key Here")
        let message = Request(
            model: .claude3_5Sonnet,
            messages: [Message("Hello!")],
            maxTokens: 64
        )
        let response = try await anthropic.send(request: message)

        dump(response)

        XCTAssertNotNil(response)
    }
    func testDecoding() throws {
        let swiftResponse = Response(
            id: "msg_01DjMHzuj6fP1jb5D2uWcqWz",
            content: "Hello! How can I assist you today? Feel free to ask me any questions or let me know if you need help with anything.",
            role: .assistant,
            model: .claude3_5Sonnet,
            stopReason: .endTurn,
            usage: Response.Usage(inputTokens: 9, outputTokens: 30))
        let recievedJSON = """
            {
                "id": "msg_01DjMHzuj6fP1jb5D2uWcqWz",
                "type": "message",
                "role": "assistant",
                "model": "claude-3-5-sonnet-20240620",
                "content": [
                    {
                        "type": "text",
                        "text": "Hello! How can I assist you today? Feel free to ask me any questions or let me know if you need help with anything."
                    }
                ],
                "stop_reason": "end_turn",
                "stop_sequence": null,
                "usage": {
                    "input_tokens": 9,
                    "output_tokens": 30
                }
            }
            """
        let decodedResponse = try JSONDecoder().decode(Response.self, from: recievedJSON.data(using: .utf8)!)
        XCTAssertEqual(decodedResponse, swiftResponse)
    }
}
