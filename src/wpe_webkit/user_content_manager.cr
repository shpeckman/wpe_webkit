# src/wpe_webkit/user_content_manager.cr
module WPEWebKit
  class UserScript < Wrapper
    boxed webkit_user_script_ref, webkit_user_script_unref

    def self.new(source : String, *, injected_frames : InjectedFrames = :all_frames, injection_time : InjectionTime = :document_end, world : String? = nil, allow_list : Enumerable(String)? = nil, block_list : Enumerable(String)? = nil) : self
      take(C.webkit_user_script_new_for_world(source, injected_frames.value, injection_time.value, Native.string(world), Native.strv(allow_list), Native.strv(block_list)))
    end
  end

  class UserStyleSheet < Wrapper
    boxed webkit_user_style_sheet_ref, webkit_user_style_sheet_unref

    def self.new(source : String, *, injected_frames : InjectedFrames = :all_frames, level : StyleLevel = :user, world : String? = nil, allow_list : Enumerable(String)? = nil, block_list : Enumerable(String)? = nil) : self
      take(C.webkit_user_style_sheet_new_for_world(source, injected_frames.value, level.value, Native.string(world), Native.strv(allow_list), Native.strv(block_list)))
    end
  end

  class ScriptMessageReply < Wrapper
    boxed webkit_script_message_reply_ref, webkit_script_message_reply_unref

    getter context : JSContext

    def initialize(pointer : Void*, @context : JSContext)
      super(pointer, owned: false)
    end

    def return_value(value) : Nil
      C.webkit_script_message_reply_return_value(self, JSValue.from_json(context, value.to_json))
    end

    def return_error(message : String) : Nil
      C.webkit_script_message_reply_return_error_message(self, message)
    end
  end

  class UserContentManager < GObject
    def self.new : self
      take(C.webkit_user_content_manager_new)
    end

    def add_script(script : UserScript) : Nil
      C.webkit_user_content_manager_add_script(self, script)
    end

    def remove_script(script : UserScript) : Nil
      C.webkit_user_content_manager_remove_script(self, script)
    end

    def remove_all_scripts : Nil
      C.webkit_user_content_manager_remove_all_scripts(self)
    end

    def add_style_sheet(style_sheet : UserStyleSheet) : Nil
      C.webkit_user_content_manager_add_style_sheet(self, style_sheet)
    end

    def remove_style_sheet(style_sheet : UserStyleSheet) : Nil
      C.webkit_user_content_manager_remove_style_sheet(self, style_sheet)
    end

    def remove_all_style_sheets : Nil
      C.webkit_user_content_manager_remove_all_style_sheets(self)
    end

    def unregister_script_message_handler(name : String, world : String? = nil) : Nil
      C.webkit_user_content_manager_unregister_script_message_handler(self, name, Native.string(world))
    end

    def on_script_message(name : String, world : String? = nil, &block : JSValue -> Nil) : UInt64
      C.webkit_user_content_manager_register_script_message_handler(self, name, Native.string(world))
      on_script_message_received(name, &block)
    end

    def on_script_message_with_reply(name : String, world : String? = nil, &block : JSValue, ScriptMessageReply -> Nil) : UInt64
      C.webkit_user_content_manager_register_script_message_handler_with_reply(self, name, Native.string(world))
      on_script_message_with_reply_received(name) do |value, reply|
        block.call(value, ScriptMessageReply.new(reply, value.context))
        true
      end
    end

    private signal script_message_received, "script-message-received", {value: JSValue}, detailed: true
    private signal script_message_with_reply_received, "script-message-with-reply-received", {value: JSValue, reply: Pointer(Void)}, Bool, detailed: true
  end
end
