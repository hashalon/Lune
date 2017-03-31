-- entry point of the program
-- chose the right configuration
export love

-- we need to change the seed to get new values
math.randomseed os.time!

START_TIME = love.timer.getTime!

export getTime
getTime = ->
    return love.timer.getTime! - START_TIME

export ADDRESS, PORT
ADDRESS = 'localhost'
PORT    = '18666'

love.load = (args)->
    isServer = false
    for i,arg in pairs args
        nextArg = args[i+1]
        switch arg
            when '--server'  then isServer = true
            when '--address' then ADDRESS  = ADDRESS or nextArg
            when '--port'    then PORT     = PORT    or nextArg
    
    -- change the role of the program based on this argument
    if isServer
        require 'server'
    else
        require 'client'
    LOAD args
