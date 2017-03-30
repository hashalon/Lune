-- server script for littleNET
require 'enet'
require 'message'
require 'coder'
require 'player'
require 'playerList'

export love

-- we need to change the seed to get new values
math.randomseed os.time!

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
                    when message.refresh
                        @refresh event, fill(msgData)
                    when message.connection
                        @connect event, fill(msgData, true)
                    when message.disconnection
                        @disconnect event, UNPACK.id msgData
    
    -- update the position of the character
    refresh: (event, info)=>
        if info ~= nil
            -- update the position of the player
            playerList\get(info.id)\update info.x, info.y
            
            -- notify other players
            for id, peer in pairs @peers
                peer\send event.data if id ~= info.id
        else love.errhand 'Refresh failed, info is nil.'
            
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

                -- notify other players and recover them
                for id, player in pairs playerList.players
                    if id == index -- same player
                        -- to new player, we send him his ID
                        event.peer\send message.assignment..PACK.id index
                    else -- different player
                        -- to new player,
                        -- we send him data regarding other players
                        event.peer\send message.instance..player\dump true
                        -- to other players,
                        -- we send them the data regarding the new player
                        @peers[id]\send message.connection..newPlayer\dump true
                
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


draw   = -> playerList\draw!
update = (dt)-> server\update dt
quit   = -> server\quit!

export LOAD
LOAD = (args)->
    love.window.setTitle "SERVER"
    server\init "localhost", "18666"
    love.draw, love.update, love.quit = draw, update, quit
    