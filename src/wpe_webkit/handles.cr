# src/wpe_webkit/handles.cr
module WPEWebKit
  module Handles
    abstract class Handle
    end

    class Holder(T) < Handle
      getter value : T

      def initialize(@value : T)
      end
    end

    @@live = {} of Void* => Handle

    RELEASE         = ->(data : Void*) { Handles.release(data) }
    RELEASE_CLOSURE = ->(data : Void*, _closure : Void*) { Handles.release(data) }

    def self.retain(value : T) : Void* forall T
      holder = Holder(T).new(value)
      pointer = holder.as(Void*)
      @@live[pointer] = holder
      pointer
    end

    def self.get(pointer : Void*, type : T.class) : T forall T
      pointer.as(Holder(T)).value
    end

    def self.release(pointer : Void*) : Nil
      @@live.delete(pointer)
    end
  end
end
