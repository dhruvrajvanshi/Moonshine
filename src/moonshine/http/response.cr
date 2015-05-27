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
