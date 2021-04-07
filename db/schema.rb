# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210407065510) do

  create_table "asset_missions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.integer "measurement_interval"
    t.integer "measurement_duration"
    t.text "comments"
    t.boolean "battery_replaced"
    t.bigint "user_id"
    t.bigint "mission_id"
    t.bigint "asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "extracted_at"
    t.datetime "placed_at"
    t.integer "position_x"
    t.integer "position_y"
    t.integer "position_z"
    t.string "img"
    t.index ["asset_id"], name: "index_asset_missions_on_asset_id"
    t.index ["mission_id"], name: "index_asset_missions_on_mission_id"
    t.index ["user_id"], name: "index_asset_missions_on_user_id"
  end

  create_table "asset_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.text "description"
    t.text "product_serial"
    t.integer "battery_life"
    t.bigint "user_id"
    t.datetime "date_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "asset_type_id"
    t.boolean "deleted", default: false
    t.boolean "battery_out", default: false
    t.index ["asset_type_id"], name: "index_assets_on_asset_type_id"
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "battery_replacements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.bigint "user_id"
    t.bigint "asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_battery_replacements_on_asset_id"
    t.index ["user_id"], name: "index_battery_replacements_on_user_id"
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "name"
    t.string "attachment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "purpose"
    t.string "parent_id"
    t.string "file_type"
  end

  create_table "missions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "project_name"
    t.text "description"
    t.datetime "starting_date"
    t.datetime "ending_date"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.index ["user_id"], name: "index_missions_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci" do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "mail"
    t.string "password"
    t.string "token"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
  end

end
