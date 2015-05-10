require "./spec_helper"
require "http"

describe Request do
  it "parses query params" do
    request = Request.new HTTP::Request.new("GET", "/?val1=12&val2=this+is+a+query+string+%26%25\
      &val3=%21@%23%24%25%5E%26*%28%29")
    request.path.should eq("/")
    request.get["val1"].should eq("12")
    request.get["val2"].should eq("this is a query string &%")
    request.get["val3"].should eq("!@#$%^&*()")
  end
  it "parses value only param" do
    request = Request.new HTTP::Request.new("GET", "/?a")
    request.path.should eq("/")
    request.get["a"].should eq("")
  end
end

describe Response do
end