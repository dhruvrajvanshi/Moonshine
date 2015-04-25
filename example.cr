require "./src/moonshine"
include Moonshine

viewcount = 0

app = Moonshine::App.new
app.route "/", do |request|
	Moonshine::Response.new(200, "Hello Moonshine!")
end

app.run()