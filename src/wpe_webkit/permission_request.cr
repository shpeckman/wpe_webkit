# src/wpe_webkit/permission_request.cr
module WPEWebKit
  class PermissionRequest < GObject
    KINDS = {
      "WebKitGeolocationPermissionRequest"        => PermissionKind::Geolocation,
      "WebKitNotificationPermissionRequest"       => PermissionKind::Notification,
      "WebKitUserMediaPermissionRequest"          => PermissionKind::UserMedia,
      "WebKitDeviceInfoPermissionRequest"         => PermissionKind::DeviceInfo,
      "WebKitMediaKeySystemPermissionRequest"     => PermissionKind::MediaKeySystem,
      "WebKitWebsiteDataAccessPermissionRequest"  => PermissionKind::WebsiteDataAccess,
      "WebKitXRPermissionRequest"                 => PermissionKind::XR,
    }

    def kind : PermissionKind
      KINDS.fetch(GObject.type_name(to_unsafe), PermissionKind::Unknown)
    end

    def allow : Nil
      C.webkit_permission_request_allow(self)
    end

    def deny : Nil
      C.webkit_permission_request_deny(self)
    end
  end
end
