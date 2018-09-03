-- server script for littleNET
require 'enet'
require 'message'
require 'pack'
require 'player'
require 'playerList'

export love

-- the player we are playing with
myPlayer = Player 0, 400, 300

-- funtion to compare two number (with an error)
compare = (a,b,d)-> math.abs(a - b) > d

-- store all of the inputs
compensation =
    
    -- do we still need to interpolate the position of the player
    keepInterpolating: false
    
    interpolation: 0.1
    threshold:     0.1
    newX: myPlayer.x
    newY: myPlayer.y
    list: {} -- list of inputs
    
    add: (bin)=> @list[#@list+1] = bin
    
    -- aplly the inputs on the last state of the player
    apply: (x, y)=>
        temp = {:x, :y, speed: myPlayer.speed}
        for i = 1,#@list
            -- we call the inputs function of player on a dummy object
            myPlayer.inputs temp,@list[i]
        @list = {} -- clear the list
        @newX, @newY = temp.x, temp.y
        keepInterpolating = true
    
    interpolate: =>
        myPlayer\refresh @newX,@newY,@interpolation
        keepInterpolating = (
            compare(myPlayer.x, @newX, @threshold) or
            compare(myPlayer.y, @newY, @threshold)
        )


-- initialize the client
client =
    
    -- initialize the server
    init: (address, port)=>
        @fname  = "user:"
        @fname ..= myPlayer.name if myPlayer.name ~= nil
        @host   = enet.host_create!
        @server = @host\connect address..":"..port

    -- update the server at regular intervals
    update: (deltaTime)=>
        -- move the player
        inputs = getInputs!
        -- recover events from the server
        event = @host\service!
        if event
            switch event.type
                when 'connect'
                    event.peer\send message.connection..PACK.full myPlayer
                    @peer = event.peer
                when 'receive'
                    msgType = event.data\sub 1,1
                    msgData = event.data\sub 2
                    switch msgType
                        when message.refresh
                            @refresh     event, UNPACK.pos  msgData
                        when message.assignment
                            @assign      event, UNPACK.id   msgData
                        when message.instance
                            @instantiate event, UNPACK.full msgData
                        when message.connection
                            @connect     event, UNPACK.full msgData
                        when message.disconnection
                            @disconnect  event, UNPACK.id   msgData
        -- if the player moved
        if @peer and (inputs ~= 0)
            compensation\add inputs -- keep track of the inputs
            myPlayer\inputs  inputs -- apply directly inputs to avoid lags
            @peer\send message.inputs..PACK.inputs myPlayer.id,inputs
        
        -- if we need to keep on interpolating, keep interpolate
        compensation\interpolate! if compensation.keepInterpolating
        
        -- keep connection with server open
        @server\ping!
        @deltaTime = @server\round_trip_time!
        
        if @deltaTime >= 500 then @error = "DISCONNECTED"
        else @error = nil
            
    
    -- update the position of the character
    refresh: (event, info)=>
        if info ~= nil
            -- update the position of the player
            player = playerList\get(info.id)
            if player ~= nil
                if player == myPlayer
                    compensation\apply info.x,info.y
                else
                    player\refresh info.x,info.y
            else love.errhand 'Player does not exists for id: '..info.id..'\n'..playerList\toString!
        else love.errhand 'Refresh failed, info is nil.'
            
    -- recover index for our new connection
    assign: (event, id)=>
        if id ~= nil
            -- change the id of the player so that
            -- it match the id on the server side
            myPlayer.id = id
            -- add our player to the list
            playerList\set id,myPlayer
        else love.errhand 'Assignment failed, id is nil.'
    
    -- recover information regarding existing player
    instantiate: (event, info)=>
        if info ~= nil
            -- add player in the list
            playerList\set info.id,Player info
        else love.errhand 'Instantiation failed, info is nil.'
    
    -- connection of player
    connect: (event, info)=>
        if info ~= nil
            -- add player in the list
            playerList\set info.id,Player info
        else love.errhand 'Connection failed, info is nil.'
    
    -- disconnection of player
    disconnect: (event, id)=>
        if id ~= nil
            -- remove player from list
            playerList\set id,nil
        else love.errhand 'Disconnection failed, id is nil.'
    
    quit: =>
        -- if the server is still up, send disconnection message
        @peer\send message.disconnection..PACK.id myPlayer.id if @peer
        event = @host\service(100)
        -- perform disconnection
        @server\disconnect_later!
        @host\flush!

update = (dt)-> client\update dt
quit   = -> client\quit!
draw   = -> playerList\draw!
--myPlayer\draw!

export LOAD
LOAD = (args)->
    myPlayer.name  = 'noname'
    myPlayer.red   = math.random(5,255)
    myPlayer.green = math.random(5,255)
    myPlayer.blue  = math.random(5,255)
    for i,arg in pairs args
        nextArg = args[i+1]
        if nextArg ~= nil
            switch arg
                when '--name' then myPlayer.name  = nextArg
                when '-r'     then myPlayer.red   = nextArg
                when '-g'     then myPlayer.green = nextArg
                when '-b'     then myPlayer.blue  = nextArg
    love.window.setTitle 'CLIENT '..myPlayer.name
    client\init ADDRESS,PORT
    love.draw, love.update, love.quit = draw, update, quit
    