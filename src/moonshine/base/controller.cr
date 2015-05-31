abstract class Controller
  property router
  
  @router = {
  } of String => Request -> Response
  
  def call(request)
    @router.each do |route, block|
      method = route.split(" ")[0]
      path   = route.split(" ")[1]
      if Route.new(method, path).match?(request)
        return block.call(request)
      end
    end
    return nil
  end

end
