
module Tr8n
  module StringExtensions

    def translate(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
      language.translate(self, desc, tokens, options)
    end

    def pluralize_for(count, plural = nil)
      return self if count==1
      plural || pluralize
    end

    def trl(desc = "", tokens = {}, options = {}, language = Tr8n::Config.current_language)
      translate(desc, tokens, options.merge(:skip_decorations => true), language)
    end

    def tr8n_translated
      return self if frozen?
      @tr8n_translated = true
      self
    end

    def tr8n_translated?
      defined?(@tr8n_translated) ? @tr8n_translated : false
    end

    def tr8n_translation_not_found
      @tr8n_not_found = true
      self
    end

    def tr8n_translation_successful?
      defined?(@tr8n_not_found) ? false : true
    end

    def html_safe
      return dup.html_safe.freeze if frozen?

      @html_safe = true
      self
    end

    def html_safe?
      defined?(@html_safe) ? @html_safe : false
    end

  end # module StringExtensions
end # module Tr8n

# have to use prepend because rails has its own html_safe implementation
String.send(:prepend, Tr8n::StringExtensions)
