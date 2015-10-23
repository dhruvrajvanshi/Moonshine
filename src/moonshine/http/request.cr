require "./parameter_hash"

module Moonshine::Http
  class Request
    getter params
    getter path
    getter method
    getter version
    property body
    property headers
    getter cookies
    getter get
    getter post
    getter query_string

    def initialize(request : HTTP::Request)
      @path = request.resource
      @method = request.method
      @version = request.version
      @body = request.body
      @headers = request.headers
      @params = {} of String => String
      @cookies = {} of String => String
      @get = ParameterHash.new
      @post = ParameterHash.new
      parse_cookies()
      parse_get_params()
      parse_post_params()
    end

    def content_type
      unless @headers.has_key? "Content-type"
        return ""
      end
      return @headers["Content-type"]
    end

    def set_params(par)
      @params = par
    end

    def body
      @body.to_s
    end

    private def parse_cookies
      if @headers.has_key? "Cookie"
        @headers["Cookie"].split(";").each do |cookie|
          m = /^(?<key>[^=]*)(=(?<value>.*))?$/.match(cookie) as Regex::MatchData
          key = m["key"]
          begin
            value = m["value"]
          rescue ArgumentError
            value = ""
          end
          @cookies[key] = value
        end
      end
    end

    private def parse_get_params
      if @path.split("?").size > 1
        # ignore everything after second ?
        query_string = @path.split("?")[1]
        @query_string = query_string
        @path = @path.split("?")[0]
        populate_params_hash(@get, query_string)
      end
    end

    private def parse_post_params
      if content_type.downcase == "application/x-www-form-urlencoded"
        populate_params_hash(@post, body)
      end
    end

    private def populate_params_hash(hash, query_string)
      query_string.split("&").each do |parameter|
        if m = /^(?<key>[^=]*)(=(?<value>.*))?$/.match(parameter)
          key = decode_query_param(m["key"])
          begin
            value = decode_query_param(m["value"])
          rescue ArgumentError
            value = ""
          end
          hash.add(key, value)
        end
      end
    end

    # #
    # Unescape query parameter value
    private def decode_query_param(string)
      # replace + with spaces
      string = string.gsub(/\+/, " ")
      out_string = ""
      state = 0
      hex_str = ""
      string.each_char do |char|
        if state == 1
          hex_str += char
          state = 2
        elsif state == 2
          hex_str += char
          out_string += hex_str.to_i(16).chr
          state = 0
        else
          if char == '%'
            state = 1
            hex_str = ""
          else
            out_string += char
          end
        end
      end
      out_string
    end
  end
end
