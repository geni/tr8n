
module Tr8n
  module ArrayExtensions

    # translates an array of options for a select tag
    def tro(description = "", options = {}, language = Tr8n::Config.current_language)
      return [] if empty?

      collect do |opt|
        if opt.is_a?(Array) and opt.first.is_a?(String)
          [opt.first.trl(description, {}, options, language), opt.last]
        elsif opt.is_a?(String)
          [opt.trl(description, {}, options, language), opt]
        else
          opt
        end
      end
    end

    # translate array values
    def trl(description = "", options = {}, language = Tr8n::Config.current_language)
      return [] if empty?

      collect do |opt|
        if opt.is_a?(String)
          opt.trl(description, {}, options, language)
        else
          opt
        end
      end
    end

    # creates a sentence with tr "and" joiner
    def tr_sentence(options = {}, language = Tr8n::Config.current_language)
      return "" if empty?
      return first if size == 1

      result = "#{self[0..-2].join(", ")}"
      result << " " << "and".translate("List elements joiner", {}, options, language) << " "
      result << self.last
    end

    def tr8n_translated
      return self if frozen?
      @tr8n_translated = true
      self
    end

    def tr8n_translated?
      @tr8n_translated
    end

  end # module ArrayExtensions
end # module Tr8n

Array.send(:include, Tr8n::ArrayExtensions)