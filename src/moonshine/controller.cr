abstract class Moonshine::Controller
	# Returns a response object with HTTP Okay
	# status code
	def ok(string)
		return Moonshine::Response.new(200, string)
	end
end