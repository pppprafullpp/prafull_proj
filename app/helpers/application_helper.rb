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

	def link_to_add_fields(name, f, association)
  	new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
