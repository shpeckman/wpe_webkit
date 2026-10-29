# src/wpe_webkit/js_value.cr
require "json"

module WPEWebKit
  class JSContext < GObject
  end

  class JSValue < GObject
    def self.from_json(context : JSContext, json : String) : self
      take(C.jsc_value_new_from_json(context, json))
    end

    def context : JSContext
      JSContext.from_raw(C.jsc_value_get_context(self), owner: self)
    end

    def undefined? : Bool
      C.jsc_value_is_undefined(self) != 0
    end

    def null? : Bool
      C.jsc_value_is_null(self) != 0
    end

    def number? : Bool
      C.jsc_value_is_number(self) != 0
    end

    def boolean? : Bool
      C.jsc_value_is_boolean(self) != 0
    end

    def string? : Bool
      C.jsc_value_is_string(self) != 0
    end

    def array? : Bool
      C.jsc_value_is_array(self) != 0
    end

    def object? : Bool
      C.jsc_value_is_object(self) != 0
    end

    def function? : Bool
      C.jsc_value_is_function(self) != 0
    end

    def to_s : String
      Native.take_string?(C.jsc_value_to_string(self)) || ""
    end

    def to_s(io : IO) : Nil
      io << to_s
    end

    def to_f : Float64
      C.jsc_value_to_double(self)
    end

    def to_i : Int32
      C.jsc_value_to_int32(self)
    end

    def to_bool : Bool
      C.jsc_value_to_boolean(self) != 0
    end

    def to_json(indent : Int = 0) : String
      Native.take_string?(C.jsc_value_to_json(self, indent.to_u32)) || "null"
    end

    def as_json : JSON::Any
      JSON.parse(to_json)
    end
  end
end
