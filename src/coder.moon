require 'struct'

-- https://github.com/iryont/lua-struct

export PACK, UNPACK
PACK =
    full: (player)->
        return struct.pack('<BffBBBs',
            player.id, player.x, player.y,
            player.red, player.green, player.blue, player.name)
    
    pos: (player)->
        return struct.pack('<Bff',
            player.id, player.x, player.y)
    
    id: (id)-> struct.pack('<B', id or 0)

UNPACK =
    full: (packed)->
        return nil if packed == nil
        info = {}
        info.id, info.x, info.y, info.red, info.green, info.blue, info.name = struct.unpack('<BffBBBs', packed)
        return info
    
    pos: (packed)->
        return nil if packed == nil
        info = {}
        info.id, info.x, info.y = struct.unpack('<Bff', packed)
        return info
    
    id: (packed)->
        return nil if packed == nil
        return struct.unpack('<B', packed)