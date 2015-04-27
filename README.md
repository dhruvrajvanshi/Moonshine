# Moonshine
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example

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

	# you can even set response headers
	app.get "api", do |request|
		res = ok("{ name : 'moonshine'}")
		res.headers["Content-type"] = "text/json"
		res
	end

	# add error handlers
	app.error_handler "404", do |req|
		Moonshine::Response.new(404, "Not found")
	end
	
To serve a static directory, pass an array of paths to Moonshine::App's constructor
	app = Moonshine::App.new(static_dirs = ["res"])

