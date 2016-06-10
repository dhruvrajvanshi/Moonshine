# Moonshine [![Build Status](https://travis-ci.org/dhruvrajvanshi/Moonshine.svg?branch=master)](https://travis-ci.org/dhruvrajvanshi/Moonshine)
Notice: This repository is no longer maintained.
[Kemal](https://github.com/sdogruyol/kemal) does pretty
much what Moonshine does and it has better documentation.


Moonshine is a minimal sinatra like web framework for the Crystal language.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  moonshine:
    github: dhruvrajvanshi/Moonshine
```

## Usage

Code speaks louder than words, so here's an example.

```crystal
require "moonshine"

include Moonshine
include Moonshine::Utils::Shortcuts
include Moonshine

app = App.new

# respond to all HTTP verbs
app.route "/", do |request|
  ok("Hello Moonshine!")
end

# or particular HTTP verbs
app.get "/get", do |request|
  ok("This is a get response")
end

# you can set response headers
app.get "/api", do |request|
  res = ok("{\"name\": \"moonshine\"}")
  res.headers["Content-type"] = "text/json"
  res
end

app.run(8000)
```

## Form Parameters
Moonshine automatically parses POST and GET parameters for you. The `get` and `post` properties are hashes of these params.

```crystal
app.get "/putparams", do |request|
  ok("<h1>POST<h1><p>#{request.post}</p><h2>GET<h2><p>#{request.get}</p>")
end
```

## Controllers
Controllers are objects which can respond to multiple routes. Set the @rotuer instance variable of a controller to specify routing within controller. Add the controller to the app using app.controller method.
@router maps between a route and an action. Action can be any object with a call method (usually a Proc).
```crystal
# Inherit from Moonshine::Controller to define a controller
class HomeController < Moonshine::Controller
  def initialize()
    @viewcount = 0
    @router = {
      "GET /" => ->get(Request),
    }
  end

  def get(req)
    @viewcount += 1
    ok("This page has been visited #{@viewcount} times.")
  end
end

# Bind controller to the app object
app.controller "/", HomeController.new
```

An action can also be a string containing the method name provided that the method is defined in the controller, and the controller name symbol has been passed to the actions macro in the controller definition.
```crystal
class PostController < Moonshine::Controller
  actions :get_all_posts, :get_post
  def initialize()
    @posts = [
          Post.new("Post1"),
          Post.new("Post2")
         ] of Post
    @router = {
      "GET /posts" =>"get_all_posts",
      "GET /posts/:id" => "get_post"
    }
  end

  def get_post(req)
    ...
  end

  def get_all_posts(req)
    ...
  end
end

app.controller(PostController.new)
```
String and proc actions can also be mixed in a single router.

## Middleware
You can either create [middleware classes](#middleware_classes) or individual methods that process [request](#request_middleware) or [response](#response_middleware)
### Middleware Classes<a name="middleware_classes"></a>
You can add middleware classes to your application by inheriting from Moonshine::Middleware. Your class can override process_request and process_response methods to globally alter request and response objects.
```crystal
class Hello < Moonshine::Middleware
  def process_request(req)
    req.headers["User"] = "Annonymous"
  end

  def process_response(req, res)
    req.body += "\nFooter"
  end
end
app.middleware_object Hello.new
```

### Request Middleware<a name="request_middleware"></a>
```crystal
# add request middleware
app.request_middleware do |req|
  unless req.get.has_key? "user"
    Moonshine::Http::Response.new(200, "Not allowed")
  else
    nil
  end
end
```

To add a request middleware, call app.request_middleware with a block that returns a response or nil. If the method returns nil, the response chain continues, otherwise, the response is sent back.

### Response Middleware<a name="response_middleware"></a>
```crystal
# add response middleware
app.response_middleware do |req, res|
  res.body = "Modified"
  res
end
```
Response middleware methods take request and response arguments and return a response. This is used to globally alter the response of the application. Response middleware are processed in order.


## Changelog
```
0.3.0 : Renamed base module to core.
        Aliased Moonshine::App = Moonshine::Core::App (Previously Moonshine::Base::App)
        Aliased Moonshine::Controller = Moonshine::Core::Controller
        Moved Moonshine::Middleware::Base => Moonshine::Core::Middleware
        Aliased Moonshine::Middleware = Moonshine::Core::Middleware
        Added Moonshine::Utils::StaticDirs middleware class. It can serve multiple directories
```