class CreateBots < ActiveRecord::Migration
  def change
    create_table :bots do |t|
      t.references :team, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :token, null: false
      t.boolean :enabled, default: true, null: false

      t.timestamps null: false
    end
  end
end
