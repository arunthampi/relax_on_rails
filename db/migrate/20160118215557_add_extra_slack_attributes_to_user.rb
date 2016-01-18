class AddExtraSlackAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :image_url, :string
    add_column :users, :timezone, :string
    add_column :users, :timezone_description, :string
    add_column :users, :timezone_offset, :integer
  end
end
