# src/wpe_webkit/find_controller.cr
module WPEWebKit
  class FindController < GObject
    def search(text : String, options : FindOptions = :none, max_match_count : Int = UInt32::MAX) : Nil
      C.webkit_find_controller_search(self, text, options.value.to_u32, max_match_count.to_u32)
    end

    def count_matches(text : String, options : FindOptions = :none, max_match_count : Int = UInt32::MAX) : Nil
      C.webkit_find_controller_count_matches(self, text, options.value.to_u32, max_match_count.to_u32)
    end

    def search_next : Nil
      C.webkit_find_controller_search_next(self)
    end

    def search_previous : Nil
      C.webkit_find_controller_search_previous(self)
    end

    def finish : Nil
      C.webkit_find_controller_search_finish(self)
    end

    def search_text : String?
      Native.string?(C.webkit_find_controller_get_search_text(self))
    end

    def options : FindOptions
      FindOptions.new(C.webkit_find_controller_get_options(self).to_i32)
    end

    def max_match_count : UInt32
      C.webkit_find_controller_get_max_match_count(self)
    end

    signal found_text, "found-text", {match_count: UInt32}
    signal failed_to_find_text, "failed-to-find-text"
    signal counted_matches, "counted-matches", {match_count: UInt32}
  end
end
