class Moonshine::Route
	# Moonshine route class
	# Is a simple 2-tuple of a regex and a 
	# controller class name

	getter controller
	getter pattern
	def initialize(@pattern, @controller)
		# strip trailing slash
		unless @pattern == "/" 
			@pattern = @pattern.gsub(/\/$/, "")
		end
	end

	def match?(path)
		return path == "/" if @path == "/"
		return false if path.split("/").length !=
			@pattern.split("/").length
		regex = Regex.new(@pattern.to_s.gsub(/(:\w*)/, ".*"))
		path.match(regex)
	end

	def get_params(path)
		params = {} of String => String
		path_items = path.split("/")
		pattern_items = @pattern.split("/")
		path_items.length.times do |i|
			if pattern_items[i].match(/(:\w*)/)
				params[pattern_items[i].gsub(/:/, "")] = path_items[i]
			end
		end
		return params
	end
end