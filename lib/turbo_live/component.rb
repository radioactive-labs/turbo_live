# frozen_string_literal: true

require "phlex"
require "literal"

module TurboLive
  class Component < Phlex::HTML
    extend Literal::Properties

    SUPPORTED_EVENTS = %i[click change input].freeze

    def self.state(name, type, **options, &block)
      options = {reader: :public, writer: :protected}.merge(**options).compact
      prop(name, _Nilable(type), **options, &block)
    end

    state :live_id, String, writer: nil do |value|
      value || SecureRandom.hex
    end

    def view_template
      div(
        id: verifiable_live_id,
        style: "display: contents;",
        data_controller: "turbo-live",
        data_turbo_live_component_value: to_verifiable(serialize)
      ) do
        view
      end
    end

    def update(input)
    end

    def verifiable_live_id
      to_verifiable(live_id)
    end

    protected

    def on(**mappings)
      actions = []
      params = []
      mappings.each do |event, param|
        raise NotImplementedError, "TurboLive does not support '#{event}' events" unless SUPPORTED_EVENTS.include?(event)

        actions << "#{event}->turbo-live#on#{event.capitalize}"
        params << [:"data_turbo_live_#{event}_param", to_verifiable(param)]
      end

      data_action = actions.join(" ")
      params.to_h.merge(data_action: data_action)
    end

    def every(milliseconds, event)
      data = {interval: milliseconds, event: to_verifiable(event)}.to_json
      add_meta :interval, data
    end

    def norender
      SKIP_RENDER
    end

    def norender!
      raise SkipRender
    end

    private

    def add_meta(type, value)
      # TODO: turbo morph does some wonky things issues here since it doesn't force a replacement everytime
      div(
        data_turbo_live_meta_type: type,
        data_turbo_live_meta_value: value,
        data_turbo_live_target: "meta",
        style: "display: none;", display: :none
      ) {}
    end

    def serialize
      state = self.class.literal_properties.map do |prop|
        [prop.name, public_send(prop.name)]
      end.to_h

      {klass: self.class.to_s, state: state}
    end

    def to_verifiable(value)
      TurboLive.verifier.generate value
    end
  end
end
