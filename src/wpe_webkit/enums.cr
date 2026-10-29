# src/wpe_webkit/enums.cr
module WPEWebKit
  enum LoadEvent
    Started
    Redirected
    Committed
    Finished
  end

  enum PolicyDecisionType
    NavigationAction
    NewWindowAction
    Response
  end

  enum NavigationType
    LinkClicked
    FormSubmitted
    BackForward
    Reload
    FormResubmitted
    Other
  end

  enum InjectedFrames
    AllFrames
    TopFrame
  end

  enum InjectionTime
    DocumentStart
    DocumentEnd
  end

  enum StyleLevel
    User
    Author
  end

  enum CookieAcceptPolicy
    Always
    Never
    NoThirdParty
  end

  enum CookieStorage
    Text
    SQLite
  end

  enum TLSErrorsPolicy
    Ignore
    Fail
  end

  enum ProxyMode
    Default
    NoProxy
    Custom
  end

  enum CacheModel
    DocumentViewer
    WebBrowser
    DocumentBrowser
  end

  enum SnapshotRegion
    Visible
    FullDocument
  end

  enum ScriptDialogType
    Alert
    Confirm
    Prompt
    BeforeUnloadConfirm
  end

  enum InsecureContentEvent
    Run
    Displayed
  end

  enum WebProcessTerminationReason
    Crashed
    ExceededMemoryLimit
    TerminatedByAPI
  end

  enum PermissionKind
    Geolocation
    Notification
    UserMedia
    DeviceInfo
    MediaKeySystem
    WebsiteDataAccess
    XR
    Unknown
  end

  @[Flags]
  enum WebsiteDataTypes
    MemoryCache
    DiskCache
    OfflineApplicationCache
    SessionStorage
    LocalStorage
    IndexedDBDatabases
    Cookies
    DeviceIdHashSalt
    HSTSCache
    ITP
    ServiceWorkerRegistrations
    DOMCache
  end

  @[Flags]
  enum FindOptions
    CaseInsensitive
    AtWordStarts
    TreatMedialCapitalAsWordStart
    Backwards
    WrapAround
  end

  @[Flags]
  enum SnapshotOptions
    IncludeSelectionHighlighting
    TransparentBackground
  end

  @[Flags]
  enum ToplevelState
    Fullscreen
    Maximized
    Active
  end
end
