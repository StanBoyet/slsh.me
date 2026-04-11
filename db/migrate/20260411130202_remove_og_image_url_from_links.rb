class RemoveOgImageUrlFromLinks < ActiveRecord::Migration[8.1]
  def change
    remove_column :links, :og_image_url, :string
  end
end
