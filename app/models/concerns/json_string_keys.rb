module JsonStringKeys
  extend ActiveSupport::Concern

  included do
    # Override attribute getters to ensure string keys for JSON attributes
    define_method(:read_attribute) do |name|
      value = super(name)
      column = self.class.columns.find { |c| c.name.to_s == name.to_s }
      normalize_json_value(value) if column && [:json, :jsonb].include?(column.type)
      value
    end
  end

  private

  def normalize_json_value(value)
    case value
    when Hash
      value.transform_keys! { |k| k.is_a?(Symbol) ? k.to_s : k }
      value.each_value { |v| normalize_json_value(v) if v.is_a?(Hash) }
    when Array
      value.each { |item| normalize_json_value(item) if item.is_a?(Hash) }
    end
    value
  end
end
