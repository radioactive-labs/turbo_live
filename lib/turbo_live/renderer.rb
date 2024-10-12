# frozen_string_literal: true

module TurboLive
  class Renderer
    class << self
      def render(data)
        data = data.symbolize_keys
        # build the payload
        payload = extract_payload(data)
        # create the component
        component = build_component(data)
        # run the update function
        component.update payload
        # render the replace stream
        <<~STREAM
          <turbo-stream action="replace" target="#{data[:id]}">
            <template>
              #{component.call}
            </template>
          </turbo-stream>
        STREAM
      end

      private

      def extract_payload(data)
        payload_event = from_verifiable(data[:payload][0])
        if data[:payload].size == 2
          [payload_event, data[:payload][1]]
        else
          [payload_event]
        end
      end

      def build_component(data)
        component_data = from_verifiable(data[:component])
        component_klass = component_data[:klass].safe_constantize
        # Ensure we have a correct class
        unless component_klass.is_a?(Class) && component_klass < Component
          raise ArgumentError, "[IMPORTANT!!!] Unexpected class: #{component_klass}"
        end

        component = component_klass.new(**component_data[:state])
        # rudimentary checksum to ensure id matches
        raise ArgumentError, "component ID mismatch" unless component.live_id == from_verifiable(data[:id])

        component
      end

      def from_verifiable(verifiable)
        TurboLive.verifier.verified verifiable
      end
    end
  end
end
