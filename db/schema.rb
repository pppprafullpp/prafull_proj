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

ActiveRecord::Schema.define(version: 20151201051546) do

  create_table "advertisements", force: :cascade do |t|
    t.integer  "service_category_id",   limit: 4
    t.string   "service_category_name", limit: 255
    t.string   "name",                  limit: 255
    t.string   "url",                   limit: 255
    t.boolean  "status",                limit: 1,   default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "image",                 limit: 255
  end

  add_index "advertisements", ["service_category_id"], name: "index_advertisements_on_service_category_id", using: :btree

  create_table "app_users", force: :cascade do |t|
    t.string   "first_name",             limit: 255, default: "",   null: false
    t.string   "last_name",              limit: 255, default: "",   null: false
    t.string   "email",                  limit: 255, default: "",   null: false
    t.string   "encrypted_password",     limit: 255, default: "",   null: false
    t.string   "address",                limit: 255
    t.string   "state",                  limit: 255
    t.string   "city",                   limit: 255
    t.string   "zip",                    limit: 255
    t.string   "gcm_id",                 limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,    null: false
    t.boolean  "active",                 limit: 1,   default: true
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar",                 limit: 255
    t.string   "unhashed_password",      limit: 255
  end

  add_index "app_users", ["email"], name: "index_app_users_on_email", unique: true, using: :btree
  add_index "app_users", ["reset_password_token"], name: "index_app_users_on_reset_password_token", unique: true, using: :btree

  create_table "bundle_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.string   "upload_speed",          limit: 255
    t.string   "download_speed",        limit: 255
    t.string   "data",                  limit: 255
    t.integer  "free_channels",         limit: 4
    t.integer  "premium_channels",      limit: 4
    t.integer  "call_minutes",          limit: 4
    t.integer  "text_messages",         limit: 4
    t.integer  "data_plan",             limit: 4
    t.integer  "data_speed",            limit: 4
    t.boolean  "talk_unlimited",        limit: 1,   default: false
    t.boolean  "text_unlimited",        limit: 1,   default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "bundle_service_preferences", ["service_preference_id"], name: "index_bundle_service_preferences_on_service_preference_id", using: :btree

  create_table "cable_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.integer  "free_channels",         limit: 4
    t.integer  "premium_channels",      limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "cable_service_preferences", ["service_preference_id"], name: "index_cable_service_preferences_on_service_preference_id", using: :btree

  create_table "cellphone_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.integer  "call_minutes",          limit: 4
    t.integer  "text_messages",         limit: 4
    t.integer  "data_plan",             limit: 4
    t.integer  "data_speed",            limit: 4
    t.boolean  "talk_unlimited",        limit: 1, default: false
    t.boolean  "text_unlimited",        limit: 1, default: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "cellphone_service_preferences", ["service_preference_id"], name: "index_cellphone_service_preferences_on_service_preference_id", using: :btree

  create_table "comment_ratings", force: :cascade do |t|
    t.integer  "app_user_id",   limit: 4
    t.integer  "deal_id",       limit: 4
    t.float    "rating_point",  limit: 24
    t.boolean  "status",        limit: 1,     default: true
    t.text     "comment_title", limit: 65535
    t.text     "comment_text",  limit: 65535
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "comment_ratings", ["app_user_id"], name: "index_comment_ratings_on_app_user_id", using: :btree
  add_index "comment_ratings", ["deal_id"], name: "index_comment_ratings_on_deal_id", using: :btree

  create_table "configurables", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurables", ["name"], name: "index_configurables_on_name", using: :btree

  create_table "deals", force: :cascade do |t|
    t.integer  "service_category_id",   limit: 4
    t.integer  "service_provider_id",   limit: 4
    t.string   "service_category_name", limit: 255
    t.string   "service_provider_name", limit: 255
    t.string   "title",                 limit: 255
    t.string   "state",                 limit: 255
    t.string   "city",                  limit: 255
    t.string   "zip",                   limit: 255
    t.text     "short_description",     limit: 65535
    t.text     "detail_description",    limit: 65535
    t.float    "price",                 limit: 24
    t.string   "url",                   limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_active",             limit: 1,     default: true
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "image",                 limit: 255
    t.integer  "free_channels",         limit: 4
    t.integer  "premium_channels",      limit: 4
    t.integer  "call_minutes",          limit: 4
    t.integer  "text_messages",         limit: 4
    t.boolean  "talk_unlimited",        limit: 1
    t.boolean  "text_unlimited",        limit: 1
    t.integer  "data_plan",             limit: 4
    t.integer  "data_speed",            limit: 4
    t.integer  "upload_speed",          limit: 4
    t.integer  "download_speed",        limit: 4
  end

  add_index "deals", ["service_category_id"], name: "index_deals_on_service_category_id", using: :btree
  add_index "deals", ["service_provider_id"], name: "index_deals_on_service_provider_id", using: :btree

  create_table "internet_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.string   "data",                  limit: 255
    t.string   "email",                 limit: 255
    t.string   "online_storage",        limit: 255
    t.string   "wifi_hotspot",          limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "upload_speed",          limit: 4
    t.integer  "download_speed",        limit: 4
  end

  add_index "internet_service_preferences", ["service_preference_id"], name: "index_internet_service_preferences_on_service_preference_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "app_user_id",          limit: 4
    t.boolean  "recieve_notification", limit: 1
    t.integer  "day",                  limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "notifications", ["app_user_id"], name: "index_notifications_on_app_user_id", using: :btree

  create_table "push_notifications", force: :cascade do |t|
    t.integer  "app_user_id", limit: 4
    t.text     "message",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "push_notifications", ["app_user_id"], name: "index_push_notifications_on_app_user_id", using: :btree

  create_table "referral_infos", force: :cascade do |t|
    t.string   "first_referring_identity", limit: 255
    t.string   "referred_user",            limit: 255
    t.string   "event",                    limit: 255
    t.integer  "referring_user_coins",     limit: 4
    t.integer  "referred_user_coins",      limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "service_preferences", force: :cascade do |t|
    t.integer  "app_user_id",           limit: 4
    t.integer  "service_category_id",   limit: 4
    t.integer  "service_provider_id",   limit: 4
    t.string   "service_category_name", limit: 255
    t.string   "service_provider_name", limit: 255
    t.boolean  "is_contract",           limit: 1
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.float    "price",                 limit: 24
    t.string   "plan_name",             limit: 255
  end

  add_index "service_preferences", ["app_user_id"], name: "index_service_preferences_on_app_user_id", using: :btree
  add_index "service_preferences", ["service_category_id"], name: "index_service_preferences_on_service_category_id", using: :btree
  add_index "service_preferences", ["service_provider_id"], name: "index_service_preferences_on_service_provider_id", using: :btree

  create_table "service_providers", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "service_category_id", limit: 4
    t.string   "address",             limit: 255
    t.string   "state",               limit: 255
    t.string   "city",                limit: 255
    t.string   "zip",                 limit: 255
    t.string   "email",               limit: 255
    t.string   "telephone",           limit: 255
    t.boolean  "is_preferred",        limit: 1,   default: false
    t.boolean  "is_active",           limit: 1,   default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "logo",                limit: 255
  end

  add_index "service_providers", ["service_category_id"], name: "index_service_providers_on_service_category_id", using: :btree

  create_table "telephone_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.integer  "call_minutes",          limit: 4
    t.integer  "text_messages",         limit: 4
    t.boolean  "talk_unlimited",        limit: 1, default: false
    t.boolean  "text_unlimited",        limit: 1, default: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "telephone_service_preferences", ["service_preference_id"], name: "index_telephone_service_preferences_on_service_preference_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255, default: "", null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "role",                   limit: 255
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.boolean  "enabled",                limit: 1
    t.integer  "failed_count",           limit: 4
    t.datetime "password_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "advertisements", "service_categories"
  add_foreign_key "bundle_service_preferences", "service_preferences"
  add_foreign_key "cable_service_preferences", "service_preferences"
  add_foreign_key "cellphone_service_preferences", "service_preferences"
  add_foreign_key "comment_ratings", "app_users"
  add_foreign_key "comment_ratings", "deals"
  add_foreign_key "deals", "service_categories"
  add_foreign_key "internet_service_preferences", "service_preferences"
  add_foreign_key "notifications", "app_users"
  add_foreign_key "push_notifications", "app_users"
  add_foreign_key "service_preferences", "app_users"
  add_foreign_key "service_preferences", "service_categories"
  add_foreign_key "service_providers", "service_categories"
  add_foreign_key "telephone_service_preferences", "service_preferences"
end
