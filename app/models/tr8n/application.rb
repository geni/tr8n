
# == Schema Information
#
# Table name: tr8n_applications
#
#  id          :integer          not null, primary key
#  description :string
#  key         :string
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_tr8n_applications_on_key  (key)
#
class Tr8n::Application < ApplicationRecord

  has_many :components,           :dependent => :destroy
  has_many :component_sources,    :through => :components
  has_many :translation_sources,  :through => :component_sources

  def self.options
    Tr8n::Application.order("name asc").collect{|app| [app.name, app.id]}
  end

end
