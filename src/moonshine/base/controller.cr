abstract class Controller
  {% for method in METHODS %}
    def {{method.id.downcase}}(req)
      Response.new(405, "Method not allowed")
    end
  {% end %}

  def call(request)
    case request.method
    when "GET" then get(request)
    when "POST" then post(request)
    when "PUT" then put(request)
    when "DELETE" then delete(request)
    when "PATCH" then patch(request)
    else Response.new(405, "Method not allowed")
    end
  end
end
