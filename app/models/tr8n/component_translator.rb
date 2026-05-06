
# == Schema Information
#
# Table name: tr8n_component_translators
#
#  id            :integer          not null, primary key
#  state         :string
#  created_at    :datetime
#  updated_at    :datetime
#  component_id  :integer
#  language_id   :integer
#  translator_id :integer
#
# Indexes
#
#  tr8n_comp_trn_comp_id  (component_id)
#  tr8n_comp_trn_trn_id   (translator_id)
#
class Tr8n::ComponentTranslator < ApplicationRecord

  belongs_to :component
  belongs_to :translator
  belongs_to :language

  def self.find_or_create(component, translator)
    cs = find(:first, :conditions => ["component_id = ? and translator_id = ?", component.id, translator.id])
    cs || create(:component => component, :translator => translator)
  end

  def after_create
    Tr8n::Notification.distribute(self)
  end

end
