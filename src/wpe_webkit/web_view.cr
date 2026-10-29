# src/wpe_webkit/web_view.cr
module WPEWebKit
  class WebView < GObject
    def self.new(*, display : Display? = nil, network_session : NetworkSession? = nil, settings : Settings? = nil, user_content_manager : UserContentManager? = nil, web_context : WebContext? = nil, related_view : WebView? = nil) : self
      take(GObject.construct(C.webkit_web_view_get_type, {
        "display"              => display,
        "network-session"      => network_session,
        "settings"             => settings,
        "user-content-manager" => user_content_manager,
        "web-context"          => web_context,
        "related-view"         => related_view,
      } of String => Wrapper?))
    end

    def display : Display?
      Display.from_raw?(C.webkit_web_view_get_display(self), owner: self)
    end

    def toplevel : Toplevel?
      view = C.webkit_web_view_get_wpe_view(self)
      Toplevel.from_raw?(C.wpe_view_get_toplevel(view), owner: self) unless view.null?
    end

    def size : {Int32, Int32}
      view = C.webkit_web_view_get_wpe_view(self)
      view.null? ? {0, 0} : {C.wpe_view_get_width(view), C.wpe_view_get_height(view)}
    end

    def network_session : NetworkSession
      NetworkSession.from_raw(C.webkit_web_view_get_network_session(self))
    end

    def web_context : WebContext
      WebContext.from_raw(C.webkit_web_view_get_context(self))
    end

    def settings : Settings
      Settings.from_raw(C.webkit_web_view_get_settings(self))
    end

    def settings=(settings : Settings)
      C.webkit_web_view_set_settings(self, settings)
    end

    def user_content_manager : UserContentManager
      UserContentManager.from_raw(C.webkit_web_view_get_user_content_manager(self))
    end

    def find_controller : FindController
      FindController.from_raw(C.webkit_web_view_get_find_controller(self), owner: self)
    end

    def load_uri(uri : String) : Nil
      C.webkit_web_view_load_uri(self, uri)
    end

    def load_html(content : String, base_uri : String? = nil) : Nil
      C.webkit_web_view_load_html(self, content, Native.string(base_uri))
    end

    def load_alternate_html(content : String, content_uri : String, base_uri : String? = nil) : Nil
      C.webkit_web_view_load_alternate_html(self, content, content_uri, Native.string(base_uri))
    end

    def load_plain_text(text : String) : Nil
      C.webkit_web_view_load_plain_text(self, text)
    end

    def load_bytes(data : Bytes | String, mime_type : String? = nil, encoding : String? = nil, base_uri : String? = nil) : Nil
      bytes = Native.bytes(data)
      C.webkit_web_view_load_bytes(self, bytes, Native.string(mime_type), Native.string(encoding), Native.string(base_uri))
      C.g_bytes_unref(bytes)
    end

    def load_request(request : URIRequest) : Nil
      C.webkit_web_view_load_request(self, request)
    end

    def stop_loading : Nil
      C.webkit_web_view_stop_loading(self)
    end

    def reload : Nil
      C.webkit_web_view_reload(self)
    end

    def reload_bypass_cache : Nil
      C.webkit_web_view_reload_bypass_cache(self)
    end

    def go_back : Nil
      C.webkit_web_view_go_back(self)
    end

    def go_forward : Nil
      C.webkit_web_view_go_forward(self)
    end

    def can_go_back? : Bool
      C.webkit_web_view_can_go_back(self) != 0
    end

    def can_go_forward? : Bool
      C.webkit_web_view_can_go_forward(self) != 0
    end

    def loading? : Bool
      C.webkit_web_view_is_loading(self) != 0
    end

    def playing_audio? : Bool
      C.webkit_web_view_is_playing_audio(self) != 0
    end

    def muted? : Bool
      C.webkit_web_view_get_is_muted(self) != 0
    end

    def muted=(muted : Bool)
      C.webkit_web_view_set_is_muted(self, muted ? 1 : 0)
    end

    def editable? : Bool
      C.webkit_web_view_is_editable(self) != 0
    end

    def editable=(editable : Bool)
      C.webkit_web_view_set_editable(self, editable ? 1 : 0)
    end

    def web_process_responsive? : Bool
      C.webkit_web_view_get_is_web_process_responsive(self) != 0
    end

    def page_id : UInt64
      C.webkit_web_view_get_page_id(self)
    end

    def title : String?
      Native.string?(C.webkit_web_view_get_title(self))
    end

    def uri : String?
      Native.string?(C.webkit_web_view_get_uri(self))
    end

    def estimated_load_progress : Float64
      C.webkit_web_view_get_estimated_load_progress(self)
    end

    def custom_charset : String?
      Native.string?(C.webkit_web_view_get_custom_charset(self))
    end

    def custom_charset=(charset : String?)
      C.webkit_web_view_set_custom_charset(self, Native.string(charset))
    end

    def zoom_level : Float64
      C.webkit_web_view_get_zoom_level(self)
    end

    def zoom_level=(level : Float64)
      C.webkit_web_view_set_zoom_level(self, level)
    end

    def background_color : Color
      color = C::Color.new
      C.webkit_web_view_get_background_color(self, pointerof(color))
      Color.from_c(color)
    end

    def background_color=(color : Color)
      native = color.to_c
      C.webkit_web_view_set_background_color(self, pointerof(native))
    end

    def theme_color : Color?
      color = C::Color.new
      Color.from_c(color) if C.webkit_web_view_get_theme_color(self, pointerof(color)) != 0
    end

    def cors_allowlist=(patterns : Enumerable(String)?)
      C.webkit_web_view_set_cors_allowlist(self, Native.strv(patterns))
    end

    def can_show_mime_type?(mime_type : String) : Bool
      C.webkit_web_view_can_show_mime_type(self, mime_type) != 0
    end

    def execute_editing_command(command : String, argument : String? = nil) : Nil
      if argument
        C.webkit_web_view_execute_editing_command_with_argument(self, command, argument)
      else
        C.webkit_web_view_execute_editing_command(self, command)
      end
    end

    def download(uri : String) : Download
      Download.take(C.webkit_web_view_download_uri(self, uri))
    end

    def evaluate_javascript(script : String, *, world : String? = nil, source_uri : String? = nil) : JSValue
      Async.await(->(result : Void*, error : C::Error**) { JSValue.take(C.webkit_web_view_evaluate_javascript_finish(self, result, error)) }) do |callback, data|
        C.webkit_web_view_evaluate_javascript(self, script, script.bytesize, Native.string(world), Native.string(source_uri), nil, callback, data)
      end
    end

    def snapshot(region : SnapshotRegion = :visible, options : SnapshotOptions = :none) : Image
      Async.await(->(result : Void*, error : C::Error**) { Image.take(C.webkit_web_view_get_snapshot_finish(self, result, error)) }) do |callback, data|
        C.webkit_web_view_get_snapshot(self, region.value, options.value, nil, callback, data)
      end
    end

    def try_close : Nil
      C.webkit_web_view_try_close(self)
    end

    def terminate_web_process : Nil
      C.webkit_web_view_terminate_web_process(self)
    end

    signal load_changed, "load-changed", {event: LoadEvent}
    signal load_failed, "load-failed", {event: LoadEvent, uri: String, error: GLibError}, Bool
    signal create, "create", {action: NavigationAction}, WebView
    signal ready_to_show, "ready-to-show"
    signal close, "close"
    signal script_dialog, "script-dialog", {dialog: ScriptDialog}, Bool
    signal decide_policy, "decide-policy", {decision: PolicyDecision, type: PolicyDecisionType}, Bool
    signal permission_request, "permission-request", {request: PermissionRequest}, Bool
    signal enter_fullscreen, "enter-fullscreen", nil, Bool
    signal leave_fullscreen, "leave-fullscreen", nil, Bool
    signal insecure_content_detected, "insecure-content-detected", {event: InsecureContentEvent}
    signal web_process_terminated, "web-process-terminated", {reason: WebProcessTerminationReason}

    notify title, "title", String
    notify uri, "uri", String
    notify estimated_load_progress, "estimated-load-progress", Float64
    notify loading, "is-loading", Bool
  end
end
