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

ActiveRecord::Schema[8.1].define(version: 2026_04_16_142541) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "color", default: "orange", null: false
    t.datetime "created_at", null: false
    t.integer "links_count", default: 0, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "slug"], name: "index_campaigns_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "custom_domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified", default: false, null: false
    t.index ["domain"], name: "index_custom_domains_on_domain", unique: true
    t.index ["user_id"], name: "index_custom_domains_on_user_id"
  end

  create_table "links", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.boolean "archived", default: false, null: false
    t.bigint "campaign_id"
    t.integer "clicks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "custom_domain_id"
    t.text "description"
    t.datetime "expires_at"
    t.integer "max_clicks"
    t.string "og_image_url"
    t.text "original_url", null: false
    t.string "password_digest"
    t.string "slug", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["campaign_id"], name: "index_links_on_campaign_id"
    t.index ["custom_domain_id", "slug"], name: "index_links_on_domain_and_slug_unique", unique: true, where: "((custom_domain_id IS NOT NULL) AND (archived = false))"
    t.index ["custom_domain_id"], name: "index_links_on_custom_domain_id"
    t.index ["slug"], name: "index_links_on_slug_unique_default", unique: true, where: "((custom_domain_id IS NULL) AND (archived = false))"
    t.index ["user_id", "created_at"], name: "index_links_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.boolean "bot", default: false, null: false
    t.string "browser"
    t.string "browser_version"
    t.string "city"
    t.string "country"
    t.string "country_code", limit: 2
    t.datetime "created_at", null: false
    t.string "device_type"
    t.string "ip_address"
    t.bigint "link_id", null: false
    t.string "os"
    t.string "referer"
    t.string "region"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["link_id", "bot"], name: "index_visits_on_link_id_and_bot"
    t.index ["link_id", "browser"], name: "index_visits_on_link_id_and_browser"
    t.index ["link_id", "country_code"], name: "index_visits_on_link_id_and_country_code"
    t.index ["link_id", "created_at"], name: "index_visits_on_link_id_and_created_at"
    t.index ["link_id", "device_type"], name: "index_visits_on_link_id_and_device_type"
    t.index ["link_id", "os"], name: "index_visits_on_link_id_and_os"
    t.index ["link_id", "referer"], name: "index_visits_on_link_id_and_referer"
    t.index ["link_id"], name: "index_visits_on_link_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campaigns", "users"
  add_foreign_key "custom_domains", "users"
  add_foreign_key "links", "campaigns"
  add_foreign_key "links", "custom_domains"
  add_foreign_key "links", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "visits", "links"
end
