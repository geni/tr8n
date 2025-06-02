class AddKeyCountToTr8nSources < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translation_sources, :key_count, :integer
  end

  def self.down
    remove_column :tr8n_translation_sources, :key_count
  end
end
