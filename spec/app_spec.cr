require "./spec_helper"
require "http"

describe BaseHTTPHandler do
	it "returns 404" do 
		handler = BaseHTTPHandler.new ([] of Moonshine::Route)
		req = HTTP::Request.new("GET", "/")
		res = handler.call(req)
		res.status_code.should eq (404)
	end

	it "handles get request" do
		callable = EmptyCallable.new("hello")
		handler = BaseHTTPHandler.new ([
			Route.new("GET", "/", callable)
			] of Moonshine::Route)
		req = HTTP::Request.new("GET", "/")
		res = handler.call(req)
		res.status_code.should eq (200)
		res.body.should eq("hello")
	end

	it "returns static file" do
		handler = BaseHTTPHandler.new([] of Route,
			["spec/res"])
		req = HTTP::Request.new("GET", "/static.txt")
		res = handler.call(req)
		res.status_code.should eq(200)
		res.body.should eq("hello")
	end
end