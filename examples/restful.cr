require "../src/moonshine"
include Moonshine::Utils::Shortcuts
include Moonshine::Base

class PostController < Controller
  actions :get_all, :create, :get, :delete
  @router = {
    "GET /posts" => "get_all",
    "POST /posts" => "create",
    "GET /posts/:id" => "get",
    "DELETE /posts/:id" => "delete"
  }
  def initialize
    @posts = [] of Post
  end

  def create(req)
    unless req.post.has_key?("text")
      return Response.new(400,
        "{message : Unable to create " +
        "post without POST param 'text'. }"
        )
    end
    post = Post.new req.post["text"]
    @posts << post
    Response.new(201,
      "{ message : 'Post created successfully' }",
    )
  end

  def get_all(req : Request)
    ok(post_array_to_json(@posts))
  end


  def get(req : Request)
    id = req.params["id"].to_i
    @posts.each do |post|
      if post.id == id
        return Response.new(200,
          post.to_s)
      end
    end
    return not_found("{ message : 'Post id #{id} not found on the server'}")
  end

  def delete(req : Request)
    id = req.params["id"].to_i
    @posts.delete_if {|post| post.id == id }
    return ok("{message : Post #{id} deleted }")
  end
end

def post_array_to_json(posts)
  if posts.length == 0 return "[]" end
  out_string = "["
  posts.each do |post|
    out_string += post.to_s + ","
  end
  out_string = out_string[0..-2]
  out_string += "]"
  out_string
end

class Post
  getter id
  getter text

  @@postcount = 0
  def initialize(@text)
    @@postcount += 1
    @id = @@postcount
  end

  def to_s
    "{ id : #{@id}, text : #{@text} }"
  end
end

app = App.new  # Instantiate app
postCtrl = PostController.new # Instantiate controller

app.controller(postCtrl)
# Globally set response type to json
app.response_middleware do |req, res|
  res.set_header("Content-type", "text/json")
  res
end

app.run()
