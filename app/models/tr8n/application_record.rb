module Tr8n
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    include Tr8n::ActiveDumper

    self.table_name_prefix = 'tr8n_'
  end
end
