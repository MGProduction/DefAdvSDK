local audio = require "adv/lua/audio"
local config = require "adv/lua/config"

function split(s, delimiter)
	result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

function table_find(t,what) -- find element v of l satisfying f(v)
	for _, v in ipairs(t) do
		if v==what then
			return true
		end
	end
	return false
end

local M = {}

M.player=nil
M.bkg=nil

M.jumpto=nil

M.rooom=nil
M.lastroom=""

M.visited={}
M.memory={}

M.gamestring=nil
M.game=nil
M.theroom=nil
M.theobjects=nil
M.theactions=nil
M.theactors=nil

-- Inventory handling

M.inventorymaxsize=4

M.hudinventory={}
M.hudinventorycnt=0
M.myinventory={}	

function M.getfrominventory(self,val)
	local i=1
	while i<=M.hudinventorycnt do
		if M.hudinventory[i].name==val then
			return M.hudinventory[i],i
		end
		i=i+1
	end
	return nil,-1
end

function M.getselectedfromname(self,val)
	if val=="" then
		return M.player
	else
		for i,obj in ipairs(M.actors) do
			if obj.name==val then
				return obj.obj				
			end
		end
	end
	return nil
end

function M.removefrominventory(self,val)
	local i=1
	while i<=M.hudinventorycnt do
		if M.hudinventory[i].name==val then
			local ii=i+1
			while ii<=M.hudinventorycnt do
				local pos=M.hudinventory[i].pos
				M.hudinventory[i]=M.hudinventory[ii]
				M.hudinventory[i].pos=pos
				msg.post("hud", "hud_setinv",{num=i,img=M.hudinventory[i].icon})
				i=i+1
				ii=ii+1
			end
			M.hudinventory[i]=nil
			msg.post("hud", "hud_setinv",{num=i,img=M.inventoryblankicon})
			M.hudinventorycnt=M.hudinventorycnt-1
			break
		end
		i=i+1
	end
end

function M.addtoinventory(self,name)
	local objects=M.game["objects"]
	if objects then
		objects=objects[1]
		local item={}
		local iteminfo=objects[name]
		if iteminfo then
			iteminfo=iteminfo[1]
			item["name"]=iteminfo["name"]
			item["desc"]=iteminfo["desc"]
			if item["name"]==nil then
				item["name"]=item["desc"]
			end
			item["fulldesc"]=iteminfo["fulldesc"]
			item["pos"]=vmath.vector3(12+M.hudinventorycnt*24,screen_h-12,0)
			item["size"]=vmath.vector3(24,24,0)
			item["usewith"]=iteminfo["usewith"]
			item["usefar"]=iteminfo["usefar"]
			item["icon"]=iteminfo["icon"]
			item["inventory"]=1
			item["kind"]=2
			item["value"]=iteminfo["value"]			
			M.hudinventorycnt=M.hudinventorycnt+1
			--if M.hudinventorycnt > 1 then
			msg.post("hud", "hud_setinv",{num=""..M.hudinventorycnt,val=iteminfo["value"],img=item["icon"]})
			--end
			table.insert(M.hudinventory,item)							
		end
	end
end

-- Functions
function M.reach(self,val,dist)
	local dig=split(val,",")								
	if math.abs(heropos.x-dig[1])>dist then
		local pos
		if heropos.x<tonumber(dig[1]) then
			pos = vmath.vector3(dig[1]-dist,heropos.y,0)
		else
			pos = vmath.vector3(dig[1]+dist,heropos.y,0)
		end
		if M.rectarea then
			if pos.x > M.rectarea.x+M.rectarea.w then
				pos.x = M.rectarea.x+M.rectarea.w
			end
			if pos.x < M.rectarea.x then
				pos.x = M.rectarea.x
			end
		end
		msg.post(M.player, "move_to",{destination=pos,follow=true})			
		M.waitfor=1
	end		
end

-- Commands handling

M.commands=nil
M.commandspos=1

M.conditional=nil
M.conditionalpos=0
M.conditionalcheck=0	

M.waittime=0
M.waitfor=-1

function M.setcommand(self,key,value,defvalue)
	M.commands={}
	M.commandspos=1
	M.conditional={}
	M.conditionalpos=0
	M.conditionalcheck=0
	M.waittime=0
	M.waitfor=-1
	cmd={}
	if value then
		cmd[key]=value
	else
		cmd[key]=defvalue
	end
	table.insert(M.commands,cmd)	
end

function M.assigncommand(self,cmds)
	M.commands=cmds
	M.commandspos=1
	M.conditional={}
	M.conditionalpos=0
	M.conditionalcheck=0
	M.waittime=0
	M.waitfor=-1
end

function M.addcommand(self,key,value,defvalue)
	if M.commands==nil then
		M.commands={}
	end	
	cmd={}
	if value then
		cmd[key]=value
	else
		cmd[key]=defvalue
	end
	table.insert(M.commands,cmd)	
end

function M.addcommands(self,cmds)
	if M.commands==nil then
		M.commands={}
	end
	for k, v in pairs(cmds) do
		table.insert(M.commands,v)	
	end	
end

function M.deletecommands(self)
	if M.commands then
		msg.post(M.player,"unlockanim",{kind="all"})
		msg.post("hud", "settextcolor",{color="white"})				
	end	
	M.commands=nil
	M.commandspos=1
	M.conditional={}
	M.conditionalpos=0
	M.conditionalcheck=0
	M.waittime=0
	M.waitfor=-1
end

function M.playaction(self,name)
	local act=M.theactions[name]
	if act then
		M.addcommands(self, act)
	end
end

function M.addcondition(self)
	M.conditionalpos=M.conditionalpos+1
	M.conditionalcheck=M.conditionalpos
	M.conditional=0
end

function M.playcommands(self)		
	local selected=M.player
	while(M.commands~=nil) do		
		local current=M.commands[M.commandspos]
		if current==nil then
			M.deletecommands(self)
			local mask
			if M.player then
				mask=2
			else
				mask=1
			end			
			msg.post("hud", "hud_enable",{enable=mask})
		else
			for cmd,val in pairs(current) do
				if cmd=="else" then
					if M.conditionalcheck==M.conditionalpos then
						if M.conditional then
							if M.conditional==0 then
								M.conditional=1
							elseif M.conditional==1 then
								M.conditional=0
							end
						end
					end
				elseif cmd=="endif" then				
					if M.conditionalcheck==M.conditionalpos then
						M.conditionalpos=M.conditionalpos-1
						M.conditionalcheck=M.conditionalpos
						if M.conditionalpos==0 then
							M.conditional=nil
						end
					else	
						M.conditionalpos=M.conditionalpos-1
						if M.conditionalpos==0 then
							M.conditional=nil
							M.conditionalcheck=M.conditionalpos
						end
					end
				else
					if M.conditionalpos~=M.conditionalcheck or (M.conditional and M.conditional==0) then
						if cmd=="ifset" or cmd=="ifnotset" or cmd=="ifhave" or cmd=="ifdonthave" or cmd=="ifequal" or cmd=="ifmorethan" or cmd=="iflessthan" then
							M.conditionalpos=M.conditionalpos+1
						else
						end
					else	
						if cmd=="ifequal" then
							M.addcondition(self)
							local sep=split(val,",")
							local obj,i=M.getfrominventory(self,sep[1])
							if obj and obj["value"] then
								if tonumber(obj["value"])==tonumber(sep[2]) then
									M.conditional=1
								end								
							end
						elseif cmd=="ifmorethan" then
							M.addcondition(self)
							local sep=split(val,",")
							local obj,i=M.getfrominventory(self,sep[1])
							if obj and obj["value"] then
								if tonumber(obj["value"])>tonumber(sep[2]) then
									M.conditional=1
								end
							end							
						elseif cmd=="iflessthan" then
							M.addcondition(self)
							local sep=split(val,",")
							local obj,i=M.getfrominventory(self,sep[1])
							if obj and obj["value"] then
								if tonumber(obj["value"])<tonumber(sep[2]) then
									M.conditional=1
								end
							end							
						elseif cmd=="ifset" then
							M.addcondition(self)
							if M.memory[val] then
								M.conditional=1
							end					
						elseif cmd=="ifnotset" then
							M.addcondition(self)
							if M.memory[val] == nil then
								M.conditional=1
							end											
						elseif cmd=="ifhave" then
							M.addcondition(self)
							if M.myinventory[val] then
								M.conditional=1
							end					
						elseif cmd=="ifdonthave" then
							M.addcondition(self)
							if M.myinventory[val] == nil then
								M.conditional=1
							end												
						elseif cmd=="set" then
							M.memory[val]=true
						elseif cmd=="unset" then
							M.memory[val]=nil																
						elseif cmd=="showobj" then
							for i,obj in ipairs(M.elements) do
								if obj.name==val then
									msg.post(obj.obj, "show",{visible=true})
									local nm=M.room.."_"..obj.name.."_visible"
									M.memory[nm]=1
									obj.visible=true
									break
								end								
							end
						elseif cmd=="hideobj" then
							for i,obj in ipairs(M.elements) do
								if obj.name==val then
									msg.post(obj.obj, "show",{visible=false})
									local nm=M.room.."_"..obj.name.."_visible"
									M.memory[nm]=0
									obj.visible=false
									break
								end								
							end
						elseif cmd=="incval" then	
							local sep=split(val,",")
							local obj,i=M.getfrominventory(self,sep[1])
							if obj and obj["value"] then
								obj["value"]=tonumber(obj["value"])+tonumber(sep[2])
								msg.post("hud", "hud_setinv",{num=i,val=obj["value"]})
							end
						elseif cmd=="setval" then		
							local sep=split(val,",")
							local obj,i=M.getfrominventory(self,sep[1])
							if obj and obj["value"] then
								obj["value"]=tonumber(sep[2])
								msg.post("hud", "hud_setinv",{num=i,val=obj["value"]})
							end
						elseif cmd=="take" then
							M.myinventory[val]=true
							M.addtoinventory(self,val)
						elseif cmd=="drop" then
							M.myinventory[val]=nil
							M.removefrominventory(self,val)							
						elseif cmd=="setpos" then
							local dig=split(val,",")
							local pos = vmath.vector3(dig[1],screen_h-((dig[2]-herosize.y/2)),0)
							msg.post(M.player, "set_to",{destination=pos,follow=true})			
						elseif cmd=="reach" then
							M.reach(self,val,32)
						elseif cmd=="moveto" then
							local dig=split(val,",")
							local pos = vmath.vector3(dig[1],screen_h-((dig[2]-herosize.y/2)),0)
							msg.post(M.player, "move_to",{destination=pos,follow=true})			
							M.waitfor=1 -- heroendmovement										
						elseif cmd=="loadroom" then									
							M.jumpto=val							
							M.unloadRoom(self)
							break
						elseif cmd=="setblock" then		
							for i,obj in ipairs(M.actors) do
								if obj.name==val then
									selected=obj.obj									
									break
								end
							end
						elseif cmd=="unsetblock" then		
							msg.post(M.player,"delblockingarea",{name=val})
							for j,actor in ipairs(M.tplayers) do	
								if actor.name==val then
									actor["blocking"]=nil
									break
								end
							end
						elseif cmd=="stop" then		
							for i,obj in ipairs(M.actors) do
								if obj.name==val then
									msg.post(obj.obj,"stop",{name=obj.name})
									break
								end
							end	
						elseif cmd=="select" then		
							selected=M.getselectedfromname(self,val)							
						elseif cmd=="setstartingpos" then
							local v=split(val,",")
							if v[3] then
								selected=M.getselectedfromname(self,v[1])							
								val=v[2]..","..v[3]
							end							
							if selected==M.player then
							else
								for j,actor in ipairs(M.tplayers) do	
									if actor.obj==selected then
										local dig=split(val,",")
										local pos = vmath.vector3(dig[1],screen_h-((dig[2]-actor.size.y/2)),0)
										actor["pos"]=pos
										selected=M.player
										break
									end
								end
							end
						elseif cmd=="setroom" then	
							if string.find(val, ",") then
								local v=split(val,",")
								selected=M.getselectedfromname(self,v[1])							
								val=v[2]
							end							
							if selected==M.player then
							else
								for j,actor in ipairs(M.tplayers) do	
									if actor.obj==selected then
										actor["room"]=val
										selected=M.player
										break
									end
								end
							end
						elseif cmd=="playsound" then	
							audio.playsound(self,"/audio#"..val)
						elseif cmd=="playmusic" then	
							if val=="" or val==nil or val=="_" then
								val=nil
								if M.music~=val then
									M.music=nil
									audio.stopmusic(self)
								end
							else
								if M.music~=val then
									M.music=val
									audio.playmusic(self,"/audio#"..M.music)
								end
							end
						elseif cmd=="setanim" then	
							if val=="" or val==nil or val=="_" then
								msg.post(selected,"unlockanim")
							else
								if string.find(val, ",") then
									local v=split(val,",")
									selected=M.getselectedfromname(self,v[1])							
									val=v[2]
								end
								msg.post(selected,"unlockanim",{kind="all"})
								msg.post(selected,"lockanim",{anim=val})
								if selected==M.player then
								else
									for j,actor in ipairs(M.tplayers) do	
										if actor.obj==selected then
											actor["anim"]=val
											selected=M.player
											break
										end
									end
									selected=M.player
								end								
							end
						elseif cmd=="wait" then	
							M.waitfor=0
							M.waittime=tonumber(val)/1000
						elseif cmd=="saycolor" then	
							msg.post("hud", "settextcolor",{color=val})					
						elseif cmd=="say" then
							msg.post(M.player,"lockanim",{anim="idle.front"})
							msg.post("hud", "action.examine",{desc=val})					
							M.waitfor=0
							M.waittime=math.max(32,string.len(val))*0.045
						elseif cmd=="declare" then
							msg.post(M.player,"lockanim",{anim="idle.front"})
							msg.post("hud", "action.examine",{desc=val})
							M.waitfor=0
							M.waittime=string.len(val)*0.5				
						elseif cmd=="call" then
							local act=M.theactions[val]
							if act then
								if M.commands[M.commandspos+1] then
									local more={}
									local j=M.commandspos
									local i=j+1
									while M.commands[i] do										
										table.insert(more,M.commands[i])	
										table.remove(M.commands,i)										
									end									
									M.commands={}
									M.commandspos=0
									M.addcommands(self, act)
									M.addcommands(self, more)
								else
									M.commands={}
									M.commandspos=0
									M.addcommands(self, act)
								end
							end
						else
							print("unrecognized cmd: "..cmd.." "..val)
						end
					end
				end
			end
			M.commandspos=M.commandspos+1
			if M.waitfor >= 0 then
				break
			end
		end
	end
end

function M.getcmd(self,obj,action,kind)
	if M.theroom then
		local theobj=M.theroom[obj]
		if theobj then
			theobj=theobj[1]
			local theact=theobj[action]
			if theact then
				return theact
			end
		end
		if kind then
			if kind==1 then
				local actor=M.theactors[obj]
				if actor then
					actor=actor[1]
					local theact=actor[action]
					return theact
				end
			elseif kind==2 then
				local object=M.theobjects[obj]
				if object then
					object=object[1]
					local theact=object[action]
					return theact
				end				
			end
		end
	end
	return nil
end

-- Commands handling

function M.unloadGame(self)
	audio.stopmusic(self)
	defos.set_cursor_visible(true)
end

function M.loadGame(self,name)	

	local systemname=sys.get_sys_info().system_name 

	M.player=nil
	M.bkg=nil
	M.jumpto=nil
	M.rooom=nil
	M.lastroom=""
	M.waittime=0
	M.waitfor=-1

	M.commands=nil
	M.commandspos=1
	M.conditional=nil
	M.conditionalpos=0
	M.conditionalcheck=0	
	
	M.hudinventory={}
	M.hudinventorycnt=0
	M.myinventory={}	

	M.memory={}
	M.visited={}	

	M.gamestring = sys.load_resource("/adv/"..name..".json")
	M.game = json.decode(M.gamestring)	

	M.locstring = sys.load_resource("/adv/loc.json")
	M.loc = json.decode(M.locstring)	

	local config

	if sys.get_engine_info().is_debug then
		config=M.game["debugconfig"]
	else
		config=M.game["config"]		
	end
	
	config=config[1]

	local general=M.game["general"]
	if general then
		local title
		general=general[1]
		title=general["gamename"]
		if title then
			defos.set_window_title(title)
		end
		M.inventorymaxsize=general["inventorysize"] or 4
		M.inventoryblankicon=general["inventoryblankicon"]
		local config_wantedY=general["height"]
		if config_wantedY then
			msg.post("@render:", "update_wantedY",{wanted_Y=config_wantedY})
		end
	else
		M.inventorymaxsize=4
	end

	local firstroom=config["starting"]

	M.playername=config["playas"]
	if M.playername==nil then
		M.playername="me"
	end

	M.tplayers={}
	M.tplayer={}

	M.theobjects=M.game["objects"]
	if M.theobjects then
		M.theobjects=M.theobjects[1]
	end
	M.theactors=M.game["actors"]
	if M.theactors then
		M.theactors=M.theactors[1]
	end
	M.theactions=M.game["actions"]
	if M.theactions then
		M.theactions=M.theactions[1]
		M.theactions=M.theactions["base"]
		if M.theactions then
			M.theactions=M.theactions[1]		
		end
	end
	for kk, vv in pairs(M.theactors) do
		local name=kk
		local actor=M.theactors[name]
		if actor then
			actor=actor[1]
			if name==M.playername then
				M.tplayer["name"]=actor["name"]
				M.tplayer["desc"]=actor["desc"]
				if M.tplayer["name"]==nil then
					M.tplayer["name"]=M.tplayer["desc"]
				end
				M.tplayer["fulldesc"]=actor["fulldesc"]
				M.tplayer["pos"]=vmath.vector3(12,screen_h-12,0)
				M.tplayer["size"]=vmath.vector3(24,24,0)		
				M.tplayer["human"]=2
				M.tplayer["kind"]=1
			else
				other={}
				other["name"]=actor["name"]
				other["desc"]=actor["desc"]
				if other["name"]==nil then
					other["name"]=other["desc"]
				end
				other["fulldesc"]=actor["fulldesc"]
				local val=actor["startingpos"]
				local val2=actor["size"]
				local w=64
				local h=100
				if val2 then
					local dig=split(val2,",")			
					w=dig[1]
					h=dig[2]
				end
				other["size"]=vmath.vector3(w,h,0)
				if val then
					local dig=split(val,",")			
					other["pos"]=vmath.vector3(dig[1],screen_h-((dig[2]-h/2)),0)							
				else
					other["pos"]=vmath.vector3(screen_w/2,screen_h/2,0)
				end
				other["human"]=3
				other["blocking"]=actor["blocking"]
				other["room"]=actor["startingfrom"]
				other["anim"]=actor["startinganim"]
				other["kind"]=1
				table.insert(M.tplayers, other)	
			end
		end
	end

	msg.post("hud", "hud_create",{dad=msg.url(".")})

	local baseinv=config["baseinventory"]
	if baseinv then
		local items=split(baseinv,",")	
		for i, v in ipairs(items) do	
			M.myinventory[v]=true	
			M.addtoinventory(self,v)		
		end
	end

	local baseset=config["baseset"]
	if baseset then
		local items=split(baseset,",")	
		for i, v in ipairs(items) do		
			M.memory[v]=true
		end
	end

	defos.set_cursor_visible(false)

	return firstroom
end

function M.deleteRoom(self)
	for i,obj in ipairs(M.elements) do
		go.delete(obj.obj)
	end
	for i,obj in ipairs(M.actors) do
		go.delete(obj.obj)
	end		
	if M.player then
		go.delete(M.player)			
	end
	if M.bkg then
		go.delete(M.bkg)
	end
end		

function M.unloadRoom(self)
	heropos=nil
	herosize=nil
	M.selected=nil
	M.selectedwith=nil
	M.twoobjects=nil							
	M.deletecommands(self)
	msg.post("hud", "hud_enable",{enable=0})
	msg.post("hud","cursor_set",{status=-1,desc=""})		
	msg.post("hud","setactionprefix",{prefix=nil})
	fader_request=msg.url(".")
	fader_request_msg="readytoload"
	msg.post("hud","fadeout")	
end

function M.loadRoomActors(self,objects,atlas)
	for j,jobj in pairs(objects) do	
		jobj=jobj["obj"]
		local w=jobj["width"] or 0
		local h=jobj["height"] or 0
		local x=jobj["x"] or 0
		local y=jobj["y"] or 0
		local pos = vmath.vector3(x+w/2,screen_h-((y-h/2)),0)
		if jobj["name"]=="player" then
			M.player=factory.create("#actorsfactory",pos,nil,{player=1})					
			msg.post(M.player, "set_to",{destination=pos,follow=true})			
		end
	end
end

function M.loadRoomWalkarea(self,objects,atlas)
	for j,jobj in pairs(objects) do	
		jobj=jobj["obj"]
		local w=jobj["width"] or 0
		local h=jobj["height"] or 0
		local x=jobj["x"] or 0
		local y=jobj["y"] or 0
		if jobj["polyline"] then
			local p1={}
			p1.points={}		
			local cnt=0
			for k,kobj in ipairs(jobj["polyline"]) do	
				p1.points[cnt+1]=vmath.vector3(kobj.x+x,kobj.y+y,0)
				cnt=cnt+1
			end
			if M.poly==nil then
				M.poly={}
			end
			table.insert(M.poly,p1)
		else
			area={}
			area.x=tonumber(x)
			area.y=tonumber(y)
			area.w=tonumber(w)
			area.h=tonumber(h)
			M.rectarea=area
		end
	end
end

function M.loadRoomObjects(self,objects,atlas)
	for j,jobj in pairs(objects) do	
		jobj=jobj["obj"]		
		local w=jobj["width"] or 0
		local h=jobj["height"] or 0
		local x=jobj["x"] or 0
		local y=jobj["y"] or 0
		local overlay=jobj["overlay"]
		local status=jobj["status"]
		local opos=nil
		local osz=nil
		tobj={}
		tobj.name=jobj["name"]
		
		if overlay==nil then
			overlay="void"
		else					
			local overlaypos=jobj["overlaypos"]
			if overlaypos then
				local dig=split(overlaypos, ",")
				opos=vmath.vector3(dig[1],dig[2],0.1)
				osz=vmath.vector3(dig[3],dig[4],0.1)
			end
			tobj.overlay=overlay
			if status then
				overlay=overlay.."_"..status
			end
		end			

		tobj.desc=jobj["desc"]
		if tobj.desc==nil then
			tobj.desc=string.gsub(tobj.name,"_+", " ")
		end
		tobj.fulldesc=jobj["fulldesc"]
			
		local visible=jobj["show"]								
		local nm=M.room.."_"..tobj.name.."_visible"		
		local lvisible=M.memory[nm]
		if lvisible then			
			visible=lvisible
		end
		
		if jobj["pickable"] then
			tobj.pickable=jobj["pickable"]					
		end
		if jobj["moveto"] then
			tobj.moveto=jobj["moveto"]
		else
			tobj.movetocode=M.getcmd(self,tobj.name,"moveto")
		end
		if status then
			local lstatus=M.memory[M.room.."_"..tobj.name.."_status"]
			tobj.status=status	
			if lstatus then
				tobj.status=lstatus
				overlay=tobj.overlay.."_"..tobj.status
			end				
		end					
		if tobj.pickable then
			if table_find(inventory,tobj.desc) == true then
				tobj.disabled=true
				overlay=overlay.."_taken"
			end					
		end
		tobj.walkable=jobj["walkable"]
		if tobj.walkable==nil then
			tobj.walkable=true
		end
		if visible==nil or visible==true or visible==1 then
			tobj.visible=true
		else
			tobj.visible=false
		end
		local zvalue
		if jobj["z"] then
			zvalue=0
		else
			zvalue=nil
		end
		if jobj["polyline"] then
			local pos = vmath.vector3(x,y,0.1)										
			if opos==nil then
				opos=pos
			else
				opos.x=opos.x+osz.x/2
				opos.y=screen_h-(opos.y+osz.y/2)
			end					
			tobj.obj=factory.create("#items"..atlas.."factory",pos,nil,{position=opos,anim=hash(overlay),size=osz,visible=tobj.visible})					
			tobj.pos=pos
			tobj.points=jobj["polyline"]
			table.insert(M.elements, tobj)
		else
			local sz = vmath.vector3(w,h,0.1)
			local pos = vmath.vector3(x+w/2,screen_h-(y+h/2),0.1)					
			if osz==nil then
				osz=sz
			end
			if opos==nil then
				opos=pos						
			else
				opos.x=opos.x+osz.x/2
				opos.y=screen_h-(opos.y+osz.y)+osz.y/2
			end					
			tobj.obj=factory.create("#items"..atlas.."factory",pos,nil,{position=opos,anim=hash(overlay),size=osz,visible=tobj.visible})					
			tobj.pos=pos
			tobj.size=sz
			if overlay=="void" then
			else
				msg.post(tobj.obj, "changeanim",{anim=overlay,z=zvalue})
			end
			table.insert(M.elements, tobj)
			if tobj.walkable==false then
				msg(M.player,"addblockingarea",{pos=tobj.pos,size=tobj.size})
			end										
		end
	end	
end

function M.loadRoom(self,name)

	-- print("room::"..name)	

	M.camerapos=vmath.vector3()
	M.lastaction=vmath.vector3()

	M.lastroom=M.room
	M.room=name
	
	M.waittime=0
	M.waitfor=-1
	M.commands=nil
	M.commandspos=1	    
	M.conditionals={}
	M.conditionalspos=0
	
	M.selected=nil
	M.selectedwith=nil
	M.twoobjects=nil
	M.action=""
	M.elements={}
	M.actors={}
	M.poly=nil
	M.rectarea=nil
	M.player=nil

	M.data=M.loc[name]

	M.theroom=M.game[M.room]
	if M.theroom then
		M.theroom=M.theroom[1]
	end
	
	local atlas
	local bkg=M.data["bkg"]
	if bkg then
		local img
		atlas=bkg["atlas"]
		img=bkg["name"]
		M.bkg=factory.create("#back"..atlas.."factory",nil,nil,{anim=hash(img)})			
	end
	local objects=M.data["objects"]
	if objects then
		M.loadRoomObjects(self,objects,atlas)
	end
	local actors=M.data["actors"]
	if actors then
		M.loadRoomActors(self,actors,atlas)
	end	
	local movearea=M.data["movearea"]
	if movearea then
		M.loadRoomWalkarea(self,movearea,atlas)
	end		
	
	for j,actor in ipairs(M.tplayers) do	
		if actor["room"]==M.room then
			local pos=actor["pos"]--vmath.vector3(screen_w/2,screen_h/2,0)
			local size=actor["size"]
			local a=factory.create("#actorsfactory",pos,nil,{player=0})
			local name=actor["name"]			
			msg.post(a,"set_name",{name=name})
			msg.post(a, "set_to",{destination=pos,follow=false})			
			local lanim=actor["anim"]
			if lanim then
				msg.post(a, "lockanim",{anim=lanim})			
			end
			actor["obj"]=a			
			if actor["blocking"] then
				local lpos=vmath.vector3(pos.x-size.x,pos.y-size.y/2,0)
				local lsize=size
				local lname=name
				msg.post(M.player,"addblockingarea",{pos=lpos,size=lsize,name=lname})
				actor["block"]=true
			end
			table.insert(M.actors, actor)
		end
	end

	local first
	if M.reloadpos and M.player then
		msg.post(M.player, "set_to",{destination=M.reloadpos,follow=true})			
		M.reloadpos=nil
		M.setcommand(self,"say","Game loaded")		
	else
		if M.visited[M.room]==nil then
			first=M.getcmd(self,"_","onfirst")
			M.visited[M.room]=1
		else
			M.visited[M.room]=M.visited[M.room]+1
		end
		if first then
			M.commands=first
		else
			local enterfrom=M.getcmd(self,"_from",M.lastroom)
			if enterfrom==nil then
				if heropos==nil or heropos.x>256 then
					if M.rectarea then
						M.setcommand(self,"setpos",(-herosize.x/2-8)..","..M.rectarea.y)
						M.addcommand(self,"moveto",(herosize.x)..","..M.rectarea.y)
					else
						enterfrom=M.game["left-right"]
					end
				end
			end
			if enterfrom then
				M.commands=enterfrom
			end
		end
		if M.commands then
			while(M.commands~=nil) do																				
				local current=M.commands[M.commandspos]
				if current==nil then
					break
				elseif current["setpos"] then	
					local val=current["setpos"]
					local dig=split(val,",")
					pos = vmath.vector3(dig[1],screen_h-((dig[2]-herosize.y/2)),0)							
					if M.player then
						msg.post(M.player, "set_to",{destination=pos,follow=true})			
					end
					M.commandspos=M.commandspos+1
				elseif current["setanim"] then		
					local val=current["setanim"]
					if M.player then
						msg.post(M.player,"lockanim",{anim=val})
					end
					M.commandspos=M.commandspos+1
				else
					if current["loadromm"] then		
						M.redirect=current["loadromm"]
					end
					break
				end
			end
		end	
	end

	if M.player==nil then
		msg.post("camera", "center")
	end

	fader_request=msg.url(".")
	fader_request_msg="endfadein"
	msg.post("hud","fadein")
end

function M.pointinObject(self,obj,pnt)
	if obj.points then
		local x=pnt.x
		local y=screen_h-pnt.y
		local y = y and y or x.y
		local x = y and x or x.x

		local polySides = #obj.points - 1
		local j = polySides
		local res = false
		local bx=obj.pos.x
		local by=obj.pos.y

		for i = 1, polySides do
			local p1 = obj.points[i]
			local p2 = obj.points[j]
			local x1,y1 = p1.x+bx,p1.y+by
			local x2,y2 = p2.x+bx,p2.y+by
			if (y1 < y and y2 >= y or y2 < y and y1 >= y) and
			(x1 <= x or x2 <= x) then
				if x1 + (y-y1)/(y2-y1)*(x2-x1)< x then
					res = not res
				end
			end
			j=i
		end
		return res
	elseif obj.pos then
		if pnt.x >= obj.pos.x-obj.size.x/2 and pnt.x <= obj.pos.x+obj.size.x/2 and (pnt.y) >= obj.pos.y-obj.size.y/2 and (pnt.y) <= obj.pos.y+obj.size.y/2 then
			return true
		end
	else
		local l
		l=0
	end
	return false
end

function M.handle_cursormovements(self,action)
	local screen_width = tonumber(sys.get_config("display.width"))
	local screen_height = tonumber(sys.get_config("display.height"))
	local dest=vmath.vector3()
	local ratio_y=screen_h/screen_height
	local ratio_x=screen_w/screen_width		
	local activity=0
	local selected=nil
	local mydesc=nil
	dest.x=action.x*ratio_x
	dest.y=action.y*ratio_y
	for i,obj in ipairs(M.hudinventory) do
		if obj.disabled==nil and M.pointinObject(self,obj,dest) then 
			activity=2
			selected=obj
			break
		end
	end
	if activity==0 then
		dest.x=action.x*ratio_x+camerapos.x		
		for i,obj in ipairs(M.elements) do
			if obj.disabled==nil and obj.visible==true and M.pointinObject(self,obj,dest) then 
				activity=1
				selected=obj
				break
			end
		end
	end
	if activity==0 then
		dest.x=action.x*ratio_x+camerapos.x		
		for i,obj in ipairs(M.actors) do
			if obj.disabled==nil and M.pointinObject(self,obj,dest) then 
				activity=1
				selected=obj
				break
			end
		end
	end
	if activity==0 and heropos then
		M.tplayer.pos.x=heropos.x
		M.tplayer.pos.y=heropos.y+herosize.y/4
		M.tplayer.size.x=herosize.x/2
		M.tplayer.size.y=herosize.y/2
		if M.pointinObject(self,M.tplayer,dest) then 
			activity=2
			selected=M.tplayer
		end
	end
	if M.twoobjects then			
		if selected==M.selectedwith then
		else		
			if selected and selected.inventory==1 then	
				mydesc=""
			else
				M.selectedwith=selected
				if M.selectedwith then
					mydesc=M.selectedwith.desc
				else
					mydesc=""
				end			
			end
		end						
	else
		if selected==M.selected then
		else			
			M.selected=selected
			if M.selected then
				mydesc=M.selected.desc
			else
				mydesc=""
			end			
		end
	end
	local pos=vmath.vector3(action.x*ratio_x,action.y*ratio_y,0.99)
	if M.twoobjects then
		msg.post("hud","cursor_setobj",{position=pos,status=activity,desc=mydesc})		
	else
		msg.post("hud","cursor_set",{position=pos,status=activity,desc=mydesc})		
	end
	msg.post(M.player, "look_at",{lookat=dest})	

	M.lastaction=action
end

function M.handle_onkeyevents(self,action_id,action)
	 if action_id==hash("togglefullscreen") then
		if action.released then
			defos.toggle_fullscreen()
			if M.commands==nil then
				if defos.is_fullscreen() then
					M.setcommand(self,"say","Good, now the world looks better")
					M.playcommands(self)
				else
					M.setcommand(self,"say","Uh, now the world looks smaller")
					M.playcommands(self)
				end				
			end
		end
	elseif action_id==hash("exitfullscreen") then
		if action.released then
			if defos.is_fullscreen() then
				defos.toggle_fullscreen()
			end
		end
	elseif action_id==hash("loadgame") then	
		if action.released then
			M.load(self,"slot")
		end
	elseif action_id==hash("savegame") then	
		if action.released then
			M.save(self,"slot")
			if M.commands==nil then
				M.setcommand(self,"say","Game saved")
				M.playcommands(self)
			end		
		end
	elseif action_id==hash("togglemusic") then
		if action.released then
			if config.music==1 then				
				audio.stopmusic(self)
				config.music=0
				config.sound=0
				if self.music then
					if commands==nil then
						M.setcommand(self,"say","Uh, now the world sounds silent")
						M.playcommands(self)
					end
				end
			else
				config.music=1
				config.sound=1			
				if self.music then
					audio.playmusic(self,"/audio#"..self.music)
					if M.commands==nil then
						M.setcommand(self,"say","Good, now the world sounds better")
						M.playcommands(self)					
					end
				end
			end
		end
	end
end	

function M.handle_action(self,actionname,defaulttext,gonear)
	local action=M.getcmd(self,M.selected.name,actionname,M.selected.kind)
	if action then	
		if gonear then
			if M.selected.kind~=2 then
				M.setcommand(self,"reach",M.selected.pos.x..","..M.selected.pos.y)
			end
		end
		M.addcommands(self,action)
		M.playcommands(self)
	else
		if actionname=="lookat" then
			M.setcommand(self,"declare",M.selected.fulldesc,defaulttext)
		else
			M.setcommand(self,"declare",defaulttext)
		end
		M.playcommands(self)
	end
end

function M.walkto(self,dest)
	M.selectd=nil
	M.action=""
	msg.post("hud","setactionprefix",{prefix=nil})

	local h=herosize.y
	local result, points,forceddest

	if heropos then
		dest.y=dest.y+herosize.y*2/4
		if dest.y<0 then
			dest.y=0
		end
		local tdest=vmath.vector3(dest.x,dest.y,0)
		local startpos=vmath.vector3(heropos.x,screen_h-(heropos.y-herosize.y/2),0)
		local endpos=vmath.vector3(dest.x,screen_h-(dest.y-herosize.y/2),0)

		if M.poly then
			-- still in development
		elseif M.rectarea then
			dest.y=heropos.y							
			if dest.x > M.rectarea.x+M.rectarea.w then
				dest.x = M.rectarea.x+M.rectarea.w
			end
			if dest.x < M.rectarea.x then
				dest.x = M.rectarea.x
			end
		end					
	end							
	msg.post(M.player, "move_to",{destination=dest,sdestination=sdest,follow=true})			
end

function M.handle_onclick(self,action)
	local sdest=nil
	local dest=vmath.vector3()
	local screen_height=tonumber(sys.get_config("display.height"))
	local screen_width=tonumber(sys.get_config("display.width"))
	local ratio_y=screen_h/screen_height
	local ratio_x=screen_w/screen_width
	local icon=nil
	dest.x=action.x*ratio_x		
	dest.y=action.y*ratio_y

	if M.commands then
		if action.pressed == true then
			if M.waitfor==0 then
				M.waittime=0
			end
		end
	else
					
		if dest.x > screen_w/2 and dest.y > screen_h-64 then
			msg.post("hud", "on_input",{action_id=action_id,action=action})		
			icon = 1
		end		

		if icon then
			
		elseif action.pressed == true then			
			local h
			if M.player then
				h=vmath.vector3(heropos.x, heropos.y-herosize.y/2,0)
			else
				h=0
			end
			if M.selected and (M.selected.inventory==1 or M.selected.human==2) and M.action=="" then
				M.action="look at"
			end
			if M.selected and M.action~="" then
				local keepit=0
				if M.action=="look at" then
					M.handle_action(self,"lookat","It looks like it should",true)
				elseif M.action=="talk to" then
					M.handle_action(self,"talkto","I'm not insane")
				elseif M.action=="use" then
					if M.selected.usewith then
						if M.selectedwith == nil then
							msg.post("hud","setactionprepprefix",{prefix="with"})
							keepit=1
							M.twoobjects=1
						else
							local action=M.getcmd(self,M.selectedwith.name,"usewith_"..M.selected.name,M.selectedwith.kind)			
							if action == nil and M.selected.kind then
								action=M.getcmd(self,M.selected.name,"usewith_all",M.selected.kind)			
							end
							if action then			
								if M.selected["usefar"] == nil then
									M.setcommand(self,"reach",M.selectedwith.pos.x..","..M.selectedwith.pos.y)
								end
								M.addcommands(self,action)
								M.playcommands(self)
							else
								M.setcommand(self,"declare","I can't do that")
								M.playcommands(self)
							end
						end
					else
						M.handle_action(self,"use","I can't do that",true)
					end					
				end
				if keepit==1 then
				else
					M.selected=nil
					M.selectedwith=nil
					M.twoobjects=nil
					M.action=""
					msg.post("hud","setactionprefix",{prefix=nil})
				end
			elseif M.selected and M.action=="" and (M.player==nil or M.pointinObject(self,M.selected,h)) and (M.selected.moveto or M.selected.movetocode) then
				if M.selected.moveto then
					M.jumpto=M.selected.moveto
					M.unloadRoom(self)
				else
					M.addcommands(self,M.selected.movetocode)
					M.playcommands(self)
				end
			else
				if M.player then
					dest.x=action.x*ratio_x+camerapos.x						
					M.walkto(self,dest)
				end
			end
		end
	end
end

function M.update(self,dt)
	if M.commands then
		if M.waitfor == 1 then
			if heroendmovement==true then
				M.playcommands(self)
			end
		elseif M.waitfor == 0 then
			if M.waittime>0 then
				M.waittime=M.waittime-dt
			end
			if M.waittime<=0 then
				M.waittime=0
				M.waitfor=-1
				msg.post(M.player,"unlockanim")
				msg.post("hud", "action.examine",{desc=""})
				M.playcommands(self)				
			end			
		end
	else
		if camerapos then
			if camerapos.x == M.camerapos.x then
			else
				M.camerapos.x=camerapos.x
				M.handle_cursormovements(self,M.lastaction)
			end
		end
	end
	
	if defos then
		if defos.is_mouse_in_view() then
			if defos.is_cursor_visible() then
				defos.set_cursor_visible(false)
			end
		else
			if defos.is_cursor_visible()==false then
				defos.set_cursor_visible(true)
			end
		end
	end
end	

function M.load(self,name)
	local appname=sys.get_config("project.title")
	local my_file_path = sys.get_save_file(appname, "adv_"..name..".json")
	if my_file_path then
		local myfile = sys.load(my_file_path)
		if myfile then
			local room=myfile["room"]
			M.visited=myfile["visited"]
			M.memory=myfile["memory"]
			M.tplayers=myfile["tplayers"]
			M.myinventory=myfile["inventory"]
			M.hudinventory=myfile["hudinventory"]
			M.hudinventorycnt=myfile["hudinventorycnt"]			
			for i = 1, M.inventorymaxsize do
				if i<=M.hudinventorycnt then
					local item=M.hudinventory[i]
					msg.post("hud", "hud_setinv",{num=i,val=item["value"],img=item["icon"]})
				else
					msg.post("hud", "hud_setinv",{num=i,val=0,img="icon5"})
				end
			end
			M.reloadpos=myfile["playerpos"]
			M.lastroom=""
			M.jumpto=room
			M.unloadRoom(self)
		end
	end
end

function M.save(self,name)
	local appname=sys.get_config("project.title")
	local my_file_path = sys.get_save_file(appname, "adv_"..name..".json")
	local myfile = {}
	myfile["room"]=M.room
	myfile["visited"]=M.visited
	myfile["memory"]=M.memory
	myfile["inventory"]=M.myinventory
	myfile["hudinventory"]=M.hudinventory
	myfile["hudinventorycnt"]=M.hudinventorycnt
	myfile["tplayers"]=M.tplayers
	myfile["playerpos"]=heropos
	sys.save(my_file_path, myfile)
end

return M