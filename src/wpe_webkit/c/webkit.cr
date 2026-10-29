# src/wpe_webkit/c/webkit.cr
module WPEWebKit
  @[Link(pkg_config: "wpe-webkit-2.0")]
  lib C
    struct Color
      red : Float64
      green : Float64
      blue : Float64
      alpha : Float64
    end

    alias URISchemeRequestCallback = Void*, Void* -> Void

    fun webkit_color_parse(color : Color*, color_string : UInt8*) : Int32

    fun webkit_web_view_get_type : GType
    fun webkit_web_view_get_display(web_view : Void*) : Void*
    fun webkit_web_view_get_wpe_view(web_view : Void*) : Void*
    fun webkit_web_view_get_network_session(web_view : Void*) : Void*
    fun webkit_web_view_get_context(web_view : Void*) : Void*
    fun webkit_web_view_try_close(web_view : Void*) : Void
    fun webkit_web_view_load_uri(web_view : Void*, uri : UInt8*) : Void
    fun webkit_web_view_load_html(web_view : Void*, content : UInt8*, base_uri : UInt8*) : Void
    fun webkit_web_view_load_alternate_html(web_view : Void*, content : UInt8*, content_uri : UInt8*, base_uri : UInt8*) : Void
    fun webkit_web_view_load_plain_text(web_view : Void*, plain_text : UInt8*) : Void
    fun webkit_web_view_load_bytes(web_view : Void*, bytes : Void*, mime_type : UInt8*, encoding : UInt8*, base_uri : UInt8*) : Void
    fun webkit_web_view_load_request(web_view : Void*, request : Void*) : Void
    fun webkit_web_view_stop_loading(web_view : Void*) : Void
    fun webkit_web_view_is_loading(web_view : Void*) : Int32
    fun webkit_web_view_is_playing_audio(web_view : Void*) : Int32
    fun webkit_web_view_set_is_muted(web_view : Void*, muted : Int32) : Void
    fun webkit_web_view_get_is_muted(web_view : Void*) : Int32
    fun webkit_web_view_get_page_id(web_view : Void*) : UInt64
    fun webkit_web_view_get_title(web_view : Void*) : UInt8*
    fun webkit_web_view_reload(web_view : Void*) : Void
    fun webkit_web_view_reload_bypass_cache(web_view : Void*) : Void
    fun webkit_web_view_get_estimated_load_progress(web_view : Void*) : Float64
    fun webkit_web_view_go_back(web_view : Void*) : Void
    fun webkit_web_view_can_go_back(web_view : Void*) : Int32
    fun webkit_web_view_go_forward(web_view : Void*) : Void
    fun webkit_web_view_can_go_forward(web_view : Void*) : Int32
    fun webkit_web_view_get_uri(web_view : Void*) : UInt8*
    fun webkit_web_view_get_custom_charset(web_view : Void*) : UInt8*
    fun webkit_web_view_set_custom_charset(web_view : Void*, charset : UInt8*) : Void
    fun webkit_web_view_set_settings(web_view : Void*, settings : Void*) : Void
    fun webkit_web_view_get_settings(web_view : Void*) : Void*
    fun webkit_web_view_set_zoom_level(web_view : Void*, zoom_level : Float64) : Void
    fun webkit_web_view_get_zoom_level(web_view : Void*) : Float64
    fun webkit_web_view_execute_editing_command(web_view : Void*, command : UInt8*) : Void
    fun webkit_web_view_execute_editing_command_with_argument(web_view : Void*, command : UInt8*, argument : UInt8*) : Void
    fun webkit_web_view_get_find_controller(web_view : Void*) : Void*
    fun webkit_web_view_evaluate_javascript(web_view : Void*, script : UInt8*, length : LibC::SSizeT, world_name : UInt8*, source_uri : UInt8*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_web_view_evaluate_javascript_finish(web_view : Void*, result : Void*, error : Error**) : Void*
    fun webkit_web_view_can_show_mime_type(web_view : Void*, mime_type : UInt8*) : Int32
    fun webkit_web_view_download_uri(web_view : Void*, uri : UInt8*) : Void*
    fun webkit_web_view_get_snapshot(web_view : Void*, region : Int32, options : Int32, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_web_view_get_snapshot_finish(web_view : Void*, result : Void*, error : Error**) : Void*
    fun webkit_web_view_get_user_content_manager(web_view : Void*) : Void*
    fun webkit_web_view_set_background_color(web_view : Void*, color : Color*) : Void
    fun webkit_web_view_get_background_color(web_view : Void*, color : Color*) : Void
    fun webkit_web_view_is_editable(web_view : Void*) : Int32
    fun webkit_web_view_set_editable(web_view : Void*, editable : Int32) : Void
    fun webkit_web_view_set_cors_allowlist(web_view : Void*, allowlist : UInt8**) : Void
    fun webkit_web_view_get_is_web_process_responsive(web_view : Void*) : Int32
    fun webkit_web_view_terminate_web_process(web_view : Void*) : Void
    fun webkit_web_view_get_theme_color(web_view : Void*, color : Color*) : Int32

    fun webkit_settings_new : Void*

    fun webkit_web_context_get_default : Void*
    fun webkit_web_context_set_cache_model(context : Void*, cache_model : Int32) : Void
    fun webkit_web_context_get_cache_model(context : Void*) : Int32
    fun webkit_web_context_register_uri_scheme(context : Void*, scheme : UInt8*, callback : URISchemeRequestCallback, user_data : Void*, user_data_destroy_func : DestroyNotify) : Void
    fun webkit_web_context_add_path_to_sandbox(context : Void*, path : UInt8*, read_only : Int32) : Void
    fun webkit_web_context_get_spell_checking_enabled(context : Void*) : Int32
    fun webkit_web_context_set_spell_checking_enabled(context : Void*, enabled : Int32) : Void
    fun webkit_web_context_set_spell_checking_languages(context : Void*, languages : UInt8**) : Void
    fun webkit_web_context_set_preferred_languages(context : Void*, languages : UInt8**) : Void

    fun webkit_network_session_get_default : Void*
    fun webkit_network_session_new(data_directory : UInt8*, cache_directory : UInt8*) : Void*
    fun webkit_network_session_new_ephemeral : Void*
    fun webkit_network_session_is_ephemeral(session : Void*) : Int32
    fun webkit_network_session_get_website_data_manager(session : Void*) : Void*
    fun webkit_network_session_get_cookie_manager(session : Void*) : Void*
    fun webkit_network_session_set_itp_enabled(session : Void*, enabled : Int32) : Void
    fun webkit_network_session_get_itp_enabled(session : Void*) : Int32
    fun webkit_network_session_set_persistent_credential_storage_enabled(session : Void*, enabled : Int32) : Void
    fun webkit_network_session_get_persistent_credential_storage_enabled(session : Void*) : Int32
    fun webkit_network_session_set_tls_errors_policy(session : Void*, policy : Int32) : Void
    fun webkit_network_session_get_tls_errors_policy(session : Void*) : Int32
    fun webkit_network_session_set_proxy_settings(session : Void*, proxy_mode : Int32, proxy_settings : Void*) : Void
    fun webkit_network_session_prefetch_dns(session : Void*, hostname : UInt8*) : Void
    fun webkit_network_session_download_uri(session : Void*, uri : UInt8*) : Void*

    fun webkit_network_proxy_settings_new(default_proxy_uri : UInt8*, ignore_hosts : UInt8**) : Void*
    fun webkit_network_proxy_settings_add_proxy_for_scheme(proxy_settings : Void*, scheme : UInt8*, proxy_uri : UInt8*) : Void
    fun webkit_network_proxy_settings_free(proxy_settings : Void*) : Void

    fun webkit_website_data_manager_is_ephemeral(manager : Void*) : Int32
    fun webkit_website_data_manager_get_base_data_directory(manager : Void*) : UInt8*
    fun webkit_website_data_manager_get_base_cache_directory(manager : Void*) : UInt8*
    fun webkit_website_data_manager_fetch(manager : Void*, types : Int32, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_website_data_manager_fetch_finish(manager : Void*, result : Void*, error : Error**) : List*
    fun webkit_website_data_manager_remove(manager : Void*, types : Int32, website_data : List*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_website_data_manager_remove_finish(manager : Void*, result : Void*, error : Error**) : Int32
    fun webkit_website_data_manager_clear(manager : Void*, types : Int32, timespan : Int64, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_website_data_manager_clear_finish(manager : Void*, result : Void*, error : Error**) : Int32

    fun webkit_website_data_ref(website_data : Void*) : Void*
    fun webkit_website_data_unref(website_data : Void*) : Void
    fun webkit_website_data_get_name(website_data : Void*) : UInt8*
    fun webkit_website_data_get_types(website_data : Void*) : Int32
    fun webkit_website_data_get_size(website_data : Void*, types : Int32) : UInt64

    fun webkit_cookie_manager_set_persistent_storage(cookie_manager : Void*, filename : UInt8*, storage : Int32) : Void
    fun webkit_cookie_manager_set_accept_policy(cookie_manager : Void*, policy : Int32) : Void
    fun webkit_cookie_manager_get_accept_policy(cookie_manager : Void*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_cookie_manager_get_accept_policy_finish(cookie_manager : Void*, result : Void*, error : Error**) : Int32
    fun webkit_cookie_manager_add_cookie(cookie_manager : Void*, cookie : Void*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_cookie_manager_add_cookie_finish(cookie_manager : Void*, result : Void*, error : Error**) : Int32
    fun webkit_cookie_manager_get_cookies(cookie_manager : Void*, uri : UInt8*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_cookie_manager_get_cookies_finish(cookie_manager : Void*, result : Void*, error : Error**) : List*
    fun webkit_cookie_manager_delete_cookie(cookie_manager : Void*, cookie : Void*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_cookie_manager_delete_cookie_finish(cookie_manager : Void*, result : Void*, error : Error**) : Int32
    fun webkit_cookie_manager_replace_cookies(cookie_manager : Void*, cookies : List*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_cookie_manager_replace_cookies_finish(cookie_manager : Void*, result : Void*, error : Error**) : Int32
    fun webkit_cookie_manager_get_all_cookies(cookie_manager : Void*, cancellable : Void*, callback : AsyncReadyCallback, user_data : Void*) : Void
    fun webkit_cookie_manager_get_all_cookies_finish(cookie_manager : Void*, result : Void*, error : Error**) : List*

    fun webkit_policy_decision_use(decision : Void*) : Void
    fun webkit_policy_decision_ignore(decision : Void*) : Void
    fun webkit_policy_decision_download(decision : Void*) : Void
    fun webkit_navigation_policy_decision_get_navigation_action(decision : Void*) : Void*
    fun webkit_response_policy_decision_get_request(decision : Void*) : Void*
    fun webkit_response_policy_decision_get_response(decision : Void*) : Void*
    fun webkit_response_policy_decision_is_mime_type_supported(decision : Void*) : Int32
    fun webkit_response_policy_decision_is_main_frame_main_resource(decision : Void*) : Int32

    fun webkit_navigation_action_copy(navigation : Void*) : Void*
    fun webkit_navigation_action_free(navigation : Void*) : Void
    fun webkit_navigation_action_get_navigation_type(navigation : Void*) : Int32
    fun webkit_navigation_action_get_mouse_button(navigation : Void*) : UInt32
    fun webkit_navigation_action_get_modifiers(navigation : Void*) : UInt32
    fun webkit_navigation_action_get_request(navigation : Void*) : Void*
    fun webkit_navigation_action_is_user_gesture(navigation : Void*) : Int32
    fun webkit_navigation_action_is_redirect(navigation : Void*) : Int32
    fun webkit_navigation_action_get_frame_name(navigation : Void*) : UInt8*

    fun webkit_uri_request_new(uri : UInt8*) : Void*
    fun webkit_uri_request_get_uri(request : Void*) : UInt8*
    fun webkit_uri_request_set_uri(request : Void*, uri : UInt8*) : Void
    fun webkit_uri_request_get_http_method(request : Void*) : UInt8*
    fun webkit_uri_request_get_http_headers(request : Void*) : Void*

    fun webkit_uri_response_get_uri(response : Void*) : UInt8*
    fun webkit_uri_response_get_status_code(response : Void*) : UInt32
    fun webkit_uri_response_get_content_length(response : Void*) : UInt64
    fun webkit_uri_response_get_mime_type(response : Void*) : UInt8*
    fun webkit_uri_response_get_suggested_filename(response : Void*) : UInt8*
    fun webkit_uri_response_get_http_headers(response : Void*) : Void*

    fun webkit_uri_scheme_request_get_scheme(request : Void*) : UInt8*
    fun webkit_uri_scheme_request_get_uri(request : Void*) : UInt8*
    fun webkit_uri_scheme_request_get_path(request : Void*) : UInt8*
    fun webkit_uri_scheme_request_get_web_view(request : Void*) : Void*
    fun webkit_uri_scheme_request_get_http_method(request : Void*) : UInt8*
    fun webkit_uri_scheme_request_get_http_headers(request : Void*) : Void*
    fun webkit_uri_scheme_request_get_http_body(request : Void*) : Void*
    fun webkit_uri_scheme_request_finish_with_response(request : Void*, response : Void*) : Void
    fun webkit_uri_scheme_request_finish_error(request : Void*, error : Error*) : Void

    fun webkit_uri_scheme_response_new(input_stream : Void*, stream_length : Int64) : Void*
    fun webkit_uri_scheme_response_set_status(response : Void*, status_code : UInt32, reason_phrase : UInt8*) : Void
    fun webkit_uri_scheme_response_set_content_type(response : Void*, content_type : UInt8*) : Void
    fun webkit_uri_scheme_response_set_http_headers(response : Void*, headers : Void*) : Void

    fun webkit_user_content_manager_new : Void*
    fun webkit_user_content_manager_add_style_sheet(manager : Void*, stylesheet : Void*) : Void
    fun webkit_user_content_manager_remove_style_sheet(manager : Void*, stylesheet : Void*) : Void
    fun webkit_user_content_manager_remove_all_style_sheets(manager : Void*) : Void
    fun webkit_user_content_manager_register_script_message_handler(manager : Void*, name : UInt8*, world_name : UInt8*) : Int32
    fun webkit_user_content_manager_unregister_script_message_handler(manager : Void*, name : UInt8*, world_name : UInt8*) : Void
    fun webkit_user_content_manager_register_script_message_handler_with_reply(manager : Void*, name : UInt8*, world_name : UInt8*) : Int32
    fun webkit_user_content_manager_add_script(manager : Void*, script : Void*) : Void
    fun webkit_user_content_manager_remove_script(manager : Void*, script : Void*) : Void
    fun webkit_user_content_manager_remove_all_scripts(manager : Void*) : Void

    fun webkit_script_message_reply_ref(reply : Void*) : Void*
    fun webkit_script_message_reply_unref(reply : Void*) : Void
    fun webkit_script_message_reply_return_value(reply : Void*, reply_value : Void*) : Void
    fun webkit_script_message_reply_return_error_message(reply : Void*, error_message : UInt8*) : Void

    fun webkit_user_style_sheet_ref(user_style_sheet : Void*) : Void*
    fun webkit_user_style_sheet_unref(user_style_sheet : Void*) : Void
    fun webkit_user_style_sheet_new_for_world(source : UInt8*, injected_frames : Int32, level : Int32, world_name : UInt8*, allow_list : UInt8**, block_list : UInt8**) : Void*
    fun webkit_user_script_ref(user_script : Void*) : Void*
    fun webkit_user_script_unref(user_script : Void*) : Void
    fun webkit_user_script_new_for_world(source : UInt8*, injected_frames : Int32, injection_time : Int32, world_name : UInt8*, allow_list : UInt8**, block_list : UInt8**) : Void*

    fun webkit_download_get_request(download : Void*) : Void*
    fun webkit_download_get_destination(download : Void*) : UInt8*
    fun webkit_download_set_destination(download : Void*, destination : UInt8*) : Void
    fun webkit_download_get_response(download : Void*) : Void*
    fun webkit_download_cancel(download : Void*) : Void
    fun webkit_download_get_estimated_progress(download : Void*) : Float64
    fun webkit_download_get_elapsed_time(download : Void*) : Float64
    fun webkit_download_get_received_data_length(download : Void*) : UInt64
    fun webkit_download_get_web_view(download : Void*) : Void*
    fun webkit_download_get_allow_overwrite(download : Void*) : Int32
    fun webkit_download_set_allow_overwrite(download : Void*, allowed : Int32) : Void

    fun webkit_permission_request_allow(request : Void*) : Void
    fun webkit_permission_request_deny(request : Void*) : Void

    fun webkit_find_controller_search(find_controller : Void*, search_text : UInt8*, find_options : UInt32, max_match_count : UInt32) : Void
    fun webkit_find_controller_search_finish(find_controller : Void*) : Void
    fun webkit_find_controller_search_next(find_controller : Void*) : Void
    fun webkit_find_controller_search_previous(find_controller : Void*) : Void
    fun webkit_find_controller_count_matches(find_controller : Void*, search_text : UInt8*, find_options : UInt32, max_match_count : UInt32) : Void
    fun webkit_find_controller_get_search_text(find_controller : Void*) : UInt8*
    fun webkit_find_controller_get_options(find_controller : Void*) : UInt32
    fun webkit_find_controller_get_max_match_count(find_controller : Void*) : UInt32

    fun webkit_script_dialog_ref(dialog : Void*) : Void*
    fun webkit_script_dialog_unref(dialog : Void*) : Void
    fun webkit_script_dialog_get_dialog_type(dialog : Void*) : Int32
    fun webkit_script_dialog_get_message(dialog : Void*) : UInt8*
    fun webkit_script_dialog_confirm_set_confirmed(dialog : Void*, confirmed : Int32) : Void
    fun webkit_script_dialog_prompt_get_default_text(dialog : Void*) : UInt8*
    fun webkit_script_dialog_prompt_set_text(dialog : Void*, text : UInt8*) : Void
    fun webkit_script_dialog_close(dialog : Void*) : Void

    fun webkit_image_get_width(image : Void*) : Int32
    fun webkit_image_get_height(image : Void*) : Int32
    fun webkit_image_get_stride(image : Void*) : UInt32
    fun webkit_image_as_bytes(image : Void*) : Void*
  end
end
