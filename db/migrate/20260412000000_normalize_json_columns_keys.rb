class NormalizeJsonColumnsKeys < ActiveRecord::Migration[7.0]
  def up
    # The ApplicationRecord now ensures all JSON attributes use string keys
    # This migration is here as a marker and for future normalization if needed
    # At application load time, the JsonStringKeys concern will handle normalization

    Rails.logger.info("JSON columns will be normalized on read/write via ApplicationRecord callbacks")
  end

  def down
    # This migration is one-way
  end
end
