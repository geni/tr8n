class AddPositionToLanguageCaseRules < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_language_case_rules, :position, :integer
  end

  def self.down
    remove_column :tr8n_language_case_rules, :position
  end
end
