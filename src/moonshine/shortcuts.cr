module Moonshine::Shortcuts
	
	# Returns a Moonshine::Response object
	# from string
	def ok(string)
		Moonshine::Response.new(200, string)
	end
end