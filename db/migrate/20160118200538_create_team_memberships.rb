class CreateTeamMemberships < ActiveRecord::Migration
  def change
    create_table :team_memberships do |t|
      t.references :team, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :membership_type, null: false, default: "member"
      t.string :user_uid, null: false

      t.timestamps null: false
    end

    add_index :team_memberships, [:team_id, :user_id], unique: true, name: 'index_on_team_id_user_id'
    add_index :team_memberships, [:team_id, :user_uid], unique: true, name: 'index_team_memberships_on_team_id_and_user_uid'
  end
end
