# spec/spec_helper.cr
require "spec"
require "../src/wpe_webkit"

DISPLAY = WPEWebKit::Display.headless

def new_view(**options) : WPEWebKit::WebView
  WPEWebKit::WebView.new(**options, display: DISPLAY)
end

def iterate_until(timeout : Time::Span = 15.seconds, & : -> Bool) : Bool
  deadline = Time.instant + timeout
  until yield
    return false if Time.instant > deadline
    WPEWebKit::MainLoop.iterate
  end
  true
end

def wait_for_load(view : WPEWebKit::WebView, & : ->) : Nil
  finished = false
  handler = view.on_load_changed { |event| finished = true if event.finished? }
  yield
  iterate_until { finished }.should be_true
  view.disconnect(handler)
end
