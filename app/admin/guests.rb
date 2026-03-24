# frozen_string_literal: true

ActiveAdmin.register Guest do
  permit_params :email, :notes

  menu priority: 2, label: "Convidados"

  filter :email
  filter :used_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :email
    column :notes
    column("Status") { |g| g.used? ? status_tag("Usado", class: "ok") : status_tag("Pendente", class: "warning") }
    column :used_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :notes
      row("Status") { |g| g.used? ? "Usado" : "Pendente" }
      row :used_at
      row :created_at
      row :updated_at
      row("Usuário") do |g|
        user = User.find_by(email: g.email)
        user ? link_to(user.username, admin_user_path(user)) : "(não registrado)"
      rescue
        "(não registrado)"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :notes
    end
    f.actions
  end

  action_item :reset_usage, only: :show, if: -> { resource.used? } do
    link_to "Resetar uso", reset_usage_admin_guest_path(resource), method: :put, data: { confirm: "Resetar o status de uso deste convidado?" }
  end

  member_action :reset_usage, method: :put do
    resource.update!(used_at: nil)
    redirect_to admin_guest_path(resource), notice: "Status resetado."
  end
end
