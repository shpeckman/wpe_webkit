# src/wpe_webkit/c/soup.cr
module WPEWebKit
  @[Link(pkg_config: "libsoup-3.0")]
  lib C
    alias SoupHeaderForeach = UInt8*, UInt8*, Void* -> Void

    fun soup_cookie_new(name : UInt8*, value : UInt8*, domain : UInt8*, path : UInt8*, max_age : Int32) : Void*
    fun soup_cookie_free(cookie : Void*) : Void
    fun soup_cookie_get_name(cookie : Void*) : UInt8*
    fun soup_cookie_get_value(cookie : Void*) : UInt8*
    fun soup_cookie_get_domain(cookie : Void*) : UInt8*
    fun soup_cookie_get_path(cookie : Void*) : UInt8*
    fun soup_cookie_get_expires(cookie : Void*) : Void*
    fun soup_cookie_set_expires(cookie : Void*, expires : Void*) : Void
    fun soup_cookie_get_secure(cookie : Void*) : Int32
    fun soup_cookie_set_secure(cookie : Void*, secure : Int32) : Void
    fun soup_cookie_get_http_only(cookie : Void*) : Int32
    fun soup_cookie_set_http_only(cookie : Void*, http_only : Int32) : Void
    fun soup_cookie_get_same_site_policy(cookie : Void*) : Int32
    fun soup_cookie_set_same_site_policy(cookie : Void*, policy : Int32) : Void

    fun soup_message_headers_new(type : Int32) : Void*
    fun soup_message_headers_unref(headers : Void*) : Void
    fun soup_message_headers_append(headers : Void*, name : UInt8*, value : UInt8*) : Void
    fun soup_message_headers_foreach(headers : Void*, func : SoupHeaderForeach, user_data : Void*) : Void
  end
end
