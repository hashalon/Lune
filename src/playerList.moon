require 'player'

names = {"Robert", "Marco", "Alfred", "Messi", "Norton", "Boris", "George", "Janine", "Maria"}

NAME = names[math.floor math.random 1,#names]

-- class to manage a list of clients
export playerList
playerList =
    
    -- containa the players
    players: {}
    
    -- function to draw each player
    draw: => player\draw! for id, player in pairs @players
    
    -- get player from id
    get: (id)=> @players[id] if id ~= nil
    
    -- set player with id
    set: (id, player)=> @players[id] = player if id ~= nil
    
    -- recover the number of players connected
    size: =>
        count = 0
        for id, player in pairs @players
            count += 1
        return count
    
    -- recover the next available id
    availableID: =>
        for i = 1,255
            if @players[i] == nil
                return i
    
    toString: =>
        str = "List of players :\n"
        for id, player in pairs @players
            str ..= id..'\n'--' : '..player.name..'\n'
        return str
            
    
    