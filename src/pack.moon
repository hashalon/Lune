require 'struct'

-- https://github.com/iryont/lua-struct

export PACK, UNPACK
PACK =
    -- pack all informations regarding a player
    full: (player)->
        struct.pack('<BffBBBs',
            player.id, player.x, player.y,
            player.red, player.green, player.blue, player.name
        )
    
    -- pack position of a player
    pos: (player)-> struct.pack('<Bff', player.id, player.x, player.y)
    
    -- pack inputs with id
    inputs: (id, inputs)-> struct.pack('<BB', id, inputs)
    
    -- pack id
    id: (id)-> struct.pack('<B', id)
    

UNPACK =
    -- unpack all informations regarding a player
    full: (packed)->
        return nil if packed == nil
        i = {}
        i.id,i.x,i.y,i.red,i.green,i.blue,i.name = struct.unpack(
            '<BffBBBs', tostring packed
        )
        return i
    
    -- unpack position of a player
    pos: (packed)->
        return nil if packed == nil
        info = {}
        info.id, info.x, info.y = struct.unpack('<Bff', tostring packed)
        return info
    
    -- unpack inputs and id
    inputs: (packed)->
        return nil if packed == nil
        info = {}
        info.id, info.inputs = struct.unpack('<BB', tostring packed)
        return info
    
    -- unpack id
    id: (packed)->
        return nil if packed == nil
        return struct.unpack('<B', tostring packed)

-- function to print the content of a network frame
export debug_print
debug_print = (trame)->
    str = 'trame: '
    for i = 1,#trame
        char = trame\sub(i,i)\byte!
        str ..= char..', '
    print str
    return str