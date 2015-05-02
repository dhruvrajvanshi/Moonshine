# Moonshine [![Build Status](https://travis-ci.org/dhruvrajvanshi/Moonshine.svg?branch=master)](https://travis-ci.org/dhruvrajvanshi/Moonshine)
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example.

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
	
## Controllers
Controllers are objects which can respond to all HTTP verbs. You can override the methods get, post, etc to return responses. Base versions of these methods return a 405(method not allowed) response. Override them to change this behaviour.
	
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

app.controller can also take an Array of strings as first argument to match multiple routes with the controller.

Override the call method of the controller to get custom routing within the controller.

	class PostController < Moonshine::Controller
		def initialize()
			@posts = [
						Post.new("Post1"),
						Post.new("Post2")
					 ] of Post
		end

		# Override for custom routing
		def call(req : Moonshine::Request)
			if Moonshine::Route.new("GET", "/posts").match? req
				get_all_posts()
			elsif Moonshine::Route.new("GET", "/posts/:id").match? req
				get_post(req.params["id"])
			else
				Moonshine::Response.new(404, "Invalid path")
			end
		end

		def get_all_posts()
			return ok(@posts.to_s)
		end

		def get_post(id)
			id = id.to_i
			@posts.each do |post|
				if post.id == id
					return ok(post.to_s)
				end
			end
			return Moonshine::Response.new(404,
				"Post with id #{id} not found on server")
		end
	end

	app.controller([
			"/posts",
			"/posts/:id"
		] of String, PostController.new)

## Error Handlers
	# add error handlers
	app.error_handler "404", do |req|
		Moonshine::Response.new(404, "Not found")
	end

## Middleware
### Request Middleware
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
To add a request middleware, call app.request_middleware with a block that returns a Moonshine::MiddlewareResponse object. If the @pass_through attribute of the MiddlewareResponse is true, other request middlewares will be called. Otherwise the @response attribute will be directly returned

### Response Middleware
	# add response middleware
	app.response_middleware do |req, res|
		res.body = "Modified"
		res
	end
Response middleware methods take request and response arguments and return a response. This is used to globally alter the response of the application. Response middleware are processed in order

## Static Files
To serve a static directory, pass an array of paths to Moonshine::App's constructor
	
	app = Moonshine::App.new(static_dirs = ["res"])

