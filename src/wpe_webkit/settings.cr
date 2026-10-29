# src/wpe_webkit/settings.cr
module WPEWebKit
  class Settings < GObject
    def self.new(**options : **T) : self forall T
      settings = take(C.webkit_settings_new)
      {% for key in T.keys %}
        settings.{{key.id}} = options[{{key.symbolize}}]
      {% end %}
      settings
    end

    properties({
      enable_javascript:                              Bool,
      auto_load_images:                               Bool,
      load_icons_ignoring_image_load_setting:         Bool,
      enable_offline_web_application_cache:           Bool,
      enable_html5_local_storage:                     Bool,
      enable_html5_database:                          Bool,
      javascript_can_open_windows_automatically:      Bool,
      enable_hyperlink_auditing:                      Bool,
      default_font_family:                            String,
      monospace_font_family:                          String,
      serif_font_family:                              String,
      sans_serif_font_family:                         String,
      cursive_font_family:                            String,
      fantasy_font_family:                            String,
      pictograph_font_family:                         String,
      math_font_family:                               String,
      default_font_size:                              UInt32,
      default_monospace_font_size:                    UInt32,
      minimum_font_size:                              UInt32,
      default_charset:                                String,
      enable_developer_extras:                        Bool,
      enable_resizable_text_areas:                    Bool,
      enable_tabs_to_links:                           Bool,
      enable_dns_prefetching:                         Bool,
      enable_caret_browsing:                          Bool,
      enable_fullscreen:                              Bool,
      print_backgrounds:                              Bool,
      enable_webaudio:                                Bool,
      enable_webgl:                                   Bool,
      allow_modal_dialogs:                            Bool,
      zoom_text_only:                                 Bool,
      javascript_can_access_clipboard:                Bool,
      media_playback_requires_user_gesture:           Bool,
      media_playback_allows_inline:                   Bool,
      draw_compositing_indicators:                    Bool,
      enable_site_specific_quirks:                    Bool,
      enable_page_cache:                              Bool,
      user_agent:                                     String,
      enable_smooth_scrolling:                        Bool,
      enable_2d_canvas_acceleration:                  Bool,
      enable_write_console_messages_to_stdout:        Bool,
      enable_media_stream:                            Bool,
      enable_mock_capture_devices:                    Bool,
      enable_spatial_navigation:                      Bool,
      enable_mediasource:                             Bool,
      enable_encrypted_media:                         Bool,
      enable_media_capabilities:                      Bool,
      allow_file_access_from_file_urls:               Bool,
      allow_universal_access_from_file_urls:          Bool,
      allow_top_navigation_to_data_urls:              Bool,
      enable_javascript_markup:                       Bool,
      enable_media:                                   Bool,
      media_content_types_requiring_hardware_support: String,
      enable_webrtc:                                  Bool,
      disable_web_security:                           Bool,
      webrtc_udp_ports_range:                         String,
    })
  end
end
