require "./spec_helper"
require "http"

describe Request do
  it "parses query params" do
    request = Request.new HTTP::Request.new("GET", "/?val1=12&val2=this+is+a+query+string+%26%25&val4=.~-_\
      &val3=%21@%23%24%25%5E%26*%28%29")
    request.path.should eq("/")
    request.get["val1"].should eq("12")
    request.get["val2"].should eq("this is a query string &%")
    request.get["val3"].should eq("!@#$%^&*()")
    request.get["val4"].should eq(".~-_")
  end
  
  it "parses value only query param" do
    request = Request.new HTTP::Request.new("GET", "/?abc&xyz")
    request.path.should eq("/")
    request.get["abc"].should eq("")
    request.get["xyz"].should eq("")
  end
  
  it "parses query param of form =a" do
    request = Request.new HTTP::Request.new("GET", "/?=abc=y")
    request.path.should eq("/")
    request.get.fetchAll("").should eq(["abc=y"])
  end
  it "parses POST params" do
    head = HTTP::Headers.new
    head["Content-type"] = "application/x-www-form-urlencoded"
    request = Request.new HTTP::Request.new("GET", "/", headers=head, body="a=abc&b=pqr")
    request.path.should eq("/")
    request.post["a"].should eq("abc")
    request.post["b"].should eq("pqr")
    begin
      a = request.post["adsfasdf"]
    rescue Moonshine::Exceptions::KeyNotFound
      a = "blank"
    end
    a.should eq "blank"
  end
end

describe Response do
end