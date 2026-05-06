
module Tr8n
  class LanguageCasesController < ApplicationController

    before_filter :validate_current_translator
    before_filter :validate_language_management, :only => [:index]

    # used by a client app
    def index
      conditions = [String.new('language_id = ? and (reported is null or reported = ?)'), tr8n_current_language.id, false]

      unless params[:search].blank?
        conditions[0] << ' and keyword like ?'
        conditions << "%#{params[:search]}%"
      end

      @maps = Tr8n::LanguageCaseValueMap
                .where(conditions)
                .order('updated_at DESC')
                .paginate(:per_page => per_page, :page => page)
    end

    def manager
      @lcase = Tr8n::LanguageCase.by_id(params[:case_id]) unless params[:case_id].blank?
      @rule = Tr8n::LanguageCaseRule.by_id(params[:rule_id]) unless params[:rule_id].blank?

      @map = Tr8n::LanguageCaseValueMap.by_language_and_keyword(tr8n_current_language, params[:case_key])
      @map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :translator => tr8n_current_translator, :keyword => params[:case_key])

      render :layout => false
    end

    def switch_manager_mode
      @map = Tr8n::LanguageCaseValueMap.by_language_and_keyword(tr8n_current_language, params[:map_keyword])
      @map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :keyword => params[:case_key], :reported => false)

      render :partial => params[:mode]
    end

    def update_value_map
      if request.post?
        map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) unless params[:map_id].blank?
        map ||= Tr8n::LanguageCaseValueMap.new(:language => tr8n_current_language, :reported => false)
        map.keyword = params[:case_key]
        map.map = params[:map][:map]
        map.save_with_log!(tr8n_current_translator)
      end

      redirect_to_source
    end

    def delete_value_map
      if request.post?
        map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) if params[:map_id]
        map.destroy_with_log!(tr8n_current_translator) if map
      end

      redirect_to_source
    end

    def report_value_map
      if request.post?
        map = Tr8n::LanguageCaseValueMap.find_by_id(params[:map_id]) unless params[:map_id].blank?
        map.report_with_log!(tr8n_current_translator) if map
      end

      redirect_to_source
    end

  end # class LanguageCasesController
end # module Tr8n