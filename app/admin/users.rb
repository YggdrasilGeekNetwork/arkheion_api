# frozen_string_literal: true

ActiveAdmin.register User do
  permit_params :email, :username, :display_name, :active

  menu priority: 1, label: "Usuários"

  filter :email
  filter :username
  filter :active
  filter :confirmed_at
  filter :created_at

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :display_name
    column("Confirmado") { |u| u.confirmed? ? status_tag("Sim", class: "ok") : status_tag("Não", class: "error") }
    column("Ativo") { |u| u.active? ? status_tag("Sim", class: "ok") : status_tag("Não", class: "warning") }
    column("Google") { |u| u.oauth_identities.any? ? status_tag("Sim", class: "ok") : "-" }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :display_name
      row :avatar_url
      row("Confirmado") { |u| u.confirmed? ? "Sim (#{u.confirmed_at})" : "Não" }
      row("Ativo") { |u| u.active? ? "Sim" : "Não" }
      row("OAuth") { |u| u.oauth_identities.map(&:provider).join(", ").presence || "Nenhum" }
      row :jti
      row :created_at
      row :updated_at
    end

    panel "Personagens" do
      table_for resource.character_sheets do
        column :id
        column :name
        column :current_level
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :username
      f.input :display_name
      f.input :active
    end
    f.actions
  end

  action_item :confirm, only: :show, if: -> { !resource.confirmed? } do
    link_to "Confirmar email", confirm_admin_user_path(resource), method: :put, data: { confirm: "Confirmar o email deste usuário?" }
  end

  member_action :confirm, method: :put do
    resource.confirm!
    redirect_to admin_user_path(resource), notice: "Email confirmado."
  end
end
