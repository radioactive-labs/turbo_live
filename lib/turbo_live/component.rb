# frozen_string_literal: true

require "phlex"
require "literal"

module TurboLive
  class Component < Phlex::HTML
    extend Literal::Properties

    SUPPORTED_EVENTS = %i[click change].freeze

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
      data = {milliseconds => to_verifiable(event)}.to_json
      add_data :every, data
    end

    def norender!
      raise SkipRender
    end

    def norender
      SKIP_RENDER
    end

    private

    def add_data(type, value)
      # Temporary hack to embed data.
      # Switch to HTML templates when we move to Phlex 2.
      div(
        class: "turbo-live-data",
        data_turbo_live_id: verifiable_live_id,
        data_turbo_live_data_type: type,
        data_turbo_live_data_value: value,
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
