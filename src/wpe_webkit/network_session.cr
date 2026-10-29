# src/wpe_webkit/network_session.cr
module WPEWebKit
  class NetworkSession < GObject
    def self.default : NetworkSession
      from_raw(C.webkit_network_session_get_default)
    end

    def self.new(data_directory : String? = nil, cache_directory : String? = nil) : self
      take(C.webkit_network_session_new(Native.string(data_directory), Native.string(cache_directory)))
    end

    def self.ephemeral : NetworkSession
      take(C.webkit_network_session_new_ephemeral)
    end

    def ephemeral? : Bool
      C.webkit_network_session_is_ephemeral(self) != 0
    end

    def website_data_manager : WebsiteDataManager
      WebsiteDataManager.from_raw(C.webkit_network_session_get_website_data_manager(self))
    end

    def cookie_manager : CookieManager
      CookieManager.from_raw(C.webkit_network_session_get_cookie_manager(self))
    end

    def itp_enabled? : Bool
      C.webkit_network_session_get_itp_enabled(self) != 0
    end

    def itp_enabled=(enabled : Bool)
      C.webkit_network_session_set_itp_enabled(self, enabled ? 1 : 0)
    end

    def persistent_credential_storage_enabled? : Bool
      C.webkit_network_session_get_persistent_credential_storage_enabled(self) != 0
    end

    def persistent_credential_storage_enabled=(enabled : Bool)
      C.webkit_network_session_set_persistent_credential_storage_enabled(self, enabled ? 1 : 0)
    end

    def tls_errors_policy : TLSErrorsPolicy
      TLSErrorsPolicy.new(C.webkit_network_session_get_tls_errors_policy(self))
    end

    def tls_errors_policy=(policy : TLSErrorsPolicy)
      C.webkit_network_session_set_tls_errors_policy(self, policy.value)
    end

    def proxy(mode : ProxyMode, default_uri : String? = nil, *, ignore_hosts : Enumerable(String)? = nil, schemes : Hash(String, String) = {} of String => String) : Nil
      return C.webkit_network_session_set_proxy_settings(self, mode.value, nil) unless mode.custom?
      settings = C.webkit_network_proxy_settings_new(Native.string(default_uri), Native.strv(ignore_hosts))
      schemes.each { |scheme, uri| C.webkit_network_proxy_settings_add_proxy_for_scheme(settings, scheme, uri) }
      C.webkit_network_session_set_proxy_settings(self, mode.value, settings)
      C.webkit_network_proxy_settings_free(settings)
    end

    def prefetch_dns(hostname : String) : Nil
      C.webkit_network_session_prefetch_dns(self, hostname)
    end

    def download(uri : String) : Download
      Download.take(C.webkit_network_session_download_uri(self, uri))
    end

    signal download_started, "download-started", {download: Download}
  end
end
