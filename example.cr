require "./src/moonshine"
include Moonshine
include Moonshine::Shortcuts

viewcount = 0

app = Moonshine::App.new
app.route "/", do |request|
	ok("Hello Moonshine!")
end

app.run()