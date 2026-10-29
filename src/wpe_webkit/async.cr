# src/wpe_webkit/async.cr
module WPEWebKit
  module Async
    abstract class Completion
      abstract def complete(result : Void*) : Nil
    end

    CALLBACK = ->(_source : Void*, result : Void*, data : Void*) {
      Handles.get(data, Completion).complete(result)
      Handles.release(data)
      nil
    }

    class Pending(T) < Completion
      @outcome : T | ::Exception | Nil = nil
      @done = false

      def initialize(&@finish : Void*, C::Error** -> T)
      end

      def complete(result : Void*) : Nil
        error = Pointer(C::Error).null
        value = @finish.call(result, pointerof(error))
        @outcome = error.null? ? value : GLibError.take(error)
      rescue ex
        @outcome = ex
      ensure
        @done = true
      end

      def wait : T
        MainLoop.iterate until @done
        outcome = @outcome
        raise outcome if outcome.is_a?(::Exception)
        outcome.as(T)
      end
    end

    def self.await(finish : Void*, C::Error** -> T, & : C::AsyncReadyCallback, Void* -> _) : T forall T
      raise WrongFiberError.new unless MainLoop.main_fiber?
      pending = Pending(T).new(&finish)
      yield CALLBACK, Handles.retain(pending.as(Completion))
      pending.wait
    end
  end
end
