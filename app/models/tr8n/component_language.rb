
# == Schema Information
#
# Table name: tr8n_component_languages
#
#  id           :integer          not null, primary key
#  state        :string
#  created_at   :datetime
#  updated_at   :datetime
#  component_id :integer
#  language_id  :integer
#
# Indexes
#
#  tr8n_comp_lang_comp_id  (component_id)
#  tr8n_comp_lang_lang_id  (language_id)
#
class Tr8n::ComponentLanguage < ApplicationRecord

  belongs_to :component
  belongs_to :language

  def self.find_or_create(component, language)
    cs = find(:first, :conditions => ["component_id = ? and language_id = ?", component.id, language.id])
    cs || create(:component => component, :language => language)
  end

  def restricted?
    not live?
  end

  def live?
    state == "live"
  end

end
