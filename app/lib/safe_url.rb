# frozen_string_literal: true

# Decides whether a metadata value may be used as a url
module SafeUrl
  ALLOWED_SCHEMES = %w[http https].freeze

  def self.permitted?(value)
    scheme = URI.parse(value.to_s.strip).scheme
    ALLOWED_SCHEMES.include?(scheme&.downcase)
  rescue URI::InvalidURIError
    false
  end
end
