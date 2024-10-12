# frozen_string_literal: true

module TurboLive
  class ComponentsChannel < ActionCable::Channel::Base
    def subscribed
      stream_from stream_name
    end

    def receive(params)
      stream = Renderer.render params
      ActionCable.server.broadcast(stream_name, stream)
    end

    protected

    def stream_name
      @stream_name ||= "turbo_live-#{SecureRandom.hex}"
    end
  end
end
