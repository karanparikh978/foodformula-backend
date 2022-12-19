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

ActiveRecord::Schema.define(version: 2022_02_05_114658) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.integer "status_id"
    t.integer "sign_in_count"
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "enquiries", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.bigint "mobile_no"
    t.string "city"
    t.integer "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message"
  end

  create_table "entity_images", force: :cascade do |t|
    t.integer "entity_type"
    t.integer "entity_type_id"
    t.string "url"
    t.integer "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "food_item_aliases", force: :cascade do |t|
    t.integer "food_item_id"
    t.integer "language_id"
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "food_item_prices", force: :cascade do |t|
    t.integer "food_item_id"
    t.integer "entity_id"
    t.float "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leads", force: :cascade do |t|
    t.integer "intern_id"
    t.string "restaurant_name"
    t.string "address"
    t.string "manager_name"
    t.bigint "mobile_no"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
  end

  create_table "masters_entities", force: :cascade do |t|
    t.string "name"
    t.string "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masters_food_items", force: :cascade do |t|
    t.string "name"
    t.integer "restaurant_id"
    t.integer "status_id"
    t.integer "category_id"
    t.integer "recipe_type"
    t.integer "total_cooked_weight"
    t.string "serving_description"
    t.integer "per_serving_weight"
    t.string "cooking_info"
    t.string "allergies_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "used_as_ingredient"
    t.string "expiry_date"
    t.string "allergy_ids"
    t.string "meal_type_ids"
    t.string "meal_types_info"
    t.integer "sort_by"
    t.boolean "is_liquid"
    t.boolean "is_jain"
    t.json "nutrition_info"
    t.boolean "best_seller"
  end

  create_table "masters_interns", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.bigint "mobile_no"
    t.string "api_key"
    t.string "pincode"
    t.string "city"
    t.string "state"
    t.integer "gender"
    t.integer "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_masters_interns_on_email", unique: true
    t.index ["reset_password_token"], name: "index_masters_interns_on_reset_password_token", unique: true
  end

  create_table "masters_languages", force: :cascade do |t|
    t.string "name"
    t.integer "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.integer "order_id"
    t.integer "recipe_id"
    t.integer "quantity"
    t.integer "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "name"
    t.bigint "mobile_no"
    t.string "email"
    t.datetime "order_time"
    t.integer "restaurant_id"
    t.integer "status_id"
    t.string "instruction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.integer "total_price"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.integer "recipe_id"
    t.integer "ingredient_id"
    t.string "ingredient_name"
    t.string "serving_unit"
    t.integer "quantity"
    t.integer "total_gm_quantity"
    t.json "nutrition_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurant_categories", force: :cascade do |t|
    t.integer "restaurant_id"
    t.string "name"
    t.integer "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_by"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_restaurants_on_email", unique: true
    t.index ["reset_password_token"], name: "index_restaurants_on_reset_password_token", unique: true
  end

  create_table "user_entities", force: :cascade do |t|
    t.integer "user_id"
    t.integer "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_languages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.integer "status_id"
    t.integer "sign_in_count"
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.string "username"
    t.string "currency"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "enable_access_state"
    t.string "name"
    t.bigint "mobile_no"
    t.string "website"
    t.string "manager_name"
    t.string "qr_code_category"
    t.string "country"
    t.string "tagline"
    t.string "menu_key"
    t.string "restaurant_type"
    t.text "address"
    t.boolean "dining"
    t.boolean "take_away"
    t.integer "country_code"
    t.string "map_link"
    t.integer "visiting_count"
    t.string "state"
    t.string "city"
    t.string "pincode"
    t.integer "tax"
    t.string "description"
    t.integer "default_language_id"
    t.boolean "image_access"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
