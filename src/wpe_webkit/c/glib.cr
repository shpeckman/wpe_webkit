# src/wpe_webkit/c/glib.cr
module WPEWebKit
  @[Link(pkg_config: "gio-2.0")]
  lib C
    alias GType = LibC::SizeT

    struct Error
      domain : UInt32
      code : Int32
      message : UInt8*
    end

    struct List
      data : Void*
      next : List*
      prev : List*
    end

    struct PollFD
      fd : Int32
      events : UInt16
      revents : UInt16
    end

    struct Value
      g_type : GType
      data : UInt64[2]
    end

    alias AsyncReadyCallback = Void*, Void*, Void* -> Void
    alias DestroyNotify = Void* -> Void
    alias ClosureNotify = Void*, Void* -> Void

    fun poll(fds : PollFD*, nfds : LibC::ULong, timeout : Int32) : Int32

    fun g_free(mem : Void*) : Void
    fun g_quark_from_string(string : UInt8*) : UInt32
    fun g_quark_to_string(quark : UInt32) : UInt8*
    fun g_error_new_literal(domain : UInt32, code : Int32, message : UInt8*) : Error*
    fun g_error_free(error : Error*) : Void

    fun g_main_context_default : Void*
    fun g_main_context_acquire(context : Void*) : Int32
    fun g_main_context_prepare(context : Void*, priority : Int32*) : Int32
    fun g_main_context_query(context : Void*, max_priority : Int32, timeout : Int32*, fds : PollFD*, n_fds : Int32) : Int32
    fun g_main_context_check(context : Void*, max_priority : Int32, fds : PollFD*, n_fds : Int32) : Int32
    fun g_main_context_dispatch(context : Void*) : Void
    fun g_main_context_wakeup(context : Void*) : Void

    fun g_list_append(list : List*, data : Void*) : List*
    fun g_list_free(list : List*) : Void

    fun g_bytes_new(data : Void*, size : LibC::SizeT) : Void*
    fun g_bytes_get_data(bytes : Void*, size : LibC::SizeT*) : Void*
    fun g_bytes_get_size(bytes : Void*) : LibC::SizeT
    fun g_bytes_unref(bytes : Void*) : Void

    fun g_date_time_new_from_unix_utc(t : Int64) : Void*
    fun g_date_time_to_unix(datetime : Void*) : Int64
    fun g_date_time_unref(datetime : Void*) : Void

    fun g_type_name(type : GType) : UInt8*
    fun g_object_ref(object : Void*) : Void*
    fun g_object_unref(object : Void*) : Void
    fun g_object_get(object : Void*, first_property_name : UInt8*, ...) : Void
    fun g_object_set(object : Void*, first_property_name : UInt8*, ...) : Void
    fun g_object_new_with_properties(object_type : GType, n_properties : UInt32, names : UInt8**, values : Value*) : Void*
    fun g_value_init(value : Value*, g_type : GType) : Value*
    fun g_value_set_object(value : Value*, object : Void*) : Void
    fun g_value_unset(value : Value*) : Void
    fun g_signal_connect_data(instance : Void*, detailed_signal : UInt8*, handler : Void*, data : Void*, destroy_data : ClosureNotify, connect_flags : Int32) : LibC::ULong
    fun g_signal_handler_disconnect(instance : Void*, handler_id : LibC::ULong) : Void

    fun g_memory_input_stream_new_from_bytes(bytes : Void*) : Void*
    fun g_input_stream_read_bytes(stream : Void*, count : LibC::SizeT, cancellable : Void*, error : Error**) : Void*
  end
end
