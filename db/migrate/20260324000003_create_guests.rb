# frozen_string_literal: true

class CreateGuests < ActiveRecord::Migration[8.0]
  def change
    create_table :guests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :email, null: false
      t.datetime :used_at
      t.string :notes

      t.timestamps
    end

    add_index :guests, :email, unique: true
  end
end
