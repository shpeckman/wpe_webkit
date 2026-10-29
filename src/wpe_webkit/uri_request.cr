# src/wpe_webkit/uri_request.cr
module WPEWebKit
  class URIRequest < GObject
    def self.new(uri : String) : self
      take(C.webkit_uri_request_new(uri))
    end

    def uri : String
      String.new(C.webkit_uri_request_get_uri(self))
    end

    def uri=(uri : String)
      C.webkit_uri_request_set_uri(self, uri)
    end

    def http_method : String?
      Native.string?(C.webkit_uri_request_get_http_method(self))
    end

    def headers : HTTP::Headers
      Headers.from_soup(C.webkit_uri_request_get_http_headers(self))
    end
  end

  class URIResponse < GObject
    def uri : String
      String.new(C.webkit_uri_response_get_uri(self))
    end

    def status_code : UInt32
      C.webkit_uri_response_get_status_code(self)
    end

    def content_length : UInt64
      C.webkit_uri_response_get_content_length(self)
    end

    def mime_type : String?
      Native.string?(C.webkit_uri_response_get_mime_type(self))
    end

    def suggested_filename : String?
      Native.string?(C.webkit_uri_response_get_suggested_filename(self))
    end

    def headers : HTTP::Headers
      Headers.from_soup(C.webkit_uri_response_get_http_headers(self))
    end
  end
end
