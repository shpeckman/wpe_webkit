# src/wpe_webkit/display.cr
module WPEWebKit
  class Display < GObject
    def self.default : Display?
      from_raw?(C.wpe_display_get_default)
    end

    def self.primary : Display?
      from_raw?(C.wpe_display_get_primary)
    end

    def self.headless : Display
      take(C.wpe_display_headless_new)
    end

    def self.wayland(name : String? = nil) : Display
      display = take(C.wpe_display_wayland_new)
      GLibError.check! { |error| C.wpe_display_wayland_connect(display, Native.string(name), error) }
      display
    end

    def connect : Nil
      GLibError.check! { |error| C.wpe_display_connect(self, error) }
    end

    def primary! : self
      C.wpe_display_set_primary(self)
      self
    end

    def create_toplevel(max_views : Int = 1) : Toplevel?
      Toplevel.take?(C.wpe_display_create_toplevel(self, max_views.to_u32))
    end
  end

  class Toplevel < GObject
    def display : Display?
      Display.from_raw?(C.wpe_toplevel_get_display(self), owner: self)
    end

    def title=(title : String?)
      C.wpe_toplevel_set_title(self, Native.string(title))
    end

    def size : {Int32, Int32}
      width = height = 0
      C.wpe_toplevel_get_size(self, pointerof(width), pointerof(height))
      {width, height}
    end

    def resize(width : Int, height : Int) : Bool
      C.wpe_toplevel_resize(self, width.to_i32, height.to_i32) != 0
    end

    def state : ToplevelState
      ToplevelState.new(C.wpe_toplevel_get_state(self))
    end

    def scale : Float64
      C.wpe_toplevel_get_scale(self)
    end

    def fullscreen : Bool
      C.wpe_toplevel_fullscreen(self) != 0
    end

    def unfullscreen : Bool
      C.wpe_toplevel_unfullscreen(self) != 0
    end

    def maximize : Bool
      C.wpe_toplevel_maximize(self) != 0
    end

    def unmaximize : Bool
      C.wpe_toplevel_unmaximize(self) != 0
    end

    def minimize : Bool
      C.wpe_toplevel_minimize(self) != 0
    end
  end
end
