class CreateNotifications < ActiveRecord::Migration[7.0]
  # Уведомление адресовано ПЕРСОНАЛЬНО пользователю (users), а не устройству:
  # один человек может сидеть в вебе и на планшете, и подтвердить уведомление
  # должен один раз. Поэтому строка на получателя, а не на событие.
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.text :body
      t.bigint :technology_id
      t.bigint :country_id
      t.jsonb :payload, default: {}, null: false
      # nil — мастер ещё не нажал «Ок»; уведомление висит на всех его устройствах
      t.datetime :acknowledged_at

      t.timestamps
    end

    add_index :notifications, [:user_id, :acknowledged_at]
    add_index :notifications, :kind
  end
end
