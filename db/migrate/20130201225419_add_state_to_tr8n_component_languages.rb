class AddStateToTr8nComponentLanguages < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_component_languages, :state, :string
  end

  def self.down
    remove_column :tr8n_component_languages, :state
  end
end
