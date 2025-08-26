module Tr8n
  class ApplicationController < ::ApplicationController
    include Tr8n::Concerns::ControllerMethods
    include Tr8n::ApplicationHelper

  end # class ApplicationController
end # module Tr8n
