# spec/web_view_spec.cr
require "./spec_helper"

describe WPEWebKit::WebView do
  it "loads html and reports title changes" do
    view = new_view
    titles = [] of String?
    view.on_title_changed { |title| titles << title }
    wait_for_load(view) { view.load_html("<title>Hello</title><p>body</p>", "https://example.test/") }
    iterate_until { view.title == "Hello" }.should be_true
    titles.should contain("Hello")
    view.uri.should eq("https://example.test/")
    view.loading?.should be_false
  end

  it "evaluates javascript into typed values" do
    view = new_view
    wait_for_load(view) { view.load_html("<p id='x'>text</p>") }
    view.evaluate_javascript("21 * 2").to_i.should eq(42)
    view.evaluate_javascript("document.getElementById('x').textContent").to_s.should eq("text")
    view.evaluate_javascript("({a: [1, 2], b: 'c'})").as_json.should eq(JSON.parse(%({"a": [1, 2], "b": "c"})))
    view.evaluate_javascript("undefined").undefined?.should be_true
  end

  it "raises GLibError on javascript exceptions" do
    view = new_view
    wait_for_load(view) { view.load_html("<p></p>") }
    expect_raises(WPEWebKit::GLibError, /boom/) { view.evaluate_javascript("throw new Error('boom')") }
  end

  it "decides navigation policy" do
    view = new_view
    seen = [] of String
    view.on_decide_policy do |decision, type|
      if type.navigation_action? && (navigation = decision.as?(WPEWebKit::NavigationPolicyDecision))
        seen << navigation.request.uri
      end
      decision.use
      true
    end
    wait_for_load(view) { view.load_html("<p></p>", "https://policy.test/") }
    seen.should contain("https://policy.test/")
  end

  it "takes snapshots" do
    view = new_view
    wait_for_load(view) { view.load_html("<body style='background:red'></body>") }
    image = view.snapshot
    image.width.should be > 0
    image.height.should be > 0
    image.bytes.size.should eq(image.stride.to_i * image.height)
  end

  it "counts find matches" do
    view = new_view
    wait_for_load(view) { view.load_html("<p>apple apple apple</p>") }
    count = nil
    view.find_controller.on_counted_matches { |matches| count = matches }
    view.find_controller.count_matches("apple", :case_insensitive)
    iterate_until { !count.nil? }.should be_true
    count.should eq(3)
  end

  it "applies settings" do
    settings = WPEWebKit::Settings.new(enable_javascript: false, user_agent: "CrystalSpec/1.0", default_font_size: 20_u32)
    settings.enable_javascript?.should be_false
    settings.user_agent.should eq("CrystalSpec/1.0")
    settings.default_font_size.should eq(20)
    view = new_view(settings: settings)
    view.settings.user_agent.should eq("CrystalSpec/1.0")
  end

  it "round-trips background color" do
    view = new_view
    view.background_color = WPEWebKit::Color.parse("#00ff00")
    view.background_color.green.should eq(1.0)
  end
end
