# src/wpe_webkit/script_dialog.cr
module WPEWebKit
  class ScriptDialog < Wrapper
    boxed webkit_script_dialog_ref, webkit_script_dialog_unref

    def type : ScriptDialogType
      ScriptDialogType.new(C.webkit_script_dialog_get_dialog_type(self))
    end

    def message : String
      String.new(C.webkit_script_dialog_get_message(self))
    end

    def confirmed=(confirmed : Bool)
      C.webkit_script_dialog_confirm_set_confirmed(self, confirmed ? 1 : 0)
    end

    def default_text : String?
      Native.string?(C.webkit_script_dialog_prompt_get_default_text(self))
    end

    def text=(text : String)
      C.webkit_script_dialog_prompt_set_text(self, text)
    end

    def close : Nil
      C.webkit_script_dialog_close(self)
    end
  end
end
