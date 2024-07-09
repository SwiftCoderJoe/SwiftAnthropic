/// An Anthropic model.
/// 
/// See all of Anthropic's models [here](https://docs.anthropic.com/en/docs/about-claude/models).
public enum Model: String, Codable {
    /// [Claude 3 Opus](https://docs.anthropic.com/en/docs/about-claude/models#model-comparison), a high-performance, high-cost model.
    case claude3Opus = "claude-3-opus-20240229"

    /// [Claude 3 Sonnet](https://docs.anthropic.com/en/docs/about-claude/models#model-comparison), a medium-performance, medium-cost model.
    /// 
    /// This model has been superseded by Claude 3.5 Sonnet.
    case claude3Sonnet = "claude-3-sonnet-20240229"

    /// [Claude 3 Haiku](https://docs.anthropic.com/en/docs/about-claude/models#model-comparison), a lower-performance, low-cost model.
    case claude3Haiku = "claude-3-haiku-20240307"

    /// [Claude 3.5 Sonnet](https://docs.anthropic.com/en/docs/about-claude/models#model-comparison), a high-performance, medium-cost model.
    case claude3_5Sonnet = "claude-3-5-sonnet-20240620"
}
