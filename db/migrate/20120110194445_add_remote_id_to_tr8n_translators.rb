
class AddRemoteIdToTr8nTranslators < ActiveRecord::Migration
  def self.up
    add_column :tr8n_translators, :remote_id, :integer
  end

  def self.down
    remove_column :tr8n_translators, :remote_id
  end
end
