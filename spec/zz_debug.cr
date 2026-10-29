require "./spec_helper"
manager = WPEWebKit::UserContentManager.new
manager.on_script_message_with_reply("echo") { |value, reply| STDERR.puts "got #{value.to_i}"; reply.return_value({echo: value.to_i * 2}); STDERR.puts "replied" }
view = new_view(user_content_manager: manager)
wait_for_load(view) { view.load_html("<p></p>") }
STDERR.puts "loaded"
view.evaluate_javascript("window.webkit.messageHandlers.echo.postMessage(21).then(r => window.result = r.echo)")
STDERR.puts "evaluated"
iterate_until { view.evaluate_javascript("window.result").number? }
p view.evaluate_javascript("window.result").to_i
