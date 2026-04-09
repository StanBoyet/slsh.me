class CreateCustomDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_domains do |t|
      t.references :user, null: false, foreign_key: true
      t.string :domain, null: false
      t.boolean :verified, default: false, null: false
      t.timestamps
    end

    add_index :custom_domains, :domain, unique: true
  end
end
