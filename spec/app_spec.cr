require "./spec_helper"
require "http"

describe App do
  it "Hello, world!" do
    a = App.new
    a.get "/" do |req|
      ok("Hello, World")
    end
    (a.call HTTP::Request.new "GET", "/").body.should eq "Hello, World"
  end

  it "404" do
    (App.new.call HTTP::Request.new "GET", "/").status_code
      .should eq 404
  end

  it "calls request middleware" do
    app = App.new

    app.get "/", do |req|
      user = req.get["user"]
      ok("Hello, #{user}!")
    end
    app.request_middleware do |req|
      if req.get.has_key? "user"
        nil
      else
        Response.new 400, "No user"
      end
    end
    resp = app.call HTTP::Request.new "GET", "/?user=test"
    resp.status_code.should eq 200
    resp.body.should eq "Hello, test!"

    resp = app.call HTTP::Request.new "GET", "/"
    resp.status_code.should eq 400
  end
end