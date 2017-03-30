-- entry point of the program
-- chose the right configuration
export love
love.load = (args)->
    server = false
    for k,arg in pairs args
        if arg == 'server'
            server = true
            break
    if server
        require 'server'
    else
        require 'client'
    LOAD args
