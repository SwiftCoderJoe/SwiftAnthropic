/// An object describing metadata about a request.
public struct Metadata: Encodable {
    /// An external identifier for the user who is associated with the request.
    /// 
    /// This should be a uuid, hash value, or other opaque identifier. Anthropic may use this id to help detect abuse. 
    /// Do not include any identifying information such as name, email address, or phone number.
    let userID: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}