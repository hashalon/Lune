bit = require 'bit'

fixString = (str)->
    if str == nil
        return 'noname'
    return tostring str

export Player
class  Player
    
    -- constructor for character
    new: (id, x, y, red, green, blue, name)=>
        if type(id) == "table"
            @set id
        else
            @id, @x, @y = id or 0, x or 0, y or 0
            @red, @green, @blue = red or 255, green or 255, blue or 255
            @name = fixString name
        @radius = 10
        @speed  =  2
    
    -- set infos of the character
    set: (info)=>
        @id, @x, @y = info.id or 0, info.x or 0, info.y or 0
        @red, @green, @blue = info.red or 255, info.green or 255, info.blue or 255
        @name = fixString info.name
        return @
    
    inputs: (bin)=>
        dx = bit.band bin,0x3 -- 0011
        dy = bit.band bin,0xC -- 1100
        if     dx == 0x1 then @x -= @speed
        elseif dx == 0x2 then @x += @speed
        if     dy == 0x4 then @y -= @speed
        elseif dy == 0x8 then @y += @speed
        return @
        
    -- refresh the position of the character
    refresh: (x, y, inter)=>
        -- interpolate the move
        if inter ~= nil
            dx = x - @x
            dy = y - @y
            @x += dx * inter
            @y += dy * inter
        else
            @x = x
            @y = y
        return @
    
    -- draw the character
    draw: =>
        gfx = love.graphics
        gfx.setColor @red, @green, @blue
        gfx.circle 'fill', @x, @y, @radius, @radius
        gfx.setColor 255, 255, 255
        gfx.print @name, @x - (gfx.getFont!\getWidth(@name)/2), @y - (@radius + gfx.getFont!\getHeight!)
        return @

-- get keyboard inputs
-- generate an integer containing all of the values
export getInputs
getInputs = ->
    kb = love.keyboard.isDown
    l = if kb 'left'  then 0x1 else 0 -- 0001
    r = if kb 'right' then 0x2 else 0 -- 0010
    u = if kb 'up'    then 0x4 else 0 -- 0100
    d = if kb 'down'  then 0x8 else 0 -- 1000
    return bit.bor l,r,u,d