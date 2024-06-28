fatool.animation = {}

local animation_samples = 16

local animation = {
	-- Start of the animation in the sequence
	start_time = 0,
	-- End of the animation in the sequence
	stop_time = 0,
	-- A reference to the sequence this animation is attached to
	sequence = nil,
	event_type = "flex"
}

animation.__index = animation
setmetatable(fatool.animation, fatool.animation)

fatool.animation.__call = function(self)
	return setmetatable({
		motions = {}
	}, animation)
end

function animation:get_type()
	return self.event_type
end

function animation:attach_sequence(sequence)
	self.sequence = sequence
end

function animation:apply_motion()

end

function animation:get_start()
	return self.start_time
end

function animation:get_stop()
	return self.stop_time
end

function animation:set_start(start_time)
	self.start_time = math.max(start_time, 0)
end

function animation:set_stop(stop_time)
	self.stop_time = stop_time
end

function animation:add_motion(identifier)
	--[[
		Purpose:
			Add the flex data to the animation. This is the data that will be sampled during the animation
	--]]
	assert(isstring(identifier))
	local spline = fatool.spline()
	self.motions[identifier] = spline
	return spline
end