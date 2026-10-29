# src/wpe_webkit/main_loop.cr
module WPEWebKit
  class WrongFiberError < Exception
    def initialize
      super("WPEWebKit must be driven from the main fiber")
    end
  end

  module MainLoop
    class Poller
      @fds = Pointer(C::PollFD).null
      @count = 0_u64
      @timeout = 0
      @request_read : Int32
      @request_write : Int32

      def initialize
        pipe = uninitialized LibC::Int[2]
        raise RuntimeError.from_errno("pipe") unless LibC.pipe(pipe) == 0
        @request_read = pipe[0]
        @request_write = pipe[1]
        @response_reader, @response_writer = IO.pipe
        Thread.new("wpe-webkit-poll") { run }
      end

      def poll(fds : C::PollFD*, count : Int32, timeout : Int32) : Nil
        @fds = fds
        @count = count.to_u64
        @timeout = timeout
        byte = 1_u8
        LibC.write(@request_write, pointerof(byte), 1)
        @response_reader.read_byte
      end

      private def run : Nil
        byte = 0_u8
        loop do
          read = LibC.read(@request_read, pointerof(byte), 1)
          next if read < 0 && Errno.value.eintr?
          break if read <= 0
          C.poll(@fds, @count, @timeout)
          LibC.write(@response_writer.fd, pointerof(byte), 1)
        end
      end
    end

    @@main = Fiber.current
    @@running = false
    @@acquired = false
    @@poller : Poller? = nil
    @@fds = Slice(C::PollFD).new(16, C::PollFD.new)

    class_property max_poll_interval : Time::Span = 10.milliseconds

    def self.context : Void*
      C.g_main_context_default
    end

    def self.running? : Bool
      @@running
    end

    def self.main_fiber? : Bool
      Fiber.current == @@main
    end

    def self.run : Nil
      @@running = true
      while @@running
        iterate
      end
    end

    def self.quit : Nil
      @@running = false
      C.g_main_context_wakeup(context)
    end

    def self.iterate : Nil
      raise WrongFiberError.new unless main_fiber?
      ctx = context
      @@acquired ||= C.g_main_context_acquire(ctx) != 0
      priority = 0
      C.g_main_context_prepare(ctx, pointerof(priority))
      timeout = 0
      count = C.g_main_context_query(ctx, priority, pointerof(timeout), @@fds.to_unsafe, @@fds.size)
      if count > @@fds.size
        @@fds = Slice(C::PollFD).new(count, C::PollFD.new)
        count = C.g_main_context_query(ctx, priority, pointerof(timeout), @@fds.to_unsafe, @@fds.size)
      end
      wait(count, timeout)
      C.g_main_context_dispatch(ctx) if C.g_main_context_check(ctx, priority, @@fds.to_unsafe, count) != 0
    end

    private def self.wait(count : Int32, timeout : Int32) : Nil
      cap = max_poll_interval.total_milliseconds.to_i
      timeout = cap if timeout < 0 || timeout > cap
      if timeout == 0
        C.poll(@@fds.to_unsafe, count.to_u64, 0)
        Fiber.yield
      else
        (@@poller ||= Poller.new).poll(@@fds.to_unsafe, count, timeout)
      end
    end
  end

  def self.run : Nil
    MainLoop.run
  end

  def self.quit : Nil
    MainLoop.quit
  end
end
