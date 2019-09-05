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

ActiveRecord::Schema.define(version: 2019_09_05_153733) do

  create_table "emailaccounts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address"
    t.string "password"
    t.string "encrypted_password"
    t.string "encryption_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "drafts_created_today"
    t.integer "drafts_created_lifetime"
    t.text "template"
    t.index ["user_id"], name: "index_emailaccounts_on_user_id"
  end

  create_table "invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id", null: false
    t.float "amount"
    t.float "amount_paid"
    t.datetime "date_paid"
    t.integer "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "paymentmethods", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false
    t.string "card_number"
    t.string "card_exp_month"
    t.string "card_exp_year"
  end

  create_table "replies", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "emailaccount_id", null: false
    t.string "keywords"
    t.text "body"
    t.string "negative_keywords"
    t.boolean "catchcall"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "drafts_created_today"
    t.integer "drafts_created_lifetime"
    t.index ["emailaccount_id"], name: "index_replies_on_emailaccount_id"
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subscriptions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "price"
    t.string "frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "reference"
    t.string "payment_provider"
    t.timestamp "timestamp"
    t.boolean "reversed"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "username"
    t.string "email_address"
    t.string "encrypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subscription_id"
    t.datetime "subscription_start_date"
    t.datetime "subscription_last_payment_date"
    t.index ["email_address"], name: "index_users_on_email_address"
  end

end
