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
end