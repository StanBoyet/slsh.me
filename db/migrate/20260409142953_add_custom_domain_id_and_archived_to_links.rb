class AddCustomDomainIdAndArchivedToLinks < ActiveRecord::Migration[8.1]
  def change
    add_reference :links, :custom_domain, null: true, foreign_key: true
    add_column :links, :archived, :boolean, default: false, null: false

    # Slug must be unique per domain. For slsh.me links (custom_domain_id IS NULL),
    # keep a partial unique index. For custom domain links, compound index.
    remove_index :links, :slug
    add_index :links, :slug, unique: true, where: "custom_domain_id IS NULL AND archived = false",
              name: "index_links_on_slug_unique_default"
    add_index :links, [ :custom_domain_id, :slug ], unique: true,
              where: "custom_domain_id IS NOT NULL AND archived = false",
              name: "index_links_on_domain_and_slug_unique"
  end
end
