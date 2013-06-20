#
# FIXME: workaround for JRuby 1.7.4, where C extensions are
# disabled. This can be removed, apparently, when 1.7.5 is released.
#
if defined? ENV_JAVA
  ENV_JAVA['jruby.cext.enabled'] = 'true'
end

require 'mkmf'

create_makefile('sodium/ffi/memory')
