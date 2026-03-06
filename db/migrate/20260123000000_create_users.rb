# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :username, null: false
      t.string :display_name

      # JWT token management
      t.string :jti, null: false
      t.datetime :token_expires_at

      # Account status
      t.boolean :active, null: false, default: true
      t.datetime :confirmed_at
      t.string :confirmation_token
      t.datetime :confirmation_sent_at

      # Password reset
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.jsonb :preferences, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :jti, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
