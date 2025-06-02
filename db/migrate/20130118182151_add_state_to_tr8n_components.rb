class AddStateToTr8nComponents < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_components, :state, :string
  end

  def self.down
    remove_column :tr8n_components, :state
  end
end
