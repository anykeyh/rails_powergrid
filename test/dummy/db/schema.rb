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

ActiveRecord::Schema.define(version: 20150923024010) do

  create_table "authors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nationality"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "authors", ["first_name"], name: "index_authors_on_first_name"
  add_index "authors", ["last_name"], name: "index_authors_on_last_name"
  add_index "authors", ["nationality"], name: "index_authors_on_nationality"

  create_table "books", force: :cascade do |t|
    t.string   "name"
    t.integer  "author_id"
    t.text     "summary"
    t.string   "isbn_number"
    t.datetime "published_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.decimal  "price"
  end

  add_index "books", ["author_id"], name: "index_books_on_author_id"
  add_index "books", ["isbn_number"], name: "index_books_on_isbn_number"
  add_index "books", ["name"], name: "index_books_on_name"
  add_index "books", ["published_at"], name: "index_books_on_published_at"

  create_table "order_lines", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "quantity"
    t.decimal  "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "order_lines", ["book_id"], name: "index_order_lines_on_book_id"

  create_table "orders", force: :cascade do |t|
    t.string   "status",     default: "CART"
    t.datetime "ordered_at"
    t.decimal  "total"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "orders", ["ordered_at"], name: "index_orders_on_ordered_at"
  add_index "orders", ["total"], name: "index_orders_on_total"
  add_index "orders", ["user_id"], name: "index_orders_on_user_id"

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "role_id"
  end

  add_index "users", ["role_id"], name: "index_users_on_role_id"

end
