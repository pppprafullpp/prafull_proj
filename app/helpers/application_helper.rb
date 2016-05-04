module ApplicationHelper
	def match_controller?(name)
	    controller.controller_name == name
    end
	  
    def match_action?(name)
	    controller.action_name == name
	end

	def current_controller
	    controller.controller_name.humanize
	end
end
