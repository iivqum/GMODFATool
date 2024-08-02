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

function animation:set(fraction)
	--[[
		Purpose:
			Called when the sequence applies the animation to the actor
	--]]
	if self.sequence == nil or not IsValid(self.sequence:get_actor()) then
		-- Error!
		return
	end
	local actor = self.sequence:get_actor()
	for motion_id, motion in pairs(self.motions) do
		local flex_id = actor:GetFlexIDByName(motion_id)
		if not flex_id then
			return
		end
		local lower_bound, upper_bound = self:get_motion_bounds(motion_id)
		local flex_weight = motion:sample_continous(fraction, animation_samples)
		if flex_weight < 0 then
			flex_weight = flex_weight * math.abs(lower_bound)
		elseif flex_weight > 0 then
			flex_weight = flex_weight * math.abs(upper_bound)
		end
		actor:SetFlexWeight(flex_id, flex_weight)
	end
end

function animation:has_unsupported_flexes()
	local actor = self.sequence:get_actor()
	for motion_id, motion in pairs(self.motions) do
		local flex_id = actor:GetFlexIDByName(motion_id)
		if not flex_id then
			return true
		end
	end
	return false
end

function animation:get_motion_bounds(motion_id)
	if not self:get_motion(motion_id) then
		return
	end
	local actor = self.sequence:get_actor()
	local flex_id = actor:GetFlexIDByName(motion_id)
	if not flex_id then
		-- ERROR!
		return 0, 0
	end
	return actor:GetFlexBounds(flex_id)
end

function animation:setup()
	--[[
		Purpose:
			Create all data that needs to be set up
	--]]
	local actor = self.sequence:get_actor()
	if self.sequence == nil or not IsValid(actor) then
		-- Error!
		return
	end
	local flex_num = actor:GetFlexNum()
	for i = 1, flex_num do
		local flex_id = actor:GetFlexName(i)
		if flex_id then
			self:add_motion(flex_id)
		end
	end
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
	self.stop_time = math.max(self.start_time, stop_time)
end

function animation:get_motions()
	return self.motions
end

function animation:get_motion(motion_identifier)
	return self.motions[motion_identifier]
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