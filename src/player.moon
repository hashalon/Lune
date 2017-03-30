require 'coder'

export Player
class  Player
    
    -- constructor for character
    new: (id, x, y, red, green, blue, name)=>
        if type(id) == "table"
            @set id
        else
            @id, @x, @y = id or 0, x or 0, y or 0
            @red, @green, @blue = red or 255, green or 255, blue or 255
            @name  = name or 'noname'
        @radius = 10
        @speed  =  2
    
    -- set infos of the character
    set: (info)=>
        @id, @x, @y = info.id or 0, info.x or 0, info.y or 0
        @red, @green, @blue = info.red or 255, info.green or 255, info.blue or 255
        @name  = info.name or 'noname'
        return @
    
    inputs: =>
        kb, dx, dy = love.keyboard.isDown, 0, 0
        dy = -@speed if kb 'up'
        dy =  @speed if kb 'down'
        dx = -@speed if kb 'left'
        dx =  @speed if kb 'right'
        @x += dx
        @y += dy
        return dx ~= 0 or dy ~= 0
    
    -- update the position of the character
    update: (x, y)=>
        @x = x
        @y = y
        return @
    
    -- draw the character
    draw: =>
        gfx = love.graphics
        gfx.setColor @red, @green, @blue
        gfx.circle 'fill', @x, @y, @radius, @radius
        gfx.setColor 255, 255, 255
        --gfx.print @name, @x - (gfx.getFont!\getWidth(@name)/2), @y - (@radius + gfx.getFont!\getHeight!)
    
    -- dump infos into a string data
    dump: (all)=>
        return PACK.full @ if all
        return PACK.pos  @

-- extract infos from a string data
export fill
fill = (str, all)->
    return UNPACK.full str if all
    return UNPACK.pos  str