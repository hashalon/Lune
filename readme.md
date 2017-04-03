# Lune

A basic network project made with LÖVE and MoonScript.

## Compile

run the command
```
moonc -t build src/.
```
in the *root* directory of the project.

## Execute

run the command
```
love build --server
```
to launch the server.

Then run the command
```
love build --name "name of your player"
```
to launch a client.

You can set the server address and port with the arguments `--address` and `--port` like so:
```
love build --server   --address 127.0.0.0 --port 8080
love build --name Bob --address 127.0.0.0 --port 8080
```

## Credits
* [LÖVE](https://love2d.org/)
* [MoonScript](http://moonscript.org/)
* [lua-struct by iryont](https://github.com/iryont/lua-struct)
