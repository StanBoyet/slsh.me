class AddStudioFieldsToCampaigns < ActiveRecord::Migration[8.1]
  def change
    change_table :campaigns do |t|
      t.text :destination_url
      t.string :title
      t.text :description
      t.integer :goal_clicks
      t.datetime :starts_at
      t.datetime :ends_at
    end
  end
end
