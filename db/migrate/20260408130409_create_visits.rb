class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.references :link, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.string :browser
      t.string :browser_version
      t.string :os
      t.string :device_type
      t.string :country
      t.string :country_code, limit: 2
      t.string :city
      t.string :region
      t.string :referer
      t.boolean :bot, null: false, default: false

      t.timestamps
    end
    add_index :visits, [ :link_id, :created_at ]
    add_index :visits, [ :link_id, :country_code ]
    add_index :visits, [ :link_id, :browser ]
    add_index :visits, [ :link_id, :device_type ]
    add_index :visits, [ :link_id, :bot ]
  end
end
