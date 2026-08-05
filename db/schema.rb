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

ActiveRecord::Schema[8.1].define(version: 2026_07_28_034037) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "account_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "download_url"
    t.integer "kind", null: false
    t.datetime "requested_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_account_requests_on_user_id"
    t.check_constraint "kind >= 0 AND kind <= 1", name: "account_requests_kind_check"
    t.check_constraint "status >= 0 AND status <= 3", name: "account_requests_status_check"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "actor_user_id"
    t.datetime "created_at", null: false
    t.uuid "family_id"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_user_id"], name: "index_audit_logs_on_actor_user_id"
    t.index ["family_id"], name: "index_audit_logs_on_family_id"
    t.index ["target_type", "target_id"], name: "index_audit_logs_on_target_type_and_target_id"
  end

  create_table "families", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "invitation_ttl_hours"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guardianships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_user_id"
    t.uuid "dependent_person_id", null: false
    t.uuid "family_id", null: false
    t.uuid "guardian_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_guardianships_on_created_by_user_id"
    t.index ["dependent_person_id"], name: "index_guardianships_on_dependent_person_id"
    t.index ["family_id", "guardian_user_id", "dependent_person_id"], name: "index_guardianships_uniqueness", unique: true
    t.index ["family_id"], name: "index_guardianships_on_family_id"
    t.index ["guardian_user_id"], name: "index_guardianships_on_guardian_user_id"
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "provider", default: 0, null: false
    t.string "provider_uid", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["provider", "provider_uid"], name: "index_identities_on_provider_and_provider_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_user_id", null: false
    t.citext "email"
    t.datetime "expires_at", null: false
    t.uuid "family_id", null: false
    t.datetime "revoked_at"
    t.integer "role", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.uuid "used_by_person_id"
    t.index ["code"], name: "index_invitations_on_code", unique: true
    t.index ["created_by_user_id"], name: "index_invitations_on_created_by_user_id"
    t.index ["family_id"], name: "index_invitations_on_family_id"
    t.index ["used_by_person_id"], name: "index_invitations_on_used_by_person_id"
    t.check_constraint "role >= 1 AND role <= 3", name: "invitations_role_check"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "family_id", null: false
    t.uuid "invited_by_user_id"
    t.datetime "joined_at"
    t.datetime "left_at"
    t.uuid "person_id", null: false
    t.datetime "removed_at"
    t.integer "role", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "person_id"], name: "index_memberships_on_family_id_and_person_id", unique: true
    t.index ["family_id"], name: "index_memberships_on_family_id"
    t.index ["family_id"], name: "index_memberships_on_single_active_owner_per_family", unique: true, where: "((role = 0) AND (status = 0))"
    t.index ["invited_by_user_id"], name: "index_memberships_on_invited_by_user_id"
    t.index ["person_id"], name: "index_memberships_on_person_id"
    t.check_constraint "role >= 0 AND role <= 3", name: "memberships_role_check"
    t.check_constraint "status >= 0 AND status <= 2", name: "memberships_status_check"
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "nickname"
    t.datetime "updated_at", null: false
  end

  create_table "refresh_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_name"
    t.datetime "expires_at", null: false
    t.string "ip_address"
    t.datetime "last_used_at"
    t.datetime "revoked_at"
    t.string "token_hash", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["token_hash"], name: "index_refresh_tokens_on_token_hash", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_family_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.citext "email", null: false
    t.datetime "email_verified_at"
    t.integer "failed_login_attempts", default: 0, null: false
    t.datetime "last_login_at"
    t.datetime "locked_at"
    t.string "password_digest", null: false
    t.uuid "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["active_family_id"], name: "index_users_on_active_family_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["person_id"], name: "index_users_on_person_id", unique: true
  end

  add_foreign_key "account_requests", "users"
  add_foreign_key "audit_logs", "families"
  add_foreign_key "audit_logs", "users", column: "actor_user_id"
  add_foreign_key "guardianships", "families"
  add_foreign_key "guardianships", "people", column: "dependent_person_id"
  add_foreign_key "guardianships", "users", column: "created_by_user_id"
  add_foreign_key "guardianships", "users", column: "guardian_user_id"
  add_foreign_key "identities", "users"
  add_foreign_key "invitations", "families"
  add_foreign_key "invitations", "people", column: "used_by_person_id"
  add_foreign_key "invitations", "users", column: "created_by_user_id"
  add_foreign_key "memberships", "families"
  add_foreign_key "memberships", "people"
  add_foreign_key "memberships", "users", column: "invited_by_user_id"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "users", "families", column: "active_family_id"
  add_foreign_key "users", "people"
end
