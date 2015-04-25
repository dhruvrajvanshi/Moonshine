# Moonshine
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example

	include Moonshine
	include Moonshine::Shortcuts

	app = Moonshine::App.new
	app.route "/", do |request|
		ok("Hello Moonshine!")
	end