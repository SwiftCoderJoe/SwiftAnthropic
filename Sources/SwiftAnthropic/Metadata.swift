public struct Metadata: Encodable {
    let userID: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}