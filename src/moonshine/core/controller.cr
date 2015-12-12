require "./route"

include Moonshine::Http

module Moonshine::Core
  abstract class Controller
    property router
    @router = {} of String => String

    def call(request)
      @router.each do |route, action|
        method = route.split(" ")[0]
        path = route.split(" ")[1]
        route = Route.new(method, path)
        if route.match?(request)
          request.set_params(route.get_params(request))
          if action.is_a?(String)
            return action_to_proc(action).call(request)
          elsif action.responds_to?(:call)
            return action.call(request)
          end
        end
      end
      return nil
    end

    def handles?(request)
      @router.each do |route, block|
        method = route.split(" ")[0]
        path = route.split(" ")[1]
        if Route.new(method, path).match?(request)
          return true
        end
      end
      return false
    end

    # Converts allows strings to be converted to procs
    macro actions(*actions)
      private def action_to_proc(action_string : String)
        procs = {
          {% for action in actions %}
            {{action}}.to_s => ->{{action.id}}(Request),
          {% end %}
        }
        return procs.fetch action_string, ->(request : Request) {
            Response.new(404, "Action '#{action_string}' not found")
          }
      end 
    end
  end
end
