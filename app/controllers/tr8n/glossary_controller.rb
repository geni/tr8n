module Tr8n
  class GlossaryController < ApplicationController

    set_tr8n_feature  :glossary

    before_filter :validate_current_translator

    def index
      if params[:search].blank?
        @terms = Tr8n::Glossary
      else
        @terms = Tr8n::Glossary.where(['(keyword like ? OR description like ?)', params[:search], params[:search]])
      end

      @terms = @terms.order('keyword asc').paginate(:page => page, :per_page => per_page)
    end

  end # class GlossaryController
end # module Tr8n