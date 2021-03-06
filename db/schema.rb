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

ActiveRecord::Schema.define(version: 5) do

  create_table "pull_request_reviews", force: :cascade do |t|
    t.integer  "pull_request_id",             null: false
    t.integer  "user_id",                     null: false
    t.string   "state",                       null: false
    t.string   "graphql_id",                  null: false
    t.integer  "comment_count",   default: 0, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["graphql_id"], name: "index_pull_request_reviews_on_graphql_id", unique: true
    t.index ["pull_request_id"], name: "index_pull_request_reviews_on_pull_request_id"
    t.index ["user_id"], name: "index_pull_request_reviews_on_user_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.integer  "user_id",           null: false
    t.integer  "repository_id",     null: false
    t.string   "title",             null: false
    t.boolean  "seen",              null: false
    t.string   "graphql_id",        null: false
    t.integer  "number",            null: false
    t.string   "state",             null: false
    t.string   "path",              null: false
    t.datetime "github_created_at", null: false
    t.datetime "github_updated_at", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["graphql_id"], name: "index_pull_requests_on_graphql_id", unique: true
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
    t.index ["user_id"], name: "index_pull_requests_on_user_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "owner",                    null: false
    t.string   "name",                     null: false
    t.string   "last_pull_request_cursor"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "review_reviews", force: :cascade do |t|
    t.integer  "pull_request_id", null: false
    t.integer  "user_id",         null: false
    t.integer  "score",           null: false
    t.string   "comment"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["pull_request_id", "user_id"], name: "index_review_reviews_on_pull_request_id_and_user_id", unique: true
    t.index ["pull_request_id"], name: "index_review_reviews_on_pull_request_id"
    t.index ["user_id"], name: "index_review_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                      null: false
    t.string   "graphql_id",                 null: false
    t.boolean  "myself",     default: false, null: false
    t.boolean  "watched",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["graphql_id"], name: "index_users_on_graphql_id", unique: true
  end

end
