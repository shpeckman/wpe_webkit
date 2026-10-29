# src/wpe_webkit/handles.cr
module WPEWebKit
  module Handles
    @@live = {} of Void* => Reference

    RELEASE         = ->(data : Void*) { Handles.release(data) }
    RELEASE_CLOSURE = ->(data : Void*, _closure : Void*) { Handles.release(data) }

    def self.retain(value : T) : Void* forall T
      box = Box(T).new(value)
      pointer = box.as(Void*)
      @@live[pointer] = box
      pointer
    end

    def self.release(pointer : Void*) : Nil
      @@live.delete(pointer)
    end

    def self.size : Int32
      @@live.size
    end
  end
end
