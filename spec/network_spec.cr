# spec/network_spec.cr
require "./spec_helper"

WPEWebKit::WebContext.default.register_uri_scheme("crystal") do |request|
  if request.path == "/missing"
    request.finish_error("not found", 404)
  else
    request.finish("<title>#{request.path}</title>", "text/html", headers: HTTP::Headers{"X-Test" => "1"})
  end
end

describe WPEWebKit::WebContext do
  it "serves custom uri schemes" do
    view = new_view
    wait_for_load(view) { view.load_uri("crystal://app/page") }
    iterate_until { view.title == "/page" }.should be_true
  end

  it "reports custom uri scheme errors" do
    view = new_view
    failure = nil
    view.on_load_failed { |_event, _uri, error| failure = error.message; true }
    view.load_uri("crystal://app/missing")
    iterate_until { !failure.nil? }.should be_true
    failure.should eq("not found")
  end
end

describe WPEWebKit::NetworkSession do
  it "manages cookies in an ephemeral session" do
    session = WPEWebKit::NetworkSession.ephemeral
    session.ephemeral?.should be_true
    cookies = session.cookie_manager
    cookies.accept_policy = :always
    cookies.accept_policy.should eq(WPEWebKit::CookieAcceptPolicy::Always)
    cookies.add(HTTP::Cookie.new("token", "abc", domain: "example.test", path: "/"))
    cookies.cookies("https://example.test/").map(&.name).should contain("token")
    cookies.delete(HTTP::Cookie.new("token", "abc", domain: "example.test", path: "/"))
    cookies.all.map(&.name).should_not contain("token")
  end

  it "fetches and clears website data" do
    session = WPEWebKit::NetworkSession.ephemeral
    manager = session.website_data_manager
    manager.ephemeral?.should be_true
    manager.clear
    manager.fetch(:cookies).should be_a(Array(WPEWebKit::WebsiteData))
  end
end
