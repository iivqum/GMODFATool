fatool.sequence = {}

local sequence = {
	progress = 0,
	-- The entity performing the sequence
	actor = 0
}

sequence.__index = sequence
setmetatable(fatool.sequence, fatool.sequence)

fatool.sequence.__call = function(self)
	return setmetatable({
		animations = {}
	}, sequence)
end

function sequence:extents()
	--[[
		Purpose:
			Get where the sequence starts and ends
	--]]
	local start, stop = 0,0
	for animation_index, animation in pairs(self.animations)
		start = math.min(animation:get_start())
		stop = math.max(aniamtion:get_end())
	end
	return start, stop
end

function sequence:add_animation(identifier, animation_type)
	--[[
		Purpose:
			
	--]]
	assert(isstring(identifier))
	animation_type = animation_type or "flex"
	local animation
	if animation_type == "flex" then
		animation = fatool.animation()
	else
		ErrorNoHalt("Bad animation type")
		return
	end
	self.animations[identifier] = animation
	animation:attach_sequence(self)
	
	return animation
end