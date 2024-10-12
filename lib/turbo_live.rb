# frozen_string_literal: true

require_relative "turbo_live/version"
require_relative "turbo_live/component"
require_relative "turbo_live/renderer"

require_relative "turbo_live/engine" if defined?(Rails)
require_relative "../app/channels/components_channel" if defined?(ActionCable)

module TurboLive
  class Error < StandardError; end

  class << self
    attr_writer :verifier_key

    def verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(verifier_key, digest: "SHA256", serializer: YAML)
    end

    def verifier_key
      @verifier_key or raise ArgumentError, "Turbo requires a verifier_key"
    end
  end
end