-- server script for littleNET
require 'enet'
require 'message'
require 'coder'
require 'player'
require 'playerList'

export love

myPlayer = Player 0, 400, 300,
    math.random(5,255), math.random(5,255), math.random(5,255), NAME

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
        changed = myPlayer\inputs!
        -- recover events from the server
        event = @host\service!
        if event
            switch event.type
                when 'connect'
                    event.peer\send message.connection..myPlayer\dump true
                    @peer = event.peer
                when 'receive'
                    msgType = event.data\sub 1,1
                    msgData = event.data\sub 2
                    switch msgType
                        when message.refresh
                            @refresh event, fill(msgData)
                        when message.assignment
                            @assign  event, UNPACK.id msgData
                        when message.instance
                            @instantiate event, fill(msgData, true)
                        when message.connection
                            @connect event, fill(msgData, true)
                        when message.disconnection
                            @disconnect event, UNPACK.id msgData
        -- if the player moved 
        @peer\send message.refresh..myPlayer\dump! if changed and @peer
        
        -- keep connection with server open
        @server\ping!
        @connected = @server\round_trip_time!
        
        if @connected >= 500 then @error = "DISCONNECTED"
        else @error = nil
            
    
    -- update the position of the character
    refresh: (event, info)=>
        if info ~= nil
            -- update the position of the player
            player = playerList\get(info.id)
            if player ~= nil
                player\update info.x, info.y
            else love.errhand 'Player does not exists for id: '..info.id..'\n'..playerList\toString!
        else love.errhand 'Refresh failed, info is nil.'
            
    -- recover index for our new connection
    assign: (event, id)=>
        if id ~= nil
            -- change the id of the player so that
            -- it match the id on the server side
            myPlayer.id = id
            -- add our player to the list
            playerList\set id,myPLayer
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


draw   = ->
    playerList\draw!
    myPlayer\draw!
update = (dt)-> client\update dt
quit   = -> client\quit!

export LOAD
LOAD = (args)->
    love.window.setTitle "CLIENT"
    client\init "localhost", "18666"
    love.draw, love.update, love.quit = draw, update, quit
    