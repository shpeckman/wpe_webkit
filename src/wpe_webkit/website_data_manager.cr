# src/wpe_webkit/website_data_manager.cr
module WPEWebKit
  class WebsiteData < Wrapper
    boxed webkit_website_data_ref, webkit_website_data_unref

    def name : String
      String.new(C.webkit_website_data_get_name(self))
    end

    def types : WebsiteDataTypes
      WebsiteDataTypes.new(C.webkit_website_data_get_types(self))
    end

    def size(types : WebsiteDataTypes = :all) : UInt64
      C.webkit_website_data_get_size(self, types.value)
    end
  end

  class WebsiteDataManager < GObject
    def ephemeral? : Bool
      C.webkit_website_data_manager_is_ephemeral(self) != 0
    end

    def base_data_directory : String?
      Native.string?(C.webkit_website_data_manager_get_base_data_directory(self))
    end

    def base_cache_directory : String?
      Native.string?(C.webkit_website_data_manager_get_base_cache_directory(self))
    end

    def fetch(types : WebsiteDataTypes = :all) : Array(WebsiteData)
      Async.await(->(result : Void*, error : C::Error**) { Native.take_list(C.webkit_website_data_manager_fetch_finish(self, result, error)) { |data| WebsiteData.take(data) } }) do |callback, data|
        C.webkit_website_data_manager_fetch(self, types.value, nil, callback, data)
      end
    end

    def remove(data : Enumerable(WebsiteData), types : WebsiteDataTypes = :all) : Nil
      list = data.reduce(Pointer(C::List).null) { |head, item| C.g_list_append(head, item.to_unsafe) }
      Async.await(->(result : Void*, error : C::Error**) { C.webkit_website_data_manager_remove_finish(self, result, error); nil }) do |callback, user_data|
        C.webkit_website_data_manager_remove(self, types.value, list, nil, callback, user_data)
      end
    ensure
      C.g_list_free(list) if list
    end

    def clear(types : WebsiteDataTypes = :all, since : Time::Span = Time::Span.zero) : Nil
      Async.await(->(result : Void*, error : C::Error**) { C.webkit_website_data_manager_clear_finish(self, result, error); nil }) do |callback, data|
        C.webkit_website_data_manager_clear(self, types.value, since.total_microseconds.to_i64, nil, callback, data)
      end
    end
  end
end
