
# Add backward compatibility shim for set_table_name in Rails 3.2+
# In Rails 3.2, set_table_name was deprecated in favor of self.table_name=
# This allows code written for Rails 3.1 to work in Rails 3.2
if defined?(ActiveRecord) && defined?(Rails) && Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 2
  module ActiveRecord
    class Base
      class << self
        unless respond_to?(:set_table_name)
          def set_table_name(value)
            self.table_name = value
          end
        end

        unless respond_to?(:set_primary_key)
          def set_primary_key(value)
            self.primary_key = value
          end
        end

        unless respond_to?(:set_inheritance_column)
          def set_inheritance_column(value)
            self.inheritance_column = value
          end
        end

        unless respond_to?(:set_sequence_name)
          def set_sequence_name(value)
            self.sequence_name = value
          end
        end

        unless respond_to?(:set_locking_column)
          def set_locking_column(value)
            self.locking_column = value
          end
        end
      end
    end
  end
end
