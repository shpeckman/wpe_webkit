# src/wpe_webkit/wrapper.cr
module WPEWebKit
  abstract class Wrapper
    getter to_unsafe : Void*

    def initialize(@to_unsafe : Void*, *, owned : Bool)
      @to_unsafe = self.class.c_ref(@to_unsafe) unless owned || @to_unsafe.null?
    end

    def self.from_raw(pointer : Void*) : self
      new(pointer, owned: false)
    end

    def self.from_raw?(pointer : Void*) : self?
      from_raw(pointer) unless pointer.null?
    end

    def self.take(pointer : Void*) : self
      new(pointer, owned: true)
    end

    def self.take?(pointer : Void*) : self?
      take(pointer) unless pointer.null?
    end

    def self.c_ref(pointer : Void*) : Void*
      C.g_object_ref(pointer)
    end

    def self.c_unref(pointer : Void*) : Nil
      C.g_object_unref(pointer)
    end

    def finalize
      self.class.c_unref(@to_unsafe) unless @to_unsafe.null?
    end

    def ==(other : Wrapper) : Bool
      to_unsafe == other.to_unsafe
    end

    def hash(hasher)
      to_unsafe.address.hash(hasher)
    end

    macro boxed(ref, unref)
      def self.c_ref(pointer : Void*) : Void*
        C.{{ref.id}}(pointer)
      end

      def self.c_unref(pointer : Void*) : Nil
        C.{{unref.id}}(pointer)
      end
    end
  end
end
