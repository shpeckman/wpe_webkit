# src/wpe_webkit/policy_decision.cr
module WPEWebKit
  class NavigationAction < Wrapper
    boxed webkit_navigation_action_copy, webkit_navigation_action_free

    def navigation_type : NavigationType
      NavigationType.new(C.webkit_navigation_action_get_navigation_type(self))
    end

    def mouse_button : UInt32
      C.webkit_navigation_action_get_mouse_button(self)
    end

    def modifiers : UInt32
      C.webkit_navigation_action_get_modifiers(self)
    end

    def request : URIRequest
      URIRequest.from_raw(C.webkit_navigation_action_get_request(self), owner: self)
    end

    def user_gesture? : Bool
      C.webkit_navigation_action_is_user_gesture(self) != 0
    end

    def redirect? : Bool
      C.webkit_navigation_action_is_redirect(self) != 0
    end

    def frame_name : String?
      Native.string?(C.webkit_navigation_action_get_frame_name(self))
    end
  end

  class PolicyDecision < GObject
    SUBCLASSES = {
      "WebKitNavigationPolicyDecision" => NavigationPolicyDecision,
      "WebKitResponsePolicyDecision"   => ResponsePolicyDecision,
    }

    def self.from_raw(pointer : Void*) : PolicyDecision
      SUBCLASSES.fetch(GObject.type_name(pointer), PolicyDecision).new(pointer, owned: false)
    end

    def use : Nil
      C.webkit_policy_decision_use(self)
    end

    def ignore : Nil
      C.webkit_policy_decision_ignore(self)
    end

    def download : Nil
      C.webkit_policy_decision_download(self)
    end
  end

  class NavigationPolicyDecision < PolicyDecision
    def navigation_action : NavigationAction
      NavigationAction.from_raw(C.webkit_navigation_policy_decision_get_navigation_action(self), owner: self)
    end

    def request : URIRequest
      navigation_action.request
    end
  end

  class ResponsePolicyDecision < PolicyDecision
    def request : URIRequest
      URIRequest.from_raw(C.webkit_response_policy_decision_get_request(self), owner: self)
    end

    def response : URIResponse
      URIResponse.from_raw(C.webkit_response_policy_decision_get_response(self), owner: self)
    end

    def mime_type_supported? : Bool
      C.webkit_response_policy_decision_is_mime_type_supported(self) != 0
    end

    def main_frame_main_resource? : Bool
      C.webkit_response_policy_decision_is_main_frame_main_resource(self) != 0
    end
  end
end
