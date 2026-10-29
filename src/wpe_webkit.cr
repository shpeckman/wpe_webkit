# src/wpe_webkit.cr
require "./wpe_webkit/c/*"
require "./wpe_webkit/error"
require "./wpe_webkit/native"
require "./wpe_webkit/handles"
require "./wpe_webkit/wrapper"
require "./wpe_webkit/g_object"
require "./wpe_webkit/enums"
require "./wpe_webkit/async"
require "./wpe_webkit/main_loop"
require "./wpe_webkit/*"

module WPEWebKit
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
