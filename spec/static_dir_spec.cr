require "http"
include Moonshine::Utils

it "static dir test" do
  app = App.new
  app.middleware_object (StaticDirs.new "res", "spec/res")
  res = app.call HTTP::Request.new "GET", "/res/static.txt"
  res.body.should eq "hello"

  res = app.call HTTP::Request.new "GET", "/res/"
  res.status_code.should eq 404
end
