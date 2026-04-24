class AddCampaignToLinks < ActiveRecord::Migration[8.1]
  def change
    add_reference :links, :campaign, foreign_key: true
  end
end
