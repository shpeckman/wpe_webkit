require "../src/wpe_webkit"
include WPEWebKit
s = Settings.new(enable_developer_extras: true, user_agent: "x", default_font_size: 12_u32)
p s.enable_developer_extras?, s.user_agent, s.default_font_size
v = WebView.new(display: Display.headless, settings: s)
v.on_load_changed { |e| p e }
v.on_load_failed { |e, u, err| false }
v.on_create { |a| nil }
v.on_decide_policy { |d, t| d.use; true }
v.on_title_changed { |t| p t }
v.on_loading_changed { |t| p t }
v.on_permission_request { |r| r.deny; true }
v.on_script_dialog { |d| true }
v.on_enter_fullscreen { false }
v.on_close { }
ucm = v.user_content_manager
ucm.on_script_message("m") { |x| p x.as_json }
ucm.on_script_message_with_reply("r") { |x, r| r.return_value({ok: 1}) }
ucm.add_script(UserScript.new("1"))
ucm.add_style_sheet(UserStyleSheet.new("p{}"))
WebContext.default.register_uri_scheme("app") { |r| r.finish("hi") }
ns = v.network_session
ns.on_download_started { |d| d.on_failed { |e| p e }; d.on_decide_destination { |f| true } }
ns.cookie_manager.accept_policy = :always
fc = v.find_controller
fc.on_found_text { |n| p n }
v.load_html("<title>x</title>")
p v.evaluate_javascript("1+1").to_i
p v.snapshot.width
p ns.cookie_manager.all
p ns.website_data_manager.fetch
p Color.parse("red")
v.toplevel.try &.title = "t"
