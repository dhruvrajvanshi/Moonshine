require "http"
require "time"

module Moonshine::Http
  METHODS = %w(GET POST PUT DELETE PATCH)


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
      @path = request.path
      @method = request.method
      @version = request.version
      @body    = request.body
      @headers = request.headers
      @params = {} of String => String
      @cookies = {} of String => String
      @get = ParameterHash.new
      @post = ParameterHash.new
      parse_cookies()
      parse_get_params()
      parse_post_params()
    end

    def content_type()
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

    private def parse_cookies()
      if @headers.has_key? "Cookie"
        @headers["Cookie"].split(";").each do |cookie|
          key = cookie.strip().split("=")[0]
          value = cookie.strip().split("=")[1]
          @cookies[key] = value
        end
      end
    end

    private def parse_get_params()
      if @path.split("?").length > 1
        # ignore everything after second ?
        query_string = @path.split("?")[1]
        @query_string = query_string
        @path = @path.split("?")[0]
        populate_params_hash(@get, query_string)
      end
    end

    private def parse_post_params()
      if content_type.downcase == "application/x-www-form-urlencoded"
        populate_params_hash(@post, body)
      end
    end

    private def populate_params_hash(hash, query_string)
      query_string.split("&").each do |parameter|
          if m = /^(?<key>[^=]*)(=(?<value>.*))?$/.match(parameter)
            key = decode_query_param(m["key"])
            value = decode_query_param(m["value"])
            hash.add(key, value)
          end
        end
    end



    ##
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

  class Response
    getter status_code
    getter body
    setter body
    getter headers
    getter cookies
    setter cookies

    def initialize(@status_code, @body, @headers = HTTP::Headers.new, @version = "HTTP/1.1", @cookies = {} of String => String)
    end

    def set_header(key, value)
      @headers[key] = value
    end


    def to_base_response()
      # unless @cookies.empty?
      #   cookie_string = serialize_cookies()
      #   @headers["Set-Cookie"] = cookie_string
      # end
      return HTTP::Response.new(@status_code, @body,
        headers = @headers, version = @version)
    end

    # TODO : Add expiry
    def set_cookie(key, value, @secure = false, @http_only = false)
      cookie_string = "#{key}=#{value}"
      if @secure
        cookie_string += "; secure"
      end
      if @http_only
        cookie_string += "; HttpOnly"
      end
      headers.add("Set-Cookie", cookie_string)
    end
  end

  class Moonshine::MiddlewareResponse
    ##
    # Return type for request middleware
    # if @pass_through is true the next middleware
    # will be called. Otherwise, Response will be
    # returned

    getter response
    getter pass_through

    def initialize(@response = Response.new(200, "Ok"),
      @pass_through = true)
    end
  end

  struct ParameterHash
    # ParameterHash is a hash that stores an array
    # of strings mapped to each key
    # To get the first value, call [] or fetch
    # To get the array, call fetchAll
    def initialize
      @hash = {"" => [] of String} of String => Array(String)
    end

    def []=(key, value : String)
      self[key] = [value]
    end

    def [](key)
      fetch key
    end

    def []?(key)
      @hash[key]?
    end

    def add(key, value : String)
      existing = @hash[key]?
      if existing
        existing << value
      else
        @hash[key] = [value]
      end
      self
    end

    def fetch(key)
      values = @hash[key]?
      if values
        values[0]
      else
        nil
      end
    end

    def fetch(key, default)
      fetch(key) { default }
    end

    def has_key?(key)
      @hash.has_key? key
    end

    def empty?
      @hash.empty?
    end

    def fetchAll(key)
      @hash[key]
    end

    def get?(key)
      @hash[key]?
    end

    def to_s(io : IO)
      io << "Moonshine::ParameterHash"
      @hash.to_s(io)
    end

    forward_missing_to @hash
  end
end
