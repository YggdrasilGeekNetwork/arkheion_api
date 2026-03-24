# frozen_string_literal: true

class AddOauthSupportToUsers < ActiveRecord::Migration[8.0]
  def change
    # Rename password_digest -> encrypted_password (Devise column name)
    # Existing BCrypt hashes remain valid — Devise uses the same BCrypt algorithm.
    rename_column :users, :password_digest, :encrypted_password

    # OAuth-only users have no password
    change_column_null :users, :encrypted_password, true

    # Devise confirmable needs unconfirmed_email for reconfirmable flow
    add_column :users, :unconfirmed_email, :string

    # Avatar from Google or manual upload
    add_column :users, :avatar_url, :string
  end
end
