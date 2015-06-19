# Moonshine [![Build Status](https://travis-ci.org/dhruvrajvanshi/Moonshine.svg?branch=master)](https://travis-ci.org/dhruvrajvanshi/Moonshine)
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example.

```crystal
require "moonshine"

include Moonshine
include Moonshine::Utils::Shortcuts
include Moonshine::Base

app = App.new

# respond to all HTTP verbs
app.route "/", do |request|
    ok("Hello Moonshine!")
end

# or particular HTTP verbs
app.get "/get", do |request|
    ok("This is a get response")
end

# you can set response headers
app.get "api", do |request|
    res = ok("{ name : 'moonshine'}")
    res.headers["Content-type"] = "text/json"
    res
end

app.run(8000)
```

## Form Parameters
Moonshine automatically pases POST and GET parameters for you. The `get` and `post` properties are hashes of these params.

```crystal
app.get "/putparams", do |request|
	ok("<h1>POST<h1><p>#{request.post}</p><h2>GET<h2><p>#{request.get}</p>")
end
```

## Controllers
Controllers are objects which can respond to multiple routes. Set the @rotuer instance variable of a controller to specify routing within controller. Add the controller to the app using app.controller method. Thse first argument can be a path pattern or an array of patterns to which the controller should respond
```crystal
# subclass Moonshine::Base::Controller to define a controller
class HomeController < Controller
	def initialize()
		@viewcount = 0
		@router = {
			"GET /" => ->get(Request),
		} of String => (Request -> Response)
	end

	def get(req)
		@viewcount += 1
		ok("This page has been visited #{@viewcount} times.")
	end
end

# Bind controller to the app object
app.controller "/", HomeController.new

```

app.controller can also take an Array of strings as first argument to match multiple routes with the controller.

```crystal
class PostController < Moonshine::Controller
	def initialize()
		@posts = [
					Post.new("Post1"),
					Post.new("Post2")
				 ] of Post
		@router = {
			"GET /posts" =>
				->get_all_posts(Request),
			"GET /posts/:id" =>
				->get_post(Request)
		} of String => (Request -> Response)
	end

	def get_post(req)
		...
	end

	def get_all_posts(req)
		...
	end
end

app.controller([
		"/posts",
		"/posts/:id"
	] of String, PostController.new)
```

## Error Handlers
```crystal
# add error handlers
include Moonshine::Shortcuts
app.error_handler "404", do |req|
	Moonshine::not_found
end
```

## Middleware
You can either create [middleware classes](#middleware_classes) or individual methods that process [request](#request_middleware) or [response](#response_middleware)
### Middleware Classes<a name="middleware_classes"></a>
You can add middleware classes to your application by inheriting from Middleware::Base. Your class can override process_request and process_response methods to globally alter request and response objects.
```crystal
class Hello < Moonshine::Middleware::Base
	def process_request(req)
		req.headers["User"] = "Annonymous"
	end

	def process_response(req, res)
		req.body += "\nFooter"
	end
end
app.middleware_object Hello.new
```

### Request Middleware<a name="request_middleware"></a>
```crystal
# add request middleware
app.request_middleware do |req|
	unless req.headers["user"]
		Moonshine::Http::MiddlewareResponse.new(
			Moonshine::Response.new(200, "Not allowed"),
			pass_through = false
			)
	else
		Moonshine::MiddlewareResponse.new
	end
end
```

To add a request middleware, call app.request_middleware with a block that returns a Moonshine::MiddlewareResponse object. If the @pass_through attribute of the MiddlewareResponse is true, other request middlewares will be called. Otherwise the @response attribute will be directly returned

### Response Middleware<a name="response_middleware"></a>
```crystal
# add response middleware
app.response_middleware do |req, res|
	res.body = "Modified"
	res
end
```
Response middleware methods take request and response arguments and return a response. This is used to globally alter the response of the application. Response middleware are processed in order

## Static Files
To serve a static directory, pass an array of paths to Moonshine::App's constructor

```crystal
app = App.new(static_dirs = ["res"])
```
