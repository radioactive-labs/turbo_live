# frozen_string_literal: true

module TurboLive
  class Serializer
    class << self
      attr_writer :permitted_classes

      def dump(obj)
        YAML.dump(obj)
      end

      def load(obj)
        YAML.safe_load(obj, permitted_classes: permitted_classes)
      end

      def permitted_classes
        @permitted_classes ||= []
      end
    end
  end
end
