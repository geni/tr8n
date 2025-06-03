module Tr8n
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    self.table_name_prefix = 'tr8n_'
  end
end
