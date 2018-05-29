local M = {}

M.LEFT=1
M.RIGHT=2

function M.play_animation(self,anim,facing)
	if facing and facing ~= self.current_facing then
		self.current_facing=facing
		if facing==M.LEFT then
			sprite.set_hflip("#sprite", true)
		else
			sprite.set_hflip("#sprite", false)
		end
	end
	if anim==nil or anim == self.current_anim then return end
	msg.post("#sprite", "play_animation", { id = hash(anim) })
	self.current_anim = anim
end

return M

