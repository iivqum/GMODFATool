fatool.spline = {}

local spline = {
	-- Catmull-Rom spline parameters used to change its shape
	alpha = 0.5,
	tension = 0.2,
	-- Offscreen and only for spline continuity
	anchor0 = Vector(-0.5),
	anchor1 = Vector(1.5),
	-- Minimum and maximum extents of the spline
	control0 = Vector(0),
	control1 = Vector(1),
	-- Length of the spline
	length = 0,
	-- Spline Y offset
	offset = 0
}

spline.__index = spline
setmetatable(fatool.spline, fatool.spline)

fatool.spline.__call = function(self, alpha, tension)
	local instance = setmetatable({
		alpha = alpha, 
		tension = tension,
		-- Array of points in the spline. Points are Vector types and must be normalized and 0 < x < 1.
		points = {},
		-- Array of pairs of points. A pair of points specifies a segment
		segments = {}
	}, spline)
	instance:update()
	return instance
end

local function catmull_rom(alpha, tension, p0, p1, p2, p3)
	--[[
		Purpose:
			Compute Catmull-Rom spline coefficients
	--]]
	local t0 = 0
	local t1 = t0 + math.pow(p0:Distance2D(p1), alpha)
	local t2 = t1 + math.pow(p1:Distance2D(p2), alpha)
	local t3 = t2 + math.pow(p2:Distance2D(p3), alpha)
	
	local m1 = (1 - tension) * (t2 - t1) * ((p1 - p0) / (t1 - t0) - (p2 - p0) / (t2 - t0) + (p2 - p1) / (t2 - t1))
	local m2 = (1 - tension) * (t2 - t1) * ((p2 - p1) / (t2 - t1) - (p3 - p1) / (t3 - t1) + (p3 - p2) / (t3 - t2))
	
	local a = 2 * (p1 - p2) + m1 + m2
	local b = -3 * (p1 - p2) - m1 - m1 - m2
	local c = m1
	local d = p1
	
	return a, b, c, d
end

function spline:update()
	--[[
		Purpose:
			Calculate everything needed for the spline
	--]]
	self:segment()
	for i, segment in ipairs(self.segments) do
		self:coefficients(i)
	end
end

function spline:coefficients(segment_index)
	--[[
		Purpose:
			Compute coefficients of a single segment
	--]]
	local segment = self.segments[segment_index]
	if not segment then
		return
	end
	local left_segment = self.segments[segment_index - 1]
	local right_segment = self.segments[segment_index + 1]
	-- If left segment doesn't exist then segment.p0 is the left control point
	local p0 = left_segment and left_segment.p0 or self.anchor0
	local p1 = segment.p0
	local p2 = segment.p1
	-- If right segment doesn't exist then segment.p1 is the right control point
	local p3 = right_segment and right_segment.p1 or self.anchor1
	
	segment.coefficients = {catmull_rom(self.alpha, self.tension, p0, p1, p2, p3)}
	
	return segment.coefficients
end

function spline:sample(segment_index,t)
	--[[
		Purpose:
			Sample a segment for t between 0 and 1 using the polynomial fit
	--]]
	local segment = self.segments[segment_index]
	if not segment then
		return
	end
	local coef = segment.coefficients
	return coef[1] * t*t*t + coef[2] * t*t + coef[3] * t + coef[4]
end

function spline:sample_continous(x, iterations)
	--[[
		Purpose:
			Sample from the entire spline for 0 <= x <= 1, approximating the spline as a continous function f(x)
	--]]
	for segment_index, segment in ipairs(self.segments) do
		local p0 = segment.p0
		local p1 = segment.p1
		-- True if the point of interest is contained by the segment
		if x <= p1.x and x >= p0.x then
			-- Bounds of the sample space
			local sample_start = 0
			local sample_end = 1
			local pos
			-- Binary space partition method to approximate a point on the spline
			-- Sample resolution is 2^iterations, percent error is 100/(2^iterations)
			for i = 1, iterations do
				local delta = (sample_end - sample_start) * 0.5
				pos = self:sample(segment_index, sample_start + delta)
				if x < pos.x then
					sample_end = sample_end - delta
				elseif x > pos.x then
					sample_start = sample_start + delta
				elseif x == pos.x then
					break
				end
			end
			return pos.y
		end
	end
	-- X is outside the bounds of the spline
	return 0
end

function spline:sample_along(segment_index, iterations, sample_func)
	--[[
		Purpose:
			Sample at fixed intervals along a spline segment
	--]]
	local segment = self.segments[segment_index]
	if not segment then 
		return 
	end
	-- Use a linear step for t and compute length for each step
	-- This could be improved using a numerical integration method
	local step = 1 / iterations
	local t = 0
	local old_point = Vector(segment.p0)
	local new_point = Vector()
	for i = 1, iterations do
		t = t + step
		new_point:Set(self:sample(segment_index, t))
		sample_func(old_point, new_point)
		old_point:Set(new_point)
	end
end

function spline:segment()
	--[[
		Purpose:
			Generate segments from the list of points, assumes they are ordered according to ascending X value
	--]]
	self.segments = {}
	-- There's a faster way of doing this
	local previous_point = self.control0
	for i, point in ipairs(self.points) do
		table.insert(self.segments, {p0 = previous_point, p1 = point})
		previous_point = point
	end
	-- Add final segment which contains last point and control point
	table.insert(self.segments, {p0 = previous_point, p1 = self.control1})
end

function spline:nearest_point(position)
	--[[
		Purpose:
			Get the nearest point on the spline from an arbitrary position
	--]]
	
end

function spline:remove_point(point_index)
	--[[
		Purpose:
			Remove a point from the spline
	--]]
	if not self.points[point_index] then
		return
	end
	table.remove(self.points,point_index)
	self.segment()
end

function spline:add_point(point)
	--[[
		Purpose:
			Add a point to the spline and recompute
	--]]
	local point_index = table.insert(self.points, point)
	table.sort(self.points, 
		function(p0, p1)
			return p0.x < p1.x
		end)
	self:segment()
	return point_index
end

function spline:get_segments()
	return self.segments
end

function spline:get_points()
	return self.points
end