require "./src/moonshine"
include Moonshine

class HomeController < Moonshine::Controller
	def initialize()
		@viewcount = 0
	end

	def handle(request)
		@viewcount += 1
		html = "
<html>
	<head><title>Moonshine!</title></head>
	<body>
		<h1>Yay! It Worked!</h1>
		#{request.body}
		<p>Time to drink some moonshine!</p>
		<hr>
		<h7>This page has been visited #{@viewcount} times</h7>
	</body>
</html>
		"
		return ok(html)
	end
end

class HelloController < Moonshine::Controller
	def handle(request)
		name = request.params["name"]
		return ok("Hello #{name}")
	end
end

class EchoController < Moonshine::Controller
	def handle(request)
		string = ""
		request.headers.each do |key, value|
			string += key + "\t" + value + "\n"
		end
		return ok(string)
	end
end

# class HelloController < Moonshine::Controller


app = Moonshine::App.new
app.add_route("/", HomeController)
app.add_route("/hello/:name", HelloController)
app.add_route("/echo", EchoController)
app.run()