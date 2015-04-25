# Moonshine
Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example

    class HelloController < Moonshine::Controller
	    def handle(request)
		    name = request.params["name"]
		    return ok("Hello #{name}")
	    end
    end

    app = Moonshine::App.new
    app.route("/", HelloController)
    app.run(port=8080)

Note that the controller needs to have a method named handle which returns a Moonshine::Response, otherwise the web server won't know which method to call.
