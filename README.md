# DefAdvSDK
A generic 2d point'n'click adventure engine for **Defold** (http://defold.com/)

**DefAdvSDK** is a generic 2d point'n'click adventure engine, made for/with **Defold**.
Assets (rooms, objects, actors, sounds) and game logics (scripted in a specific game language, and stored in two json files) can be created and handled outside the Defold project (and then build to became resources - collection, game objects and so on) or you can use the Lua engine directly.

Outside creation can be done with Tiled (to create the "rooms") and with a Yaml like script file in which you'll put actions and interactions between game elements, that can be "compiled" using a specific tool called acompiler.

A full documentation is not available at the moment (but feel free to peek at the code and at script files). I'll surely do it, if there will be interest about it.


**DefAdvSDK** is in a preliminary state, use at your own risk (I mean it could still change a lot) 
Engine code and also the graphics used in this demo are by Marco Giorgini (@marcogiorgini).  
Code asset (this engine) is releases with MIT Licence.
Graphic assets are instead released as CC BY 3.0 (you can use and modify it without fee, but credits are mandatory)

**DefAdvSDK** use **DefOS** native library

This engine has been created and used for the first time as base for **The Child of the Hill House** (a short paranormal adventure game, created in 14 days for *#advjam2018* - https://gamejolt.com/games/thechildofthehillhouse/337760)

## Quick Start
Simply clone the DefAdvSDK Defold project and start to modify its assets in adv folder (compiled ones, so game script code is in main.json/loc.json files) or in advsrc folder (source files, so you need to edit/recreate main.txt and the tmx files inside loc subfolder)

### Main concepts
In DefAdvSDK you have three main elements: **actors** (one is the player the user can deal with, and it can be the only one present in the game), **objects** (that can be put in the inventory, and used to "use with" commands) and **locations/rooms** (that can contains other objects, to deal with)

If you don't want to write directly the loc.json file, locations can be created using Tiled (https://www.mapeditor.org/).
Inside the tiled file the compiler (**acompiler**) will inspect and extract elements from "bkg" layer, "objects" layer, "actors" layer and "movearea" layer (ignoring all the rest, that you can use to help you creating the scene)

## Script set of instructions

### Audio
playsound	

playmusic	

### Dialog system
saycolor	

say

declare

### Movement (in room)
setpos

reach

moveto

### Movement (to room)
loadroom		

### Animation
setanim	

### Timing
wait	

### Memory and Inventory
set

unset

take

drop

### Conditional expressions
ifset

ifnotset

ifhave

ifdonthave

### Others
showobj

hideobj

setblock		

unsetblock		

stop			

select		

setstartingpos

setroom	

goto
