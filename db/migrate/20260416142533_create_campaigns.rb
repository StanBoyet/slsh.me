class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :color, null: false, default: "orange"
      t.integer :links_count, null: false, default: 0

      t.timestamps
    end

    add_index :campaigns, %i[user_id slug], unique: true
  end
end
