fader_request=""
fader_request_msg=""

local function on_animation_done(self, url, property)
	if fader_request == "" then
		fader_request=""	 
	else
		if fader_request_msg=="" then
			fader_request_msg="end"
		end
		msg.post(fader_request, fader_request_msg)
		fader_request=""	 
	end
end

function handle_touch(self,x,y,bpressed,breleased,dad)
	for i,obj in ipairs(self.abtns) do
		if obj.cmd == nil then
		else
			if(gui.pick_node(obj.btn,x,y)) then
				if breleased then			
					local pos=string.find(obj.cmd,"+")					
					if pos then
						local poscode=string.find(obj.cmd,"::")
						local scmd=string.sub(obj.cmd, 1,pos-1)
						local swhat
						local scode=nil
						if poscode == nil then
							swhat=string.sub(obj.cmd, pos+1)
						else
							swhat=string.sub(obj.cmd, pos+1, poscode-1)
							scode=string.sub(obj.cmd, poscode+2)
						end
						local wcmd="btn_cmd_"..scmd
						msg.post(obj.dad, wcmd, {what=swhat,code=scode})
					else
						local poscode=string.find(obj.cmd,"::")
						local wcmd
						local scode=nil
						if poscode == nil then
							wcmd="btn_cmd_"..obj.cmd
						else
							wcmd="btn_cmd_"..string.sub(obj.cmd, 1,poscode-1)
							scode=string.sub(obj.cmd, poscode+2)
						end							
						msg.post(obj.dad, wcmd, {code=scode})
					end
					obj.reqpressed=false
				else
					obj.reqpressed=true
				end
			end
		end
	end
end

function gui_init(self)
	self.abtns={}
	self.bbtns={}
	self.sbtns={}
	self.black_box = nil
	self.jsonstring = nil
	self.data = nil
end

function gui_update(self, dt)
	for i,obj in ipairs(self.abtns) do
		if obj.pressed == obj.reqpressed then
		else	
			obj.pressed=obj.reqpressed
			if obj.pressed then 
				gui.animate(obj.btn, gui.PROP_SCALE, vmath.vector3(obj.scale*0.9, obj.scale*0.9, obj.scale*0.9), gui.EASING_LINEAR, 0.25, 0.0)
			else
				gui.animate(obj.btn, gui.PROP_SCALE, vmath.vector3(obj.scale, obj.scale, obj.scale), gui.EASING_LINEAR, 0.25, 0.0)
			end
		end
		obj.reqpressed=false
	end
end

function abtn_delete(self,item)
	gui.delete_node(item)
end

function gui_blackbox(self)
	if self.black_box == nil then
		local w=screen_w
		local h=screen_h
		local new_position = vmath.vector3(w/2, h/2, 0)
		local new_size = vmath.vector3(w, h, 0)			
		self.black_box = gui.new_box_node(new_position, new_size)		
		gui.set_color(self.black_box, vmath.vector4(0, 0, 0, 0))			
	else
		local w=screen_w
		local h=screen_h
		local new_position = vmath.vector3(w/2, h/2, 0)
		local new_size = vmath.vector3(w, h, 0)			
		gui.set_position(self.black_box , new_position)
		gui.set_size(self.black_box , new_size)
	end
end

function gui_fadeout(self)
	gui_blackbox(self)
	gui.set_color(self.black_box, vmath.vector4(0, 0, 0, 0))	
	gui.animate(self.black_box, gui.PROP_COLOR, vmath.vector4(0, 0, 0, 1), gui.EASING_INOUTQUAD, 0.5, 0.0, on_animation_done)
	for i,obj in ipairs(self.abtns) do
		local color=gui.get_color(obj.btn)
		gui.animate(obj.btn, gui.PROP_COLOR, vmath.vector4(color.x, color.y, color.z, 0), gui.EASING_INOUTQUAD, 0.5, 0.0, on_animation_done)
	end		
	for i,obj in ipairs(self.bbtns) do
		local color=gui.get_color(obj)
		gui.animate(obj, gui.PROP_COLOR, vmath.vector4(color.x, color.y, color.z, 0), gui.EASING_INOUTQUAD, 0.5, 0.0, on_animation_done)
	end		
	for i,obj in ipairs(self.sbtns) do
		gui.animate(obj, gui.PROP_COLOR, vmath.vector4(0,0,0,0), gui.EASING_INOUTQUAD, 0.5, 0.0, on_animation_done)
	end	
end

function gui_fadein(self)
	gui_blackbox(self)
	gui.set_color(self.black_box, vmath.vector4(0, 0, 0, 1))	
	gui.animate(self.black_box, gui.PROP_COLOR, vmath.vector4(0, 0, 0, 0), gui.EASING_INOUTQUAD, 0.5, 0.0, on_animation_done)
	
end

function gui_on_message(self, message_id, message, sender)
	if message_id == hash("fadein") then
		gui_fadein(self)
	elseif message_id == hash("fadeout") then
		gui_fadeout(self)
	elseif message_id == hash("on_input") then	
		local world_scale_x = screen_w/screen_width
		local world_scale_y = screen_h/screen_height		
		if  message.action.touch then
			for i, tpoint in ipairs(message.action.touch) do
				local x=tpoint.x*world_scale_x
				local y=tpoint.y*world_scale_y
				handle_touch(self,x,y,tpoint.pressed,tpoint.released,pressed)
			end	
		else 
			local x=message.action.x*world_scale_x
			local y=message.action.y*world_scale_y
			handle_touch(self,x,y,message.action.pressed,message.action.released,pressed)
		end								
	end
end