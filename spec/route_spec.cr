require "./spec_helper"

describe Route do
	it "match root path" do
		route = Route.new("/", Object.new)
		route.match?("/").should eq(true)
	end
end