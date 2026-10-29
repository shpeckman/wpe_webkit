# src/wpe_webkit/native.cr
module WPEWebKit
  module Native
    def self.string(value : String?) : UInt8*
      value ? value.to_unsafe : Pointer(UInt8).null
    end

    def self.string?(pointer : UInt8*) : String?
      String.new(pointer) unless pointer.null?
    end

    def self.take_string?(pointer : UInt8*) : String?
      return if pointer.null?
      String.new(pointer).tap { C.g_free(pointer) }
    end

    def self.strv(values : Enumerable(String)?) : UInt8**
      return Pointer(UInt8*).null unless values
      array = values.map(&.to_unsafe).to_a
      array << Pointer(UInt8).null
      array.to_unsafe
    end

    def self.list(list : C::List*, & : Void* ->) : Nil
      node = list
      until node.null?
        yield node.value.data
        node = node.value.next
      end
    end

    def self.take_list(list : C::List*, & : Void* -> T) : Array(T) forall T
      result = [] of T
      list(list) { |data| result << yield data }
      C.g_list_free(list)
      result
    end

    def self.bytes(data : String | Bytes) : Void*
      C.g_bytes_new(data.to_unsafe, data.bytesize)
    end

    def self.read_bytes(bytes : Void*) : Bytes
      size = LibC::SizeT.new(0)
      data = C.g_bytes_get_data(bytes, pointerof(size))
      Bytes.new(size).tap { |copy| copy.copy_from(data.as(UInt8*), size) }
    end
  end
end
