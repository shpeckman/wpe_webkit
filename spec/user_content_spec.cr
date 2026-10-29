# spec/user_content_spec.cr
require "./spec_helper"

describe WPEWebKit::UserContentManager do
  it "receives script messages" do
    manager = WPEWebKit::UserContentManager.new
    received = nil
    manager.on_script_message("bridge") { |value| received = value.as_json }
    view = new_view(user_content_manager: manager)
    wait_for_load(view) { view.load_html("<script>window.webkit.messageHandlers.bridge.postMessage({n: 7})</script>") }
    iterate_until { received }.should be_true
    received.should eq(JSON.parse(%({"n": 7})))
  end

  it "replies to script messages" do
    manager = WPEWebKit::UserContentManager.new
    manager.on_script_message_with_reply("echo") { |value, reply| reply.return_value({echo: value.to_i * 2}) }
    view = new_view(user_content_manager: manager)
    wait_for_load(view) { view.load_html("<p></p>") }
    view.evaluate_javascript("window.webkit.messageHandlers.echo.postMessage(21).then(r => window.result = r.echo)")
    iterate_until { view.evaluate_javascript("window.result").number? }.should be_true
    view.evaluate_javascript("window.result").to_i.should eq(42)
  end

  it "injects user scripts and style sheets" do
    manager = WPEWebKit::UserContentManager.new
    manager.add_script(WPEWebKit::UserScript.new("window.injected = 'yes'", injection_time: :document_start))
    manager.add_style_sheet(WPEWebKit::UserStyleSheet.new("p { color: rgb(1, 2, 3) }"))
    view = new_view(user_content_manager: manager)
    wait_for_load(view) { view.load_html("<p>x</p>") }
    view.evaluate_javascript("window.injected").to_s.should eq("yes")
    view.evaluate_javascript("getComputedStyle(document.querySelector('p')).color").to_s.should eq("rgb(1, 2, 3)")
  end
end
