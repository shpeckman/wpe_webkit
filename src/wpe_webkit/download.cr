# src/wpe_webkit/download.cr
module WPEWebKit
  class Download < GObject
    def request : URIRequest
      URIRequest.from_raw(C.webkit_download_get_request(self))
    end

    def response : URIResponse?
      URIResponse.from_raw?(C.webkit_download_get_response(self))
    end

    def destination : String?
      Native.string?(C.webkit_download_get_destination(self))
    end

    def destination=(destination : String)
      C.webkit_download_set_destination(self, destination)
    end

    def allow_overwrite? : Bool
      C.webkit_download_get_allow_overwrite(self) != 0
    end

    def allow_overwrite=(allowed : Bool)
      C.webkit_download_set_allow_overwrite(self, allowed ? 1 : 0)
    end

    def estimated_progress : Float64
      C.webkit_download_get_estimated_progress(self)
    end

    def elapsed_time : Time::Span
      C.webkit_download_get_elapsed_time(self).seconds
    end

    def received_data_length : UInt64
      C.webkit_download_get_received_data_length(self)
    end

    def web_view : WebView?
      WebView.from_raw?(C.webkit_download_get_web_view(self))
    end

    def cancel : Nil
      C.webkit_download_cancel(self)
    end

    signal received_data, "received-data", {length: UInt64}
    signal finished, "finished"
    signal failed, "failed", {error: GLibError}
    signal decide_destination, "decide-destination", {suggested_filename: String}, Bool
    signal created_destination, "created-destination", {destination: String}
  end
end
