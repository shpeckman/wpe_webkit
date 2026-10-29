# src/wpe_webkit/web_context.cr
module WPEWebKit
  class URISchemeRequest < GObject
    READ_CHUNK = 65536

    def scheme : String
      String.new(C.webkit_uri_scheme_request_get_scheme(self))
    end

    def uri : String
      String.new(C.webkit_uri_scheme_request_get_uri(self))
    end

    def path : String
      String.new(C.webkit_uri_scheme_request_get_path(self))
    end

    def http_method : String?
      Native.string?(C.webkit_uri_scheme_request_get_http_method(self))
    end

    def headers : HTTP::Headers
      Headers.from_soup(C.webkit_uri_scheme_request_get_http_headers(self))
    end

    def web_view : WebView?
      WebView.from_raw?(C.webkit_uri_scheme_request_get_web_view(self))
    end

    def body : Bytes?
      stream = C.webkit_uri_scheme_request_get_http_body(self)
      return if stream.null?
      io = IO::Memory.new
      loop do
        chunk = GLibError.check! { |error| C.g_input_stream_read_bytes(stream, READ_CHUNK, nil, error) }
        data = Native.read_bytes(chunk)
        C.g_bytes_unref(chunk)
        break if data.empty?
        io.write(data)
      end
      C.g_object_unref(stream)
      io.to_slice
    end

    def finish(body : String | Bytes, content_type : String = "text/html", *, status : Int = 200, reason : String? = nil, headers : HTTP::Headers? = nil) : Nil
      bytes = Native.bytes(body)
      stream = C.g_memory_input_stream_new_from_bytes(bytes)
      C.g_bytes_unref(bytes)
      response = C.webkit_uri_scheme_response_new(stream, body.bytesize.to_i64)
      C.g_object_unref(stream)
      C.webkit_uri_scheme_response_set_status(response, status.to_u32, Native.string(reason))
      C.webkit_uri_scheme_response_set_content_type(response, content_type)
      C.webkit_uri_scheme_response_set_http_headers(response, Headers.to_soup(headers)) if headers
      C.webkit_uri_scheme_request_finish_with_response(self, response)
      C.g_object_unref(response)
    end

    def finish_error(message : String, code : Int32 = 0) : Nil
      error = C.g_error_new_literal(C.g_quark_from_string("WPEWebKit"), code, message)
      C.webkit_uri_scheme_request_finish_error(self, error)
      C.g_error_free(error)
    end
  end

  class WebContext < GObject
    URI_SCHEME = ->(request : Void*, data : Void*) {
      begin
        Box(Proc(URISchemeRequest, Nil)).unbox(data).call(URISchemeRequest.from_raw(request))
      rescue ex
        ex.inspect_with_backtrace(STDERR)
      end
      nil
    }

    def self.default : WebContext
      from_raw(C.webkit_web_context_get_default)
    end

    def register_uri_scheme(scheme : String, &block : URISchemeRequest -> Nil) : Nil
      C.webkit_web_context_register_uri_scheme(self, scheme, URI_SCHEME, Handles.retain(block), Handles::RELEASE)
    end

    def cache_model : CacheModel
      CacheModel.new(C.webkit_web_context_get_cache_model(self))
    end

    def cache_model=(model : CacheModel)
      C.webkit_web_context_set_cache_model(self, model.value)
    end

    def spell_checking_enabled? : Bool
      C.webkit_web_context_get_spell_checking_enabled(self) != 0
    end

    def spell_checking_enabled=(enabled : Bool)
      C.webkit_web_context_set_spell_checking_enabled(self, enabled ? 1 : 0)
    end

    def spell_checking_languages=(languages : Enumerable(String))
      C.webkit_web_context_set_spell_checking_languages(self, Native.strv(languages))
    end

    def preferred_languages=(languages : Enumerable(String))
      C.webkit_web_context_set_preferred_languages(self, Native.strv(languages))
    end

    def add_path_to_sandbox(path : String, read_only : Bool = true) : Nil
      C.webkit_web_context_add_path_to_sandbox(self, path, read_only ? 1 : 0)
    end
  end
end
