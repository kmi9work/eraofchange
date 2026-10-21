# Миграция № 6 ТЗ «несколько команд» (движок vassals_and_robbers):
# у каждого государства свой список вассалов, поэтому сюзерен хранится явно.
# Уникальность переезжает с одиночного vassal_country_id на пару
# (sovereign_country_id, vassal_country_id): одно государство остаётся
# вассалом только одного сюзерена.
class AddSovereignCountryToVassalsAndRobbersChecklists < ActiveRecord::Migration[7.0]
  # «Русь» — государство, которому принадлежали все чек-листы до перехода
  RUS = 1

  def up
    add_column :vassals_and_robbers_checklists, :sovereign_country_id, :integer, null: true
    add_index :vassals_and_robbers_checklists, [:sovereign_country_id, :vassal_country_id],
              unique: true, name: 'index_vnr_checklists_on_sovereign_and_vassal'

    # Сюзерен nullable + бэкфилл «Русь» сразу после миграции: иначе чек-листы
    # остались бы без сюзерена и не попали ни в один список (ТЗ § 15.1 п. 1)
    execute <<~SQL
      UPDATE vassals_and_robbers_checklists
      SET sovereign_country_id = #{RUS}
      WHERE sovereign_country_id IS NULL
    SQL

    # Флаг вассалитета переезжает из плоского ключа vassal_<id>_established
    # в пару params['vassalage'][<сюзерен>][<вассал>]
    execute <<~SQL
      UPDATE vassals_and_robbers_checklists
      SET params = jsonb_set(
            COALESCE(params, '{}'::jsonb),
            '{vassalage,#{RUS}}',
            COALESCE(COALESCE(params, '{}'::jsonb)->'vassalage'->'#{RUS}', '{}'::jsonb)
              || jsonb_build_object(vassal_country_id::text, true)
          )
      WHERE COALESCE(params, '{}'::jsonb)->>('vassal_' || vassal_country_id || '_established') = 'true'
        AND COALESCE(COALESCE(params, '{}'::jsonb)->'vassalage'->'#{RUS}'->>(vassal_country_id::text), '') <> 'true'
    SQL
  end

  def down
    remove_index :vassals_and_robbers_checklists, name: 'index_vnr_checklists_on_sovereign_and_vassal'
    remove_column :vassals_and_robbers_checklists, :sovereign_country_id
  end
end
