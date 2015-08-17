# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150807103939) do

  create_table "advertisements", force: :cascade do |t|
    t.integer  "service_category_id"
    t.string   "service_category_name"
    t.string   "name"
    t.string   "url"
    t.boolean  "status",                default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "image"
  end

  add_index "advertisements", ["service_category_id"], name: "index_advertisements_on_service_category_id"

  create_table "app_users", force: :cascade do |t|
    t.string   "first_name",             default: "",   null: false
    t.string   "last_name",              default: "",   null: false
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "address"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "gcm_registration_id"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.boolean  "active",                 default: true
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
  end

  add_index "app_users", ["email"], name: "index_app_users_on_email", unique: true
  add_index "app_users", ["reset_password_token"], name: "index_app_users_on_reset_password_token", unique: true

  create_table "comments", force: :cascade do |t|
    t.integer  "app_user_id"
    t.integer  "deal_id"
    t.boolean  "status",       default: true
    t.text     "comment_text"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "comments", ["app_user_id"], name: "index_comments_on_app_user_id"
  add_index "comments", ["deal_id"], name: "index_comments_on_deal_id"

  create_table "deals", force: :cascade do |t|
    t.integer  "service_category_id"
    t.integer  "service_provider_id"
    t.string   "service_category_name"
    t.string   "service_provider_name"
    t.string   "title"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.text     "short_description"
    t.text     "detail_description"
    t.float    "price"
    t.string   "url"
    t.text     "you_save_text"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_active",             default: true
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "image"
  end

  add_index "deals", ["service_category_id"], name: "index_deals_on_service_category_id"
  add_index "deals", ["service_provider_id"], name: "index_deals_on_service_provider_id"

  create_table "notifications", force: :cascade do |t|
    t.integer  "app_user_id"
    t.boolean  "recieve_notification"
    t.integer  "day"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "notifications", ["app_user_id"], name: "index_notifications_on_app_user_id"

  create_table "push_notifications", force: :cascade do |t|
    t.integer  "app_user_id"
    t.text     "message"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "push_notifications", ["app_user_id"], name: "index_push_notifications_on_app_user_id"

  create_table "ratings", force: :cascade do |t|
    t.integer  "app_user_id"
    t.integer  "deal_id"
    t.float    "rating_point"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "ratings", ["app_user_id"], name: "index_ratings_on_app_user_id"
  add_index "ratings", ["deal_id"], name: "index_ratings_on_deal_id"

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_categories", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "service_preferences", force: :cascade do |t|
    t.integer  "app_user_id"
    t.integer  "service_category_id"
    t.integer  "service_provider_id"
    t.string   "service_category_name"
    t.string   "service_provider_name"
    t.datetime "contract_date"
    t.boolean  "is_contract"
    t.float    "contract_fee"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "service_preferences", ["app_user_id"], name: "index_service_preferences_on_app_user_id"
  add_index "service_preferences", ["service_category_id"], name: "index_service_preferences_on_service_category_id"
  add_index "service_preferences", ["service_provider_id"], name: "index_service_preferences_on_service_provider_id"

  create_table "service_providers", force: :cascade do |t|
    t.string   "name"
    t.integer  "service_category_id"
    t.string   "service_category_name"
    t.string   "address"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "email"
    t.string   "telephone"
    t.boolean  "is_preferred",          default: false
    t.boolean  "is_active",             default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "logo"
  end

  add_index "service_providers", ["service_category_id"], name: "index_service_providers_on_service_category_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",                   default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "role"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "enabled"
    t.integer  "failed_count"
    t.datetime "password_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
