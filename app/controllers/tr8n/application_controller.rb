module Tr8n
  class ApplicationController < ::ApplicationController
    include Tr8n::Concerns::ControllerMethods
    include Tr8n::ApplicationHelper

    ######################################################################
    # Author: Iain Hecker
    # reference: http://github.com/iain/http_accept_language
    ######################################################################
    def tr8n_browser_accepted_locales
      @accepted_languages ||= request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |l|
        l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
        l.split(';q=')
      end.sort do |x,y|
        raise Tr8n::Exception.new("Not correctly formatted") unless x.first =~ /^[a-z\-]+$/i
        y.last.to_f <=> x.last.to_f
      end.collect do |l|
        l.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
      end
    rescue
      []
    end # def tr8n_browser_accepted_locales

  end # class ApplicationController
end # module Tr8n
