# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_21_101131) do
  create_table "armies", force: :cascade do |t|
    t.integer "region_id", null: false
    t.integer "player_id", null: false
    t.integer "army_size_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["army_size_id"], name: "index_armies_on_army_size_id"
    t.index ["player_id"], name: "index_armies_on_player_id"
    t.index ["region_id"], name: "index_armies_on_region_id"
  end

  create_table "army_sizes", force: :cascade do |t|
    t.integer "level"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "building_levels", force: :cascade do |t|
    t.integer "level"
    t.json "price"
    t.json "params"
    t.integer "building_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_type_id"], name: "index_building_levels_on_building_type_id"
  end

  create_table "building_places", force: :cascade do |t|
    t.integer "category"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "building_types", force: :cascade do |t|
    t.string "title"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buildings", force: :cascade do |t|
    t.string "comment"
    t.json "params"
    t.integer "building_level_id", null: false
    t.integer "settlement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_level_id"], name: "index_buildings_on_building_level_id"
    t.index ["settlement_id"], name: "index_buildings_on_settlement_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "title"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credits", force: :cascade do |t|
    t.integer "sum"
    t.integer "deposit"
    t.float "procent"
    t.integer "start_year"
    t.integer "duration"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fossil_types", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fossil_types_plant_places", force: :cascade do |t|
    t.integer "fossil_type_id"
    t.integer "plant_place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fossil_type_id"], name: "index_fossil_types_plant_places_on_fossil_type_id"
    t.index ["plant_place_id"], name: "index_fossil_types_plant_places_on_plant_place_id"
  end

  create_table "guilds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "humen", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ideologist_technologies", force: :cascade do |t|
    t.string "title"
    t.json "requirements"
    t.json "params"
    t.integer "ideologist_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ideologist_type_id"], name: "index_ideologist_technologies_on_ideologist_type_id"
  end

  create_table "ideologist_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string "name"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name"
    t.integer "plant_id"
    t.integer "family_id"
    t.integer "guild_id"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plant_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plant_levels", force: :cascade do |t|
    t.integer "level"
    t.integer "deposit"
    t.integer "charge"
    t.json "formula"
    t.json "price"
    t.integer "max_product"
    t.integer "plant_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plant_places", force: :cascade do |t|
    t.string "title"
    t.integer "plant_category_id"
    t.integer "settlement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plant_types", force: :cascade do |t|
    t.string "name"
    t.integer "plant_category_id"
    t.integer "fossil_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plants", force: :cascade do |t|
    t.string "comments"
    t.integer "plant_level_id"
    t.integer "plant_place_id"
    t.integer "economic_subject_id"
    t.string "economic_subject_type"
    t.integer "settlement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_types", force: :cascade do |t|
    t.string "title"
    t.integer "ideologist_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ideologist_type_id"], name: "index_player_types_on_ideologist_type_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "family_id"
    t.integer "guild_id"
    t.integer "player_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "political_action_types", force: :cascade do |t|
    t.string "title"
    t.json "action"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "political_actions", force: :cascade do |t|
    t.integer "year"
    t.integer "success"
    t.json "params"
    t.integer "player_id"
    t.integer "political_action_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_political_actions_on_player_id"
    t.index ["political_action_type_id"], name: "index_political_actions_on_political_action_type_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "title"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settlement_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settlements", force: :cascade do |t|
    t.string "name"
    t.integer "settlement_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "troop_types", force: :cascade do |t|
    t.string "title"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "troops", force: :cascade do |t|
    t.integer "troop_type_id", null: false
    t.boolean "is_hired"
    t.integer "army_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["army_id"], name: "index_troops_on_army_id"
    t.index ["troop_type_id"], name: "index_troops_on_troop_type_id"
  end

  add_foreign_key "armies", "army_sizes"
  add_foreign_key "armies", "players"
  add_foreign_key "armies", "regions"
  add_foreign_key "building_levels", "building_types"
  add_foreign_key "buildings", "building_levels"
  add_foreign_key "buildings", "settlements"
  add_foreign_key "ideologist_technologies", "ideologist_types"
  add_foreign_key "player_types", "ideologist_types"
  add_foreign_key "political_actions", "players"
  add_foreign_key "political_actions", "political_action_types"
  add_foreign_key "troops", "armies"
  add_foreign_key "troops", "troop_types"
end
