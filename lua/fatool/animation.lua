fatool.animation = {}

local animation_samples = 16

local animation = {
	name = "default",
	-- Length of the animation in seconds
	length = 1,
	-- Progress of the animation in seconds
	progress = 0,
	playing = false,
	looped = false,
	-- Entity that is playing the animation
	actor = 0
}

animation.__index = animation
setmetatable(fatool.animation, fatool.animation)

fatool.animation.__call = function(self)
	return setmetatable({
		-- A list of flexes to be controlled by the animation, this is a table of splines where the key is the flex to be controlled
		flexes = {}
	}, animation)
end

function animation:get_fraction_complete()
	return self.progress / self.length
end

function animation:apply_frame()
	--[[
		Purpose:
			Apply an animation frame to the actor entity
	--]]
	if not IsValid(self.actor) then
		return
	end
	for flex_name, spline in pairs(self.flexes) do
		local flex_id = self.actor:GetFlexIDByName(flex_name)
		local flex_weight = spline:sample_continous(self:get_fraction_complete(), animation_samples)
		
		self.actor:SetFlexWeight(flex_id, flex_weight)
	end
end