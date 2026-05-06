
module Tr8n
  module HashExtensions

    # Return all combinations of a hash.
    #
    # Example:
    #   {
    #     :a => [1, 2]
    #     :b => [1, 2]
    #   }.combinations #=> [{:a=>1, :b=>1}, {:a=>1, :b=>2}, {:a=>2, :b=>1}, {:a=>2, :b=>2}]
    #
    def combinations
      return [{}] if empty?

      copy = dup
      values = copy.delete(key = keys.first)

      result = []
      copy.combinations.each do |tail|
        values.each do |value|
          result << tail.merge(key=>value)
        end
      end

      result
    end

    def tr8n_translated
      return self if frozen?
      @tr8n_translated = true
      self
    end

    def tr8n_translated?
      defined?(@tr8n_translated) ? @tr8n_translated : false
    end

  end # module HashExtensions
end # module Tr8n

Hash.send(:include, Tr8n::HashExtensions)