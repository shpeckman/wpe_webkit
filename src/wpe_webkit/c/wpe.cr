# src/wpe_webkit/c/wpe.cr
module WPEWebKit
  @[Link(pkg_config: "wpe-platform-2.0")]
  @[Link(pkg_config: "wpe-platform-headless-2.0")]
  @[Link(pkg_config: "wpe-platform-wayland-2.0")]
  lib C
    fun wpe_display_get_default : Void*
    fun wpe_display_get_primary : Void*
    fun wpe_display_set_primary(display : Void*) : Void
    fun wpe_display_connect(display : Void*, error : Error**) : Int32
    fun wpe_display_create_toplevel(display : Void*, max_views : UInt32) : Void*
    fun wpe_display_headless_new : Void*
    fun wpe_display_wayland_new : Void*
    fun wpe_display_wayland_connect(display : Void*, name : UInt8*, error : Error**) : Int32

    fun wpe_toplevel_get_display(toplevel : Void*) : Void*
    fun wpe_toplevel_set_title(toplevel : Void*, title : UInt8*) : Void
    fun wpe_toplevel_get_size(toplevel : Void*, width : Int32*, height : Int32*) : Void
    fun wpe_toplevel_resize(toplevel : Void*, width : Int32, height : Int32) : Int32
    fun wpe_toplevel_get_state(toplevel : Void*) : Int32
    fun wpe_toplevel_get_scale(toplevel : Void*) : Float64
    fun wpe_toplevel_fullscreen(toplevel : Void*) : Int32
    fun wpe_toplevel_unfullscreen(toplevel : Void*) : Int32
    fun wpe_toplevel_maximize(toplevel : Void*) : Int32
    fun wpe_toplevel_unmaximize(toplevel : Void*) : Int32
    fun wpe_toplevel_minimize(toplevel : Void*) : Int32

    fun wpe_view_get_toplevel(view : Void*) : Void*
    fun wpe_view_get_width(view : Void*) : Int32
    fun wpe_view_get_height(view : Void*) : Int32
  end
end
