# Moonshine
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example

	include Moonshine
	include Moonshine::Shortcuts

	app = Moonshine::App.new
	app.route "/", do |request|
		ok("Hello Moonshine!")
	end

Note that the controller needs to have a method named handle which returns a Moonshine::Response, otherwise the web server won't know which method to call.
