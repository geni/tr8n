module Tr8n::CommonMethods
  extend ActiveSupport::Concern

  def tr8n_component
    nil
  end

  # for translating labels
  def trl(label, desc = "", tokens = {}, options = {})
    tr(label, desc, tokens, options.merge(:skip_decorations => true))
  end

  # flash notice
  def trfn(label, desc = "", tokens = {}, options = {})
    flash[:trfn] = label.tr8n_translated? ? label : tr(label, desc, tokens, options)
  end

  # flash error
  def trfe(label, desc = "", tokens = {}, options = {})
    flash[:trfe] = label.tr8n_translated? ? label : tr(label, desc, tokens, options)
  end

  # admin interface translations
  def tra(label, desc = "", tokens = {}, options = {})
    if Tr8n::Config.enable_admin_translations?
      if Tr8n::Config.enable_admin_inline_mode?
        tr(label, desc, tokens, options)
      else
        trl(label, desc, tokens, options)
      end
    else
      Tr8n::Config.default_language.translate(label, desc, tokens, options)
    end
  end

  # admin interface translations
  def trla(label, desc = "", tokens = {}, options = {})
    tra(label, desc, tokens, options.merge(:skip_decorations => true))
  end
  # end translation helper methods

  def tr(label, desc = "", tokens = {}, options = {})
    unless desc.nil? or desc.is_a?(String)
      raise Tr8n::Exception.new("The second parameter of the tr function must be a description")
    end

    # if the label has already been translated, just return it back.
    # if this line is removed, an exception will be raised from within the Language object
    return label if label.tr8n_translated?

    begin
      url     = request.url
      host    = request.env['HTTP_HOST']
    rescue Exception => ex
      url = nil
      host = 'localhost'
    end

    options.merge!(:caller => caller)
    options.merge!(:url => url)
    options.merge!(:host => host)

    unless Tr8n::Config.enabled?
      return Tr8n::TranslationKey.substitute_tokens(label, tokens, options)
    end

    Tr8n::Config.current_language.translate(label, desc, tokens, options)
  end # def tr

end # module Tr8n::CommonMethods
