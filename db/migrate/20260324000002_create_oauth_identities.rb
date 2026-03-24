# frozen_string_literal: true

class CreateOauthIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :oauth_identities, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false   # e.g. "google"
      t.string :uid, null: false        # Google's sub
      t.string :email
      t.string :name
      t.string :avatar_url
      t.jsonb :data, default: {}
      t.timestamps
    end

    add_index :oauth_identities, [:provider, :uid], unique: true
    add_index :oauth_identities, [:user_id, :provider], unique: true
  end
end
