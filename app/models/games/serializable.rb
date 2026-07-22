module Games
  # One declared field list drives both as_json and from_json, so a field can't
  # be serialized on save yet silently dropped on reload. POROs mix this in and
  # declare fields with scalar / nested_one / nested_many.
  module Serializable
    extend ActiveSupport::Concern

    included do
      class_attribute :scalar_attrs, default: []
      # name => { class:, collection: true|false }
      class_attribute :nested_attrs, default: {}
    end

    class_methods do
      def scalar(*names) = self.scalar_attrs += names
      def nested_one(name, klass)  = register_nested(name, klass, false)
      def nested_many(name, klass) = register_nested(name, klass, true)

      def register_nested(name, klass, collection)
        self.nested_attrs = nested_attrs.merge(name => { class: klass, collection: collection })
      end

      def from_json(json)
        new(**scalar_values(json), **nested_values(json))
      end

      def scalar_values(json) = scalar_attrs.index_with { |name| json[name.to_s] }

      def nested_values(json)
        nested_attrs.to_h { |name, cfg| [ name, load_nested(cfg, json[name.to_s]) ] }
      end

      def load_nested(cfg, raw)
        return (cfg[:collection] ? [] : nil) if raw.nil?
        return cfg[:class].from_json(raw) unless cfg[:collection]
        raw.map { |item| cfg[:class].from_json(item) }
      end
    end

    def as_json(*)
      scalar_attrs.index_with { |name| send(name) }
        .merge(nested_attrs.to_h { |name, cfg| [ name, dump_nested(send(name), cfg) ] })
        .stringify_keys
    end

    def dump_nested(value, cfg)
      cfg[:collection] ? value.map(&:as_json) : value&.as_json
    end
  end
end
