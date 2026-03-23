class CreateFeedbackItems < ActiveRecord::Migration[8.0]
  def change
    create_table :feedback_items do |t|
      t.string  :title,         null: false
      t.text    :description
      t.string  :status,        null: false, default: 'pending'
      t.integer :progress,      null: false, default: 0
      t.integer :upvotes_count, null: false, default: 0
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :feedback_items, :status
  end
end
