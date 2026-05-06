module Tr8n
  class HelpController < Tr8n::BaseController
    set_tr8n_feature  :help

    before_filter :validate_current_translator, :except => [:lb_shortcuts, :lb_stats, :credits, :license]
    before_filter :validate_guest_user, :except => [:lb_shortcuts, :lb_stats, :credits, :license]
    before_filter :validate_current_user, :except => [:lb_shortcuts, :lb_stats, :credits, :license]

    def index

    end

    def lb_shortcuts
      render :layout => false
    end

    def lb_stats
      render :layout => false
    end

    def lb_source
      @translation_source = Tr8n::TranslationSource.find_or_create(params[:source])
      @translation_source_metric = @translation_source.total_metric
      render :layout => false
    end

    def credits

    end

    def license

    end

  end # class HelpController
end # module Tr8n