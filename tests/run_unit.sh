#!/bin/sh
#
# Run the lunatest unit specs (stand-in display, stage and transition) with plain Lua 5.1.
#
# usage: tests/run_unit.sh
#   override the interpreter with LUA=

set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
LUA=${LUA:-$ROOT/../tools/lua51/bin/lua}

cd "$ROOT"
LUA_PATH="$ROOT/?.lua;$HERE/?.lua;$($LUA -e 'io.write(package.path)')"
LUA_CPATH="$($LUA -e 'io.write(package.cpath)')"
export LUA_PATH LUA_CPATH

# stand-ins for the Solar2D globals dmc_corona_boot needs
"$LUA" -e "
package.preload.json = package.preload.json or function() return require 'dkjson' end
system = { pathForFile=function( f ) return f end, ResourceDirectory='.' }
local lunatest = require 'lunatest'
lunatest.suite( 'dmc_dragdrop_spec' )
lunatest.run()
"
