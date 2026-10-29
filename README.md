# wpe_webkit

Crystal bindings for [WPE WebKit](https://github.com/WebPlatformForEmbedded/WPEWebKit) 2.x, built on the WPE Platform API (`wpe-webkit-2.0`, `wpe-platform-2.0`).

## Requirements

- Crystal >= 1.22
- WPE WebKit >= 2.52 with WPE Platform (headless and/or Wayland backends)
- libsoup 3, GLib/GIO

Fedora: `dnf install wpewebkit-devel libsoup3-devel`

## Installation

```yaml
dependencies:
  wpe_webkit:
    github: shpeckman/wpe_webkit
```

```crystal
require "wpe_webkit"
```

## Threading model

WebKit and JavaScriptCore must run on the thread's native stack, so the GLib main loop is driven **from the main fiber**:

- `WPEWebKit.run` iterates the loop until `WPEWebKit.quit`.
- Blocking calls (`evaluate_javascript`, `snapshot`, cookie and website-data operations) iterate the loop themselves until their result arrives. You can call them at the top level, or from inside signal handlers.
- While the loop waits for events, a helper thread polls the GLib file descriptors and other Crystal fibers keep running.
- Call the WPEWebKit API from the main fiber only. Iterating from any other fiber raises `WPEWebKit::WrongFiberError`.
- `WPEWebKit::MainLoop.max_poll_interval` (default 10 ms) caps how long a single poll waits.

Signal handlers run on the main fiber during dispatch. If a handler raises, the exception is printed to STDERR and the handler returns its default (`false` / `nil`).

## Quick start

```crystal
require "wpe_webkit"

view = WPEWebKit::WebView.new(display: WPEWebKit::Display.headless)

view.on_load_changed do |event|
  if event.finished?
    puts view.title
    puts view.evaluate_javascript("document.querySelectorAll('a').length").to_i
    WPEWebKit.quit
  end
end

view.load_uri("https://example.com")
WPEWebKit.run
```

## API

### Displays and toplevels

```crystal
WPEWebKit::Display.default            # Display? (platform picks wayland/drm/headless)
WPEWebKit::Display.headless           # offscreen
WPEWebKit::Display.wayland            # connects to $WAYLAND_DISPLAY, or pass a name
display.primary!                      # make it the primary display
display.connect                       # raises GLibError on failure

if toplevel = view.toplevel
  toplevel.title = "Kiosk"
  toplevel.resize(1280, 720)
  toplevel.fullscreen
  toplevel.state                      # ToplevelState flags
end
view.size                             # {width, height}
```

### WebView

```crystal
view = WPEWebKit::WebView.new(
  display: display,
  network_session: session,
  settings: settings,
  user_content_manager: manager,
  web_context: WPEWebKit::WebContext.default,
  related_view: other_view,
)
```

Every argument is optional.

| Group | Methods |
| --- | --- |
| Loading | `load_uri`, `load_html(content, base_uri)`, `load_alternate_html`, `load_plain_text`, `load_bytes(data, mime_type, encoding, base_uri)`, `load_request(URIRequest)`, `reload`, `reload_bypass_cache`, `stop_loading` |
| History | `go_back`, `go_forward`, `can_go_back?`, `can_go_forward?` |
| State | `title`, `uri`, `loading?`, `estimated_load_progress`, `page_id`, `playing_audio?`, `web_process_responsive?`, `theme_color` |
| Properties | `settings`, `settings=`, `zoom_level`, `zoom_level=`, `muted?`, `muted=`, `editable?`, `editable=`, `custom_charset`, `custom_charset=`, `background_color`, `background_color=`, `cors_allowlist=` |
| JavaScript | `evaluate_javascript(script, world:, source_uri:) : JSValue` (raises `GLibError` on JS exceptions) |
| Other | `snapshot(region, options) : Image`, `download(uri) : Download`, `execute_editing_command(command, argument)`, `can_show_mime_type?`, `find_controller`, `user_content_manager`, `network_session`, `web_context`, `display`, `toplevel`, `try_close`, `terminate_web_process` |

#### Signals

Every signal method returns a handler id, which you pass to `view.disconnect(id)`. Handlers whose return type is `Bool` must return `true` when they handled the event.

| Method | Block |
| --- | --- |
| `on_load_changed` | `LoadEvent -> Nil` |
| `on_load_failed` | `LoadEvent, String, GLibError -> Bool` |
| `on_decide_policy` | `PolicyDecision, PolicyDecisionType -> Bool` |
| `on_create` | `NavigationAction -> WebView?` (create the new view with `related_view:`) |
| `on_ready_to_show`, `on_close` | `-> Nil` |
| `on_script_dialog` | `ScriptDialog -> Bool` |
| `on_permission_request` | `PermissionRequest -> Bool` |
| `on_enter_fullscreen`, `on_leave_fullscreen` | `-> Bool` |
| `on_insecure_content_detected` | `InsecureContentEvent -> Nil` |
| `on_web_process_terminated` | `WebProcessTerminationReason -> Nil` |
| `on_title_changed`, `on_uri_changed` | `String? -> Nil` |
| `on_estimated_load_progress_changed` | `Float64 -> Nil` |
| `on_loading_changed` | `Bool -> Nil` |

### Policy decisions

```crystal
view.on_decide_policy do |decision, type|
  case decision
  when WPEWebKit::NavigationPolicyDecision
    decision.request.uri.starts_with?("https://") ? decision.use : decision.ignore
  when WPEWebKit::ResponsePolicyDecision
    decision.mime_type_supported? ? decision.use : decision.download
  end
  true
end
```

- `NavigationAction`: `navigation_type`, `request`, `mouse_button`, `modifiers`, `user_gesture?`, `redirect?`, `frame_name`
- `URIRequest`: `URIRequest.new(uri)`, `uri`, `uri=`, `http_method`, `headers : HTTP::Headers`
- `URIResponse`: `uri`, `status_code`, `content_length`, `mime_type`, `suggested_filename`, `headers`

### JavaScript values

`JSValue`:

- Type checks: `undefined?`, `null?`, `number?`, `boolean?`, `string?`, `array?`, `object?`, `function?`
- Conversions: `to_s`, `to_i`, `to_f`, `to_bool`, `to_json(indent)`, `as_json : JSON::Any`
- Construction: `JSValue.from_json(context, json)`

`evaluate_javascript` cannot return a Promise. Wrap async code so that it returns a plain value.

### Settings

```crystal
settings = WPEWebKit::Settings.new(enable_developer_extras: true, user_agent: "MyApp/1.0")
settings.enable_webgl = false
settings.enable_webgl?        # Bool getters end in ?
settings.default_font_size    # UInt32
```

All `WebKitSettings` GObject properties are exposed, with dashes replaced by underscores (`enable-html5-local-storage` → `enable_html5_local_storage`). Unknown keys passed to `Settings.new` fail at compile time.

### User content and script messages

```crystal
manager = WPEWebKit::UserContentManager.new
manager.add_script(WPEWebKit::UserScript.new("console.log('hi')", injection_time: :document_start))
manager.add_style_sheet(WPEWebKit::UserStyleSheet.new("body { margin: 0 }", level: :author))

manager.on_script_message("bridge") do |value|
  pp value.as_json
end

manager.on_script_message_with_reply("rpc") do |value, reply|
  reply.return_value({result: value.to_i * 2})
end

view = WPEWebKit::WebView.new(user_content_manager: manager)
```

JavaScript side: `window.webkit.messageHandlers.bridge.postMessage({...})`. A reply handler returns a Promise there.

- `UserScript.new` / `UserStyleSheet.new` take `injected_frames:`, `world:`, `allow_list:` and `block_list:`.
- `remove_script`, `remove_all_scripts`, `remove_style_sheet`, `remove_all_style_sheets` and `unregister_script_message_handler` remove what you added.
- `reply.return_value(value)` takes any JSON-serializable value. `reply.return_error(message)` rejects the Promise.

### Custom URI schemes

```crystal
WPEWebKit::WebContext.default.register_uri_scheme("app") do |request|
  case request.path
  when "/" then request.finish("<h1>Home</h1>", "text/html")
  else          request.finish_error("not found", 404)
  end
end
```

- `URISchemeRequest`: `scheme`, `uri`, `path`, `http_method`, `headers`, `body : Bytes?`, `web_view`
- `finish(body, content_type, status:, reason:, headers:)`, `finish_error(message, code)`
- `WebContext` also has `cache_model`, `cache_model=`, `spell_checking_enabled?`, `spell_checking_enabled=`, `spell_checking_languages=`, `preferred_languages=` and `add_path_to_sandbox`.

### Network sessions, cookies, website data

```crystal
session = WPEWebKit::NetworkSession.new("/tmp/data", "/tmp/cache")
session = WPEWebKit::NetworkSession.ephemeral
session = WPEWebKit::NetworkSession.default

session.tls_errors_policy = :fail
session.itp_enabled = true
session.proxy(:custom, "http://proxy:3128", ignore_hosts: ["localhost"], schemes: {"https" => "http://proxy:3129"})
session.prefetch_dns("example.com")
session.on_download_started { |download| download.destination = "/tmp/file" }

cookies = session.cookie_manager
cookies.accept_policy = :no_third_party
cookies.accept_policy                                    # CookieAcceptPolicy
cookies.persistent_storage("/tmp/cookies.sqlite", :sqlite)
cookies.add(HTTP::Cookie.new("token", "abc", domain: "example.com"))
cookies.cookies("https://example.com/")                  # Array(HTTP::Cookie)
cookies.all
cookies.delete(cookie)
cookies.replace([cookie_a, cookie_b])

data = session.website_data_manager
data.fetch(:cookies | :local_storage)                    # Array(WebsiteData): name, types, size
data.remove(entries, :all)
data.clear(:all, since: 1.hour)
```

Cookies map to `HTTP::Cookie`. A cookie you add needs a `domain`. Cookies whose name or value `HTTP::Cookie` rejects are left out of the results.

### Downloads

`Download`:

- Accessors: `request`, `response`, `destination`, `destination=`, `allow_overwrite?`, `allow_overwrite=`, `estimated_progress`, `elapsed_time`, `received_data_length`, `web_view`, `cancel`
- Signals: `on_received_data(UInt64)`, `on_finished`, `on_failed(GLibError)`, `on_decide_destination(String) -> Bool`, `on_created_destination(String)`

### Find controller

```crystal
finder = view.find_controller
finder.on_counted_matches { |count| puts count }
finder.on_found_text { |count| }
finder.on_failed_to_find_text { }
finder.search("needle", :case_insensitive | :wrap_around)
finder.count_matches("needle")
finder.search_next
finder.search_previous
finder.finish
```

### Script dialogs and permissions

```crystal
view.on_script_dialog do |dialog|
  dialog.confirmed = true if dialog.type.confirm?
  dialog.text = "answer" if dialog.type.prompt?
  true
end

view.on_permission_request do |request|
  request.kind.geolocation? ? request.allow : request.deny
  true
end
```

### Snapshots and colors

`view.snapshot(:full_document)` returns an `Image`. `width`, `height` and `stride` describe it, and `bytes` holds the pixels in BGRA8888.

`Color.parse("#ff8800")` returns `Color(red, green, blue, alpha)`.

### Errors

Every GLib `GError` becomes a `WPEWebKit::GLibError`, with `domain`, `code` and `message`.

## Development

```sh
crystal spec          # runs against a headless display
crystal tool format
ameba
```

## License

MIT
