class AddMissingVisitIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :visits, [:link_id, :os], algorithm: :concurrently
    add_index :visits, [:link_id, :referer], algorithm: :concurrently
  end
end
