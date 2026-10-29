class UpdateSermonPublicOrderText < ActiveRecord::Migration[7.0]
  # Карточка Митрополита «Проповедь»: код (`PoliticalAction#sermon`) повышает
  # общественный порядок региона на 10, а в записи типа действия оставалось 5.
  # Правка сида (`db/seeds/pat_nobles.csv`) на живой базе не применяется — сиды
  # повторно не грузятся, поэтому текст правится миграцией.
  #
  # Действие движка vassals_and_robbers называется `sermon_vassals` (там 5 и в
  # тексте, и в коде) — его эта миграция не трогает.
  OLD_TEXT = 'повышается на 5 пунктов'.freeze
  NEW_TEXT = 'повышается на 10 пунктов'.freeze

  def up
    update_text(OLD_TEXT, NEW_TEXT)
  end

  def down
    update_text(NEW_TEXT, OLD_TEXT)
  end

  private

  def update_text(from, to)
    execute(
      ActiveRecord::Base.sanitize_sql_array([
        "UPDATE political_action_types " \
        "SET success = replace(success, ?, ?), updated_at = NOW() " \
        "WHERE action = 'sermon' AND success LIKE ?",
        from, to, "%#{from}%"
      ])
    )
  end
end
