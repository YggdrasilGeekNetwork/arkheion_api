# frozen_string_literal: true

ActiveAdmin.register FeedbackItem do
  permit_params :title, :description, :status, :progress

  filter :title
  filter :status, as: :select, collection: FeedbackItem::STATUSES
  filter :user_email, as: :string, label: "User Email"
  filter :created_at

  index do
    selectable_column
    id_column
    column :title
    column :status
    column :progress do |item|
      "#{item.progress}%"
    end
    column :upvotes_count
    column :user do |item|
      item.user.email
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :status
      row :progress do |item|
        "#{item.progress}%"
      end
      row :upvotes_count
      row :user do |item|
        item.user.email
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :status, as: :select, collection: FeedbackItem::STATUSES
      f.input :progress, hint: "0–100"
    end
    f.actions
  end
end
