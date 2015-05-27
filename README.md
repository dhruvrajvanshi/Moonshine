# Moonshine [![Build Status](https://travis-ci.org/dhruvrajvanshi/Moonshine.svg?branch=master)](https://travis-ci.org/dhruvrajvanshi/Moonshine)
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example.

```crystal
	include Moonshine
	include Moonshine::Shortcuts

	app = Moonshine::App.new

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
```

## Form Parameters
Moonshine automatically pases POST and GET parameters for you. The `get` and `post` properties are hashes of these params.

```crystal
	app.get "/putparams", do |request|
		ok("<h1>POST<h1><p>#{request.post}</p><h2>GET<h2><p>#{request.get}</p>")
	end
```

## Controllers
Controllers are objects which can respond to all HTTP verbs. You can override the methods get, post, etc to return responses. Base versions of these methods return a 405(method not allowed) response. Override them to change this behaviour.

```crystal
	# subclass Moonshine::Controller to define a controller
	class HomeController < Moonshine::Controller
		def initialize()
			@viewcount = 0
		end

		# Override individual HTTP methods
		def get(req)
			@viewcount += 1
			ok("This page has been visited #{@viewcount} times.")
		end
	end

	# Bind controller to the app object
	app.controller "/", HomeController.new
```

app.controller can also take an Array of strings as first argument to match multiple routes with the controller.

Override the call method of the controller to get custom routing within the controller.

```crystal
	class PostController < Moonshine::Controller
		def initialize()
			@posts = [
						Post.new("Post1"),
						Post.new("Post2")
					 ] of Post
			@router = {
				"GET /posts" =>
					->(req : Request) { get_all_posts() },
				"GET /posts/:id" =>
					->(req : Request) { get_post(req.params["id"]) }
			} of String => (Request -> Response)
		end

		def call(req : Moonshine::Request)
			@router.each do |route, block|
				if Route.new(route.split(" ")[0],
					route.split(" ")[1]).match? req
					return block.call(req)
				end
			end
			return Moonshine::Response.new(404, "unhandled route on controller")
		end

		def get_post(id)
			...
		end

		def get_all_posts()
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
### Request Middleware

```crystal
	# add request middleware
	app.request_middleware do |req|
		unless req.headers["user"]
			Moonshine::MiddlewareResponse.new(
				Moonshine::Response.new(200, "Not allowed"),
				pass_through = false
				)
		else
			Moonshine::MiddlewareResponse.new
		end
	end
```

To add a request middleware, call app.request_middleware with a block that returns a Moonshine::MiddlewareResponse object. If the @pass_through attribute of the MiddlewareResponse is true, other request middlewares will be called. Otherwise the @response attribute will be directly returned

### Response Middleware
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
	app = Moonshine::App.new(static_dirs = ["res"])
```
