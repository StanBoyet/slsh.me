class CreateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.references :user, null: false, foreign_key: true
      t.text :original_url, null: false
      t.string :slug, null: false
      t.string :title
      t.text :description
      t.string :og_image_url
      t.string :password_digest
      t.datetime :expires_at
      t.integer :max_clicks
      t.boolean :active, null: false, default: true
      t.integer :clicks_count, null: false, default: 0

      t.timestamps
    end
    add_index :links, :slug, unique: true
    add_index :links, :user_id
    add_index :links, [ :user_id, :created_at ]
  end
end
