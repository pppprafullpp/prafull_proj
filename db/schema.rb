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

ActiveRecord::Schema.define(version: 20160510133145) do

  create_table "additional_offers", force: :cascade do |t|
    t.integer  "deal_id",       limit: 4
    t.string   "title",         limit: 255
    t.text     "description",   limit: 65535
    t.float    "price",         limit: 24,    default: 0.0,   null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_nationwide",               default: false
    t.boolean  "is_active",                   default: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "additional_offers", ["deal_id"], name: "index_additional_offers_on_deal_id", using: :btree

  create_table "additional_offers_zipcodes", id: false, force: :cascade do |t|
    t.integer "additional_offer_id", limit: 4, null: false
    t.integer "zipcode_id",          limit: 4, null: false
  end

  create_table "advertisements", force: :cascade do |t|
    t.integer  "service_category_id",   limit: 4
    t.string   "service_category_name", limit: 255
    t.string   "name",                  limit: 255
    t.string   "url",                   limit: 255
    t.string   "image",                 limit: 255
    t.boolean  "status",                            default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "advertisements", ["service_category_id"], name: "index_advertisements_on_service_category_id", using: :btree

  create_table "app_users", force: :cascade do |t|
    t.string   "user_type",              limit: 25,  default: "residence", null: false
    t.string   "business_name",          limit: 255, default: "",          null: false
    t.string   "first_name",             limit: 255, default: "",          null: false
    t.string   "last_name",              limit: 255, default: "",          null: false
    t.string   "email",                  limit: 255, default: "",          null: false
    t.string   "encrypted_password",     limit: 255, default: "",          null: false
    t.string   "address",                limit: 255
    t.string   "state",                  limit: 255
    t.string   "city",                   limit: 255
    t.string   "zip",                    limit: 255
    t.string   "gcm_id",                 limit: 255
    t.string   "avatar",                 limit: 255
    t.string   "unhashed_password",      limit: 255
    t.string   "device_flag",            limit: 255
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,           null: false
    t.boolean  "active",                             default: true
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_users", ["email"], name: "index_app_users_on_email", unique: true, using: :btree
  add_index "app_users", ["reset_password_token"], name: "index_app_users_on_reset_password_token", unique: true, using: :btree

  create_table "bulk_notifications", force: :cascade do |t|
    t.string   "state",      limit: 255
    t.string   "city",       limit: 255
    t.string   "zip",        limit: 255
    t.text     "message",    limit: 65535
    t.string   "category",   limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "bundle_deal_attributes", force: :cascade do |t|
    t.integer  "deal_id",                    limit: 4
    t.string   "bundle_combo",               limit: 255
    t.float    "download",                   limit: 24
    t.float    "upload",                     limit: 24
    t.float    "data",                       limit: 24
    t.boolean  "static_ip"
    t.string   "domestic_call_minutes",      limit: 255
    t.string   "international_call_minutes", limit: 255
    t.integer  "free_channels",              limit: 4
    t.text     "free_channels_list",         limit: 65535
    t.integer  "premium_channels",           limit: 4
    t.text     "premium_channels_list",      limit: 65535
    t.integer  "hd_channels",                limit: 4
    t.text     "hd_channels_list",           limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "bundle_equipments", force: :cascade do |t|
    t.integer  "bundle_deal_attribute_id", limit: 4
    t.string   "name",                     limit: 255
    t.string   "make",                     limit: 255
    t.decimal  "price",                                  precision: 30, scale: 2
    t.text     "installation",             limit: 65535
    t.string   "activation",               limit: 255
    t.string   "offer",                    limit: 255
    t.boolean  "is_active"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  create_table "bundle_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id",        limit: 4
    t.float    "upload_speed",                 limit: 24
    t.float    "download_speed",               limit: 24
    t.float    "data",                         limit: 24
    t.integer  "free_channels",                limit: 4
    t.integer  "premium_channels",             limit: 4
    t.integer  "domestic_call_minutes",        limit: 4
    t.integer  "international_call_minutes",   limit: 4
    t.float    "data_plan",                    limit: 24
    t.float    "data_speed",                   limit: 24
    t.boolean  "domestic_call_unlimited",                  default: false
    t.boolean  "international_call_unlimited",             default: false
    t.string   "bundle_combo",                 limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "bundle_service_preferences", ["service_preference_id"], name: "index_bundle_service_preferences_on_service_preference_id", using: :btree

  create_table "cable_deal_attributes", force: :cascade do |t|
    t.integer  "deal_id",               limit: 4
    t.integer  "free_channels",         limit: 4
    t.text     "free_channels_list",    limit: 65535
    t.integer  "premium_channels",      limit: 4
    t.text     "premium_channels_list", limit: 65535
    t.integer  "hd_channels",           limit: 4
    t.text     "hd_channels_list",      limit: 65535
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "cable_deal_attributes", ["deal_id"], name: "index_cable_deal_attributes_on_deal_id", using: :btree

  create_table "cable_equipments", force: :cascade do |t|
    t.integer  "cable_deal_attribute_id", limit: 4
    t.string   "name",                    limit: 255
    t.string   "make",                    limit: 255
    t.decimal  "price",                                 precision: 30, scale: 2
    t.text     "installation",            limit: 65535
    t.string   "activation",              limit: 255
    t.string   "offer",                   limit: 255
    t.boolean  "is_active"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  create_table "cable_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.integer  "free_channels",         limit: 4
    t.integer  "premium_channels",      limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "cable_service_preferences", ["service_preference_id"], name: "index_cable_service_preferences_on_service_preference_id", using: :btree

  create_table "cellphone_deal_attributes", force: :cascade do |t|
    t.integer  "deal_id",                    limit: 4
    t.integer  "no_of_lines",                limit: 4,                           default: 0,     null: false
    t.decimal  "price_per_line",                         precision: 5, scale: 2, default: 0.0,   null: false
    t.string   "domestic_call_minutes",      limit: 255
    t.string   "domestic_text",              limit: 255
    t.string   "international_call_minutes", limit: 255
    t.string   "international_text",         limit: 255
    t.float    "data_plan",                  limit: 24
    t.decimal  "data_plan_price",                        precision: 5, scale: 2, default: 0.0,   null: false
    t.float    "additional_data",            limit: 24
    t.decimal  "additional_data_price",                  precision: 5, scale: 2, default: 0.0,   null: false
    t.boolean  "rollover_data",                                                  default: false
    t.datetime "created_at",                                                                     null: false
    t.datetime "updated_at",                                                                     null: false
  end

  add_index "cellphone_deal_attributes", ["deal_id"], name: "index_cellphone_deal_attributes_on_deal_id", using: :btree

  create_table "cellphone_equipments", force: :cascade do |t|
    t.integer  "cellphone_deal_attribute_id", limit: 4
    t.string   "model",                       limit: 255
    t.string   "make",                        limit: 255
    t.integer  "memory",                      limit: 4
    t.decimal  "price",                                     precision: 30, scale: 2
    t.text     "installation",                limit: 65535
    t.string   "activation",                  limit: 255
    t.string   "offer",                       limit: 255
    t.boolean  "is_active"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  create_table "cellphone_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id",        limit: 4
    t.integer  "domestic_call_minutes",        limit: 4
    t.integer  "international_call_minutes",   limit: 4
    t.float    "data_plan",                    limit: 24
    t.float    "data_speed",                   limit: 24
    t.boolean  "domestic_call_unlimited",                 default: false
    t.boolean  "international_call_unlimited",            default: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "cellphone_service_preferences", ["service_preference_id"], name: "index_cellphone_service_preferences_on_service_preference_id", using: :btree

  create_table "comment_ratings", force: :cascade do |t|
    t.integer  "app_user_id",   limit: 4
    t.integer  "deal_id",       limit: 4
    t.float    "rating_point",  limit: 24
    t.boolean  "status",                      default: true
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
    t.integer  "service_category_id", limit: 4
    t.integer  "service_provider_id", limit: 4
    t.string   "title",               limit: 255
    t.text     "short_description",   limit: 65535
    t.text     "detail_description",  limit: 65535
    t.float    "price",               limit: 24,    default: 0.0,         null: false
    t.string   "url",                 limit: 255
    t.string   "image",               limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "is_nationwide",                     default: false
    t.string   "deal_type",           limit: 100,   default: "residence", null: false
    t.boolean  "is_active",                         default: true
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "deals", ["service_category_id"], name: "index_deals_on_service_category_id", using: :btree
  add_index "deals", ["service_provider_id"], name: "index_deals_on_service_provider_id", using: :btree

  create_table "deals_include_zipcodes", force: :cascade do |t|
    t.integer "deal_id",            limit: 4
    t.integer "include_zipcode_id", limit: 4
  end

  create_table "deals_zipcodes", id: false, force: :cascade do |t|
    t.integer "deal_id",    limit: 4, null: false
    t.integer "zipcode_id", limit: 4, null: false
  end

  create_table "internet_deal_attributes", force: :cascade do |t|
    t.integer  "deal_id",               limit: 4
    t.float    "download",              limit: 24
    t.float    "upload",                limit: 24
    t.float    "data",                  limit: 24
    t.string   "email",                 limit: 255
    t.string   "online_storage",        limit: 255
    t.text     "wifi_hotspot_networks", limit: 65535
    t.boolean  "static_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "internet_deal_attributes", ["deal_id"], name: "index_internet_deal_attributes_on_deal_id", using: :btree

  create_table "internet_equipments", force: :cascade do |t|
    t.integer  "internet_deal_attribute_id", limit: 4
    t.string   "name",                       limit: 255
    t.string   "make",                       limit: 255
    t.decimal  "price",                                    precision: 30, scale: 2
    t.text     "installation",               limit: 65535
    t.string   "activation",                 limit: 255
    t.string   "offer",                      limit: 255
    t.boolean  "is_active"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
  end

  create_table "internet_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id", limit: 4
    t.float    "upload_speed",          limit: 24
    t.float    "download_speed",        limit: 24
    t.string   "online_storage",        limit: 255
    t.string   "wifi_hotspot",          limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "internet_service_preferences", ["service_preference_id"], name: "index_internet_service_preferences_on_service_preference_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "app_user_id",            limit: 4
    t.boolean  "recieve_notification"
    t.integer  "day",                    limit: 4
    t.boolean  "recieve_trending_deals",           default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "notifications", ["app_user_id"], name: "index_notifications_on_app_user_id", using: :btree

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
    t.float    "price",                 limit: 24
    t.boolean  "is_contract"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "plan_name",             limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
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
    t.string   "logo",                limit: 255
    t.boolean  "is_preferred",                    default: false
    t.boolean  "is_active",                       default: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "service_providers", ["service_category_id"], name: "index_service_providers_on_service_category_id", using: :btree

  create_table "subscribe_deals", force: :cascade do |t|
    t.integer  "app_user_id",   limit: 4
    t.integer  "deal_id",       limit: 4
    t.boolean  "active_status",           default: false
    t.integer  "category_id",   limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "subscribe_deals", ["app_user_id"], name: "index_subscribe_deals_on_app_user_id", using: :btree
  add_index "subscribe_deals", ["deal_id"], name: "index_subscribe_deals_on_deal_id", using: :btree

  create_table "telephone_deal_attributes", force: :cascade do |t|
    t.integer  "deal_id",                          limit: 4
    t.string   "domestic_call_minutes",            limit: 25
    t.integer  "domestic_receive_minutes",         limit: 4
    t.integer  "domestic_additional_minutes",      limit: 4
    t.string   "international_call_minutes",       limit: 25
    t.integer  "international_landline_minutes",   limit: 4
    t.integer  "international_mobile_minutes",     limit: 4
    t.integer  "international_additional_minutes", limit: 4
    t.text     "countries",                        limit: 65535
    t.text     "features",                         limit: 65535
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "telephone_deal_attributes", ["deal_id"], name: "index_telephone_deal_attributes_on_deal_id", using: :btree

  create_table "telephone_equipments", force: :cascade do |t|
    t.integer  "telephone_deal_attribute_id", limit: 4
    t.string   "name",                        limit: 255
    t.string   "make",                        limit: 255
    t.decimal  "price",                                     precision: 30, scale: 2
    t.text     "installation",                limit: 65535
    t.string   "activation",                  limit: 255
    t.string   "offer",                       limit: 255
    t.boolean  "is_active"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
  end

  create_table "telephone_service_preferences", force: :cascade do |t|
    t.integer  "service_preference_id",        limit: 4
    t.integer  "domestic_call_minutes",        limit: 4
    t.integer  "international_call_minutes",   limit: 4
    t.boolean  "domestic_call_unlimited",                default: false
    t.boolean  "international_call_unlimited",           default: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  add_index "telephone_service_preferences", ["service_preference_id"], name: "index_telephone_service_preferences_on_service_preference_id", using: :btree

  create_table "trending_deals", force: :cascade do |t|
    t.integer  "deal_id",            limit: 4
    t.integer  "subscription_count", limit: 4
    t.integer  "category_id",        limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "trending_deals", ["deal_id"], name: "index_trending_deals_on_deal_id", using: :btree

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
    t.boolean  "enabled"
    t.integer  "failed_count",           limit: 4
    t.datetime "password_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "zipcodes", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "area",       limit: 255
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "country",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "additional_offers", "deals"
  add_foreign_key "advertisements", "service_categories"
  add_foreign_key "bundle_service_preferences", "service_preferences"
  add_foreign_key "cable_service_preferences", "service_preferences"
  add_foreign_key "cellphone_service_preferences", "service_preferences"
  add_foreign_key "comment_ratings", "app_users"
  add_foreign_key "comment_ratings", "deals"
  add_foreign_key "deals", "service_categories"
  add_foreign_key "internet_deal_attributes", "deals"
  add_foreign_key "internet_service_preferences", "service_preferences"
  add_foreign_key "notifications", "app_users"
  add_foreign_key "service_preferences", "app_users"
  add_foreign_key "service_preferences", "service_categories"
  add_foreign_key "service_providers", "service_categories"
  add_foreign_key "subscribe_deals", "app_users"
  add_foreign_key "subscribe_deals", "deals"
  add_foreign_key "telephone_deal_attributes", "deals"
  add_foreign_key "telephone_service_preferences", "service_preferences"
  add_foreign_key "trending_deals", "deals"
end
