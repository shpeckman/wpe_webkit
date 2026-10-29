# src/wpe_webkit/image.cr
module WPEWebKit
  class Image < GObject
    def width : Int32
      C.webkit_image_get_width(self)
    end

    def height : Int32
      C.webkit_image_get_height(self)
    end

    def stride : UInt32
      C.webkit_image_get_stride(self)
    end

    def bytes : Bytes
      Native.read_bytes(C.webkit_image_as_bytes(self))
    end
  end

  record Color, red : Float64, green : Float64, blue : Float64, alpha : Float64 = 1.0 do
    def self.parse(value : String) : Color
      color = C::Color.new
      raise ArgumentError.new("Invalid color: #{value}") if C.webkit_color_parse(pointerof(color), value) == 0
      from_c(color)
    end

    def self.from_c(color : C::Color) : Color
      new(color.red, color.green, color.blue, color.alpha)
    end

    def to_c : C::Color
      C::Color.new(red: red, green: green, blue: blue, alpha: alpha)
    end
  end
end
