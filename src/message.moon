-- define the types of message we can encounter
export message
message = 
    refresh:       "r" -- update positions of player
    assignment:    "a" -- set index of player
    instance:      "i" -- recover players from server
    connection:    "c" -- add new player
    disconnection: "d" -- remove player