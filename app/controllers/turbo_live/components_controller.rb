# frozen_string_literal: true

module TurboLive
  class ComponentsController < ActionController::API
    def update
      stream = Renderer.render params.to_unsafe_hash
      render plain: stream
    end
  end
end
