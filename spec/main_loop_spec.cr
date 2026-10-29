# spec/main_loop_spec.cr
require "./spec_helper"

describe WPEWebKit::MainLoop do
  it "runs until quit while other fibers keep working" do
    ticks = 0
    spawn do
      3.times do
        ticks += 1
        sleep 5.milliseconds
      end
      WPEWebKit.quit
    end
    WPEWebKit.run
    ticks.should eq(3)
  end

  it "rejects use from other fibers" do
    error = nil
    done = Channel(Nil).new
    spawn do
      WPEWebKit::MainLoop.iterate
    rescue ex
      error = ex
    ensure
      done.send(nil)
    end
    done.receive
    error.should be_a(WPEWebKit::WrongFiberError)
  end
end
