# DefAdvSDK
A generic 2d point'n'click adventure engine for Defold

**DefAdvSDK** is a generic 2d point'n'click adventure engine, made with Defold.
Assets (rooms, objects, actors, sounds) and game logics (scripted in a specific game language, and stored in two json files) can be created and handled outside the Defold project (and then build to became resources - collection, game objects and so on) or you can use the Lua engine directly.
Outside creation can be done with Tiled (to create the "rooms") and with a Yaml like script file in which you'll put actions and interactions between game elements, that can be "compiled" using a specific tool called acompiler.

A full documentation is not available at the moment (but feel free to peek at the code and at script files). I'll surely do it, if there will be interest about it.


**DefAdvSDK** is in a preliminary state, use at your own risk (I mean it could still change a lot) 
Engine code and also the graphics used in this demo are by Marco Giorgini (@marcogiorgini).  
Both (code assets and graphic assets) are released as CC BY 3.0 (you can use and modify it without fee, but credits are mandatory)

**DefAdvSDK** use **DefOS** native library

This engine has been created and used for the first time as base for **The Child of the Hill House** (a short paranormal adventure game, created in 14 days for *#advjam2018*)
