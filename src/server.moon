-- server script for littleNET
require 'enet'
require 'message'
require 'pack'
require 'player'
require 'playerList'

export love

-- initialize the server
server =
    
    -- initialize the server
    init: (address, port)=>
        @host    = enet.host_create address..":"..port
        @peers   = {}

    -- update the server at regular intervals
    update: (deltaTime)=>
        event = @host\service!
        if event
            if event.type == "receive"
                msgType = event.data\sub 1,1
                msgData = event.data\sub 2
                switch msgType
                    when message.inputs
                        @inputs     event, UNPACK.inputs msgData
                    when message.connection
                        @connect    event, UNPACK.full   msgData
                    when message.disconnection
                        @disconnect event, UNPACK.id     msgData
    
    -- update the position of the character based on inputs
    inputs: (event, info)=>
        if info ~= nil
            -- apply inputs to the player
            player = playerList\get(info.id)
            player\inputs info.inputs
            
            -- notify other players
            msg = message.refresh..PACK.pos player 
            for id, peer in pairs @peers
                peer\send msg
        else love.errhand 'Inputs failed, info is nil.'
            
    -- connection of new character
    connect: (event, info)=>
        if info ~= nil
            
            -- get next available ID for this new player
            index = playerList\availableID!
            
            if index ~= nil
                info.id = index -- store the new id
                -- create new player and add it to the list
                newPlayer = Player info
                playerList\set(index, newPlayer)
                @peers[index] = event.peer
                
                -- to new player, we send him his ID
                event.peer\send message.assignment..PACK.id index
                
                -- notify other players and recover them
                for id, player in pairs playerList.players
                    if id ~= index -- different player
                        -- to new player,
                        -- we send him data regarding other players
                        event.peer\send message.instance..PACK.full player
                        -- to other players,
                        -- we send them the data regarding the new player
                        @peers[id]\send message.connection..PACK.full newPlayer
                
            else love.errhand 'Connection failed, index is nil.'
        else love.errhand 'Connection failed, info is nil.'
    
    -- disconnection of character
    disconnect: (event, id)=>
        if id ~= nil
            -- remove player from list
            playerList\set(id, nil)
            @peers[id] = nil

            -- notify other players
            for id, peer in pairs @peers
                peer\send event.data
        else love.errhand 'Disconnection failed, id is nil.'
    
    quit: => -- do nothing ?


update = (dt)-> server\update dt
quit   = -> server\quit!
draw   = -> playerList\draw!

export LOAD
LOAD = (args)->
    love.window.setTitle 'SERVER '..ADDRESS..':'..PORT
    server\init ADDRESS,PORT
    love.draw, love.update, love.quit = draw, update, quit
    