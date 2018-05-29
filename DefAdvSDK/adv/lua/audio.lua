local config = require "adv/lua/config"

local M = {}

function M.playmusic(self,music)
	M.music=music
	if config.audio==1 then 		
		msg.post(music,"play_sound",{gain = 1.0})
	end	
end

function M.stopmusic(self)
	if M.music then 
		if config.audio==1 then 		
			msg.post(M.music, "stop_sound")
		end
		M.music=nil
	end	
end

function M.playsound(self,sound)
	if config.sound==1 then 
		msg.post(sound,"play_sound",{gain = 1.0})
	end
end

return M