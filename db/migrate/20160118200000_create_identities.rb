class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.text :meta
      t.string :token, null: false
      t.string :secret
      t.string :team_uid, null: false

      t.timestamps null: false
    end
  end
end
