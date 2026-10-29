# src/wpe_webkit/headers.cr
require "http/headers"

module WPEWebKit
  module Headers
    RESPONSE = 1

    COLLECT = ->(name : UInt8*, value : UInt8*, data : Void*) {
      Box(HTTP::Headers).unbox(data).add(String.new(name), String.new(value))
      nil
    }

    def self.from_soup(pointer : Void*) : HTTP::Headers
      headers = HTTP::Headers.new
      return headers if pointer.null?
      C.soup_message_headers_foreach(pointer, COLLECT, Box(HTTP::Headers).box(headers))
      headers
    end

    def self.to_soup(headers : HTTP::Headers) : Void*
      pointer = C.soup_message_headers_new(RESPONSE)
      headers.each do |name, values|
        values.each { |value| C.soup_message_headers_append(pointer, name, value) }
      end
      pointer
    end
  end
end
