class AddExtraAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :full_name, :string
    add_column :users, :signed_in_via_oauth, :boolean, default: false, null: false
  end
end
