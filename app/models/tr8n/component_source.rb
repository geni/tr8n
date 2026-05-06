
# == Schema Information
#
# Table name: tr8n_component_sources
#
#  id                    :integer          not null, primary key
#  created_at            :datetime
#  updated_at            :datetime
#  component_id          :integer
#  translation_source_id :integer
#
# Indexes
#
#  tr8n_comp_comp_id  (component_id)
#  tr8n_comp_src_id   (translation_source_id)
#
class Tr8n::ComponentSource < ApplicationRecord

  belongs_to :component
  belongs_to :translation_source

  has_many :translation_key_sources, :through => :translation_source
  has_many :translation_keys,        :through => :translation_key_sources

  def self.find_or_create(component, source)
    cs = find(:first, :conditions => ["component_id = ? and translation_source_id = ?", component.id, source.id])
    cs || create(:component => component, :translation_source => source)
  end

end
