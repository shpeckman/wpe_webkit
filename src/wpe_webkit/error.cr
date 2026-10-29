# src/wpe_webkit/error.cr
module WPEWebKit
  class GLibError < Exception
    getter domain : String
    getter code : Int32

    def initialize(@domain : String, @code : Int32, message : String)
      super(message)
    end

    def self.from_raw(pointer : Void*) : self
      error = pointer.as(C::Error*).value
      new(String.new(C.g_quark_to_string(error.domain)), error.code, String.new(error.message))
    end

    def self.take(pointer : C::Error*) : self
      from_raw(pointer.as(Void*)).tap { C.g_error_free(pointer) }
    end

    def self.check!(& : C::Error** -> _)
      error = Pointer(C::Error).null
      result = yield pointerof(error)
      raise take(error) unless error.null?
      result
    end
  end
end
