# src/wpe_webkit/cookie_manager.cr
require "http/cookie"

module WPEWebKit
  class CookieManager < GObject
    SAME_SITE = {
      HTTP::Cookie::SameSite::None   => 0,
      HTTP::Cookie::SameSite::Lax    => 1,
      HTTP::Cookie::SameSite::Strict => 2,
    }

    def self.from_soup(pointer : Void*) : HTTP::Cookie?
      expires = C.soup_cookie_get_expires(pointer)
      HTTP::Cookie.new(
        String.new(C.soup_cookie_get_name(pointer)),
        String.new(C.soup_cookie_get_value(pointer)),
        path: Native.string?(C.soup_cookie_get_path(pointer)),
        expires: expires.null? ? nil : Time.unix(C.g_date_time_to_unix(expires)),
        domain: Native.string?(C.soup_cookie_get_domain(pointer)),
        secure: C.soup_cookie_get_secure(pointer) != 0,
        http_only: C.soup_cookie_get_http_only(pointer) != 0,
        samesite: SAME_SITE.key_for?(C.soup_cookie_get_same_site_policy(pointer)),
      )
    rescue IO::Error | ArgumentError
      nil
    end

    def self.to_soup(cookie : HTTP::Cookie) : Void*
      domain = cookie.domain || raise ArgumentError.new("Cookie #{cookie.name} requires a domain")
      max_age = cookie.max_age.try(&.total_seconds.to_i32) || -1
      pointer = C.soup_cookie_new(cookie.name, cookie.value, domain, cookie.path || "/", max_age)
      if expires = cookie.expires
        datetime = C.g_date_time_new_from_unix_utc(expires.to_unix)
        C.soup_cookie_set_expires(pointer, datetime)
        C.g_date_time_unref(datetime)
      end
      C.soup_cookie_set_secure(pointer, cookie.secure ? 1 : 0)
      C.soup_cookie_set_http_only(pointer, cookie.http_only ? 1 : 0)
      cookie.samesite.try { |policy| C.soup_cookie_set_same_site_policy(pointer, SAME_SITE[policy]) }
      pointer
    end

    def self.take_cookies(list : C::List*) : Array(HTTP::Cookie)
      Native.take_list(list) do |cookie|
        from_soup(cookie).tap { C.soup_cookie_free(cookie) }
      end.compact
    end

    def accept_policy=(policy : CookieAcceptPolicy)
      C.webkit_cookie_manager_set_accept_policy(self, policy.value)
    end

    def accept_policy : CookieAcceptPolicy
      Async.await(->(result : Void*, error : C::Error**) { CookieAcceptPolicy.new(C.webkit_cookie_manager_get_accept_policy_finish(self, result, error)) }) do |callback, data|
        C.webkit_cookie_manager_get_accept_policy(self, nil, callback, data)
      end
    end

    def persistent_storage(filename : String, storage : CookieStorage = :sqlite) : Nil
      C.webkit_cookie_manager_set_persistent_storage(self, filename, storage.value)
    end

    def add(cookie : HTTP::Cookie) : Nil
      with_soup(cookie) do |pointer|
        Async.await(->(result : Void*, error : C::Error**) { C.webkit_cookie_manager_add_cookie_finish(self, result, error); nil }) do |callback, data|
          C.webkit_cookie_manager_add_cookie(self, pointer, nil, callback, data)
        end
      end
    end

    def delete(cookie : HTTP::Cookie) : Nil
      with_soup(cookie) do |pointer|
        Async.await(->(result : Void*, error : C::Error**) { C.webkit_cookie_manager_delete_cookie_finish(self, result, error); nil }) do |callback, data|
          C.webkit_cookie_manager_delete_cookie(self, pointer, nil, callback, data)
        end
      end
    end

    def replace(cookies : Enumerable(HTTP::Cookie)) : Nil
      pointers = cookies.map { |cookie| CookieManager.to_soup(cookie) }
      list = pointers.reduce(Pointer(C::List).null) { |head, pointer| C.g_list_append(head, pointer) }
      begin
        Async.await(->(result : Void*, error : C::Error**) { C.webkit_cookie_manager_replace_cookies_finish(self, result, error); nil }) do |callback, data|
          C.webkit_cookie_manager_replace_cookies(self, list, nil, callback, data)
        end
      ensure
        C.g_list_free(list)
        pointers.each { |pointer| C.soup_cookie_free(pointer) }
      end
    end

    def cookies(uri : String) : Array(HTTP::Cookie)
      Async.await(->(result : Void*, error : C::Error**) { CookieManager.take_cookies(C.webkit_cookie_manager_get_cookies_finish(self, result, error)) }) do |callback, data|
        C.webkit_cookie_manager_get_cookies(self, uri, nil, callback, data)
      end
    end

    def all : Array(HTTP::Cookie)
      Async.await(->(result : Void*, error : C::Error**) { CookieManager.take_cookies(C.webkit_cookie_manager_get_all_cookies_finish(self, result, error)) }) do |callback, data|
        C.webkit_cookie_manager_get_all_cookies(self, nil, callback, data)
      end
    end

    private def with_soup(cookie : HTTP::Cookie, & : Void* -> _) : Nil
      pointer = CookieManager.to_soup(cookie)
      yield pointer
    ensure
      C.soup_cookie_free(pointer) if pointer
    end
  end
end
