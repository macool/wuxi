module Brain
  class ExternalAnalysisDecorator < ::ApplicationDecorator
    BITEXT_SCORES = {
      "-1" => "N-",
      "0" => "NEU",
      "+1" => "P+"
    }.freeze
    SENTIMENT140_SCORES = {
      "0" => "N-",
      "2" => "NEU",
      "4" => "P+"
    }.freeze

    def score_str
      case provider
      when "sentiment140"
        SENTIMENT140_SCORES.fetch(response["polarity"].to_s)
      when "meaningcloud"
        response["score_tag"]
      when "bitext"
        bitext_avg_score(response["sentimentanalysis"])
      else
        fail "define score for #{provider}"
      end
    end

    private

    def bitext_avg_score(sentimentanalysis)
      scores = sentimentanalysis.map do |analysis|
        analysis["score"].to_f
      end
      avg_score = scores.sum / scores.length
      if avg_score == 0
        BITEXT_SCORES.fetch("0")
      elsif avg_score > 0
        BITEXT_SCORES.fetch("+1")
      else
        BITEXT_SCORES.fetch("-1")
      end
    end
  end
end
