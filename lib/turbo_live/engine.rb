# frozen_string_literal: true

module TurboLive
  class Engine < ::Rails::Engine
    isolate_namespace TurboLive

    initializer "turbo_live.verifier_key" do
      config.after_initialize do
        TurboLive.verifier_key = Rails.application.key_generator.generate_key("turbo_live/verifier_key")
      end
    end
  end
end
