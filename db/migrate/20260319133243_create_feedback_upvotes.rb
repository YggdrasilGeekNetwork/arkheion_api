class CreateFeedbackUpvotes < ActiveRecord::Migration[8.0]
  def change
    create_table :feedback_upvotes do |t|
      t.references :feedback_item, null: false, foreign_key: true
      t.references :user,          null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :feedback_upvotes, %i[feedback_item_id user_id], unique: true
  end
end
