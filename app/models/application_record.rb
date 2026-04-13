class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include JsonStringKeys

  # Normalize JSON/JSONB attributes to always use string keys
  before_save :normalize_json_attributes
  before_validation :normalize_json_attributes

  private

  def normalize_json_attributes
    self.class.columns.each do |column|
      next unless [:json, :jsonb].include?(column.type)

      value = read_attribute(column.name)
      if value.is_a?(Hash)
        write_attribute(column.name, normalize_keys(value))
      end
    end
  end

  def normalize_keys(obj)
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), result|
        key = k.is_a?(Symbol) ? k.to_s : k
        result[key] = normalize_keys(v)
      end
    when Array
      obj.map { |item| normalize_keys(item) }
    else
      obj
    end
  end
end
