# src/wpe_webkit/c/jsc.cr
module WPEWebKit
  @[Link(pkg_config: "wpe-webkit-2.0")]
  lib C
    fun jsc_value_get_context(value : Void*) : Void*
    fun jsc_value_new_from_json(context : Void*, json : UInt8*) : Void*
    fun jsc_value_to_json(value : Void*, indent : UInt32) : UInt8*
    fun jsc_value_to_string(value : Void*) : UInt8*
    fun jsc_value_to_double(value : Void*) : Float64
    fun jsc_value_to_int32(value : Void*) : Int32
    fun jsc_value_to_boolean(value : Void*) : Int32
    fun jsc_value_is_undefined(value : Void*) : Int32
    fun jsc_value_is_null(value : Void*) : Int32
    fun jsc_value_is_number(value : Void*) : Int32
    fun jsc_value_is_boolean(value : Void*) : Int32
    fun jsc_value_is_string(value : Void*) : Int32
    fun jsc_value_is_array(value : Void*) : Int32
    fun jsc_value_is_object(value : Void*) : Int32
    fun jsc_value_is_function(value : Void*) : Int32
  end
end
