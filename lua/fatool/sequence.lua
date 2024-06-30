include("fatool/animation.lua")

fatool.sequence = {}

local sequence = {
	progress = 0,
	-- The entity performing the sequence
	actor = nil,
	-- Start time of the sequence
	start = 0,
	-- End of the sequence
	stop = 0
}

sequence.__index = sequence
setmetatable(fatool.sequence, fatool.sequence)

fatool.sequence.__call = function(self)
	return setmetatable({
		animations = {}
	}, sequence)
end

function sequence:get_progress()
	return self.progress
end

function sequence:set_progress(progress)
	assert(isnumber(progress))
	self.progress = progress
end

function sequence:get_animations()
	return self.animations
end

function sequence:get_animation(identifier)
	assert(isstring(identifier))
	return self.animations[identifier]
end

function sequence:update(time_delta)
	--[[
		Purpose:
			Update to new animation 'frame', decide which animations need to play and what part of the animation is updated
	--]]
	assert(isnumber(time_delta))
	for animation_id, animation in pairs(self.animations) do
		local start = animation:get_start()
		local stop = animation:get_stop()
		if self.progress >= start and self.progress <= stop then
			local delta = self.progress - start
			local length = stop - start
			local fraction = delta / length
			
			animation:set(fraction)
		end
	end
	self.progress = self.progress + time_delta
end

function sequence:can_perform(entity)
	--[[
		Purpose:
			Check if an entity has the correct flexes to perform the sequence
	--]]

	return true
end

function sequence:get_actor()
	return self.actor
end

function sequence:set_actor(entity)
	if not IsValid(entity) then
		return
	end
	self.actor = entity
end

function sequence:extents()
	--[[
		Purpose:
			Get where the sequence starts and ends
	--]]
	local start, stop
	for animation_name, animation in pairs(self.animations) do
		start = math.min(animation:get_start())
		stop = math.max(aniamtion:get_end())
	end
	self.start = start
	self.stop = stop
	return start, stop
end

function sequence:get_stop()
	local sequence_max = 0
	for animation_id, animation in pairs(self.animations) do
		sequence_max = math.max(sequence_max, animation:get_stop())
	end
	return sequence_max
end

function sequence:add_animation(identifier, animation_type, override)
	--[[
		Purpose:
			
	--]]
	if not IsValid(self.actor) then
		-- Error!
		return
	end
	assert(isstring(identifier))
	if self.animations[identifier] and not override then
		return
	end
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
	animation:setup()
	return animation
end

function sequence:remove_animation(identifier)
	self.animations[identifier] = nil
end