require "./spec_helper"
require "http"


describe Route do
  it "matches root path" do
    route = Route.new "GET", "/"
    route.match?(new_request("GET", "/")).should eq(true)
  end

  it "fails on non matching verb" do
    route = Route.new "GET", "/"
    route.match?(new_request("POST", "/")).should eq(false)
  end

  # required for controllers
  it "matches all verbs when method is blank" do
    route = Route.new "", "/hello"
    route.match?(new_request("GET", "/hello")).should eq(true)
    route.match?(new_request("POST", "/hello")).should eq(true)
    route.match?(new_request("PATCH", "/hello")).should eq(true)
    route.match?(new_request("PUT", "/hello")).should eq(true)
    route.match?(new_request("DELETE", "/hello")).should eq(true)
  end

  it "matches /hello" do
    route = Route.new "GET", "/hello"
    route.match?(new_request("GET", "/hello")).should eq(true)
  end

  it "fails on non matching path" do
    route = Route.new "GET", "/hello"
    route.match?(new_request("GET", "/x")).should eq(false)
  end

  it "parses parameters from request" do
    route = Route.new "GET", "/hello/:id"
    route.get_params(
        new_request("GET", "/hello/1")
      )["id"].should eq("1")
    route.get_params(
        new_request("GET", "/hello/abc")
      )["id"].should eq("abc")
  end
end

