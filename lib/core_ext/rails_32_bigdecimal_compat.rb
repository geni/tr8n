# Monkey patch for Rails 3.2.x + Ruby 2.7+ BigDecimal compatibility
# This must be loaded BEFORE Rails loads

# Fix: BigDecimal.new is deprecated in Ruby 2.7+
# Rails 3.2's duplicable.rb tries to call BigDecimal.new which doesn't exist
# We need to define BigDecimal.new as an alias to BigDecimal() kernel method
require 'bigdecimal'

BigDecimal.singleton_class.prepend(Module.new do
  def new(*args, **kwargs)
    if kwargs.empty?
      ::Kernel.BigDecimal(*args)
    else
      ::Kernel.BigDecimal(*args, **kwargs)
    end
  end
end)
