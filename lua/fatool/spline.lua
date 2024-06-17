fatool.spline = {}

local spline = {
	-- Catmull-Rom spline parameters used to change its shape
	alpha = 0.5,
	tension = 0,
	-- Array of points in the spline. Points are Vector types.
	points = {},
	-- Array of pairs of points. A pair of points specifies a segment
	segments = {},
	-- Spline control points which specify the start and end of the spline
	control0 = Vector(0),
	control1 = Vector(0,1),
	-- Length of the spline
	length = 0,
	-- Spline Y offset
	offset = 0
}

spline.__index = spline

function fatool.spline.new(alpha, tension)
	[[
		Purpose:
			Create an instance of a spline object
	]]
	return setmetatable({alpha = alpha, tension = tension}, spline)
end

local function catmull_rom(alpha, tension, p0, p1, p2, p3)
	[[
		Purpose:
			Compute Catmull-Rom spline coefficients
	]]
	local t0 = 0
	local t1 = t0 + math.pow(p0:Distance2D(p1), alpha)
	local t2 = t1 + math.pow(p1:Distance2D(p2), alpha)
	local t3 = t2 + math.pow(p2:Distance2D(p3), alpha)
	
	local m1 = (1 - tension) * (t2 - t1) * ((p1 - p0) / (t1 - t0) - (p2 - p0) / (t2 - t0) + (p2 - p1)/(t2 - t1))
	local m2 = (1 - tension) * (t2 - t1) * ((p2 - p1) / (t2 - t1) - (p3 - p1) / (t3 - t1) + (p3 - p2)/(t3 - t2))
	
	local a = 2 * (p1 - p2) + m1 + m2
	local b = -3 * (p1 - p2) - m1 - m1 - m2
	local c = m1
	local d = p1
	
	return a, b, c, d
end

function spline:coefficients(segment_index)
	[[
		Purpose:
			Compute coefficients of a single segment
	]]
	local segment = self.segments[segment_index]
	if not segment then
		return
	end
	local left_segment = self.segments[segment_index - 1]
	local right_segment = self.segments[segment_index + 1]
	-- If left segment doesn't exist then segment.p0 is the left control point
	local p0 = left_segment and left_segment.p0 or segment.p0
	local p1 = segment.p0
	local p2 = segment.p1
	-- If right segment doesn't exist then segment.p1 is the right control point
	local p3 = right_segment and right_segment.p1 or segment.p1
	
	segment.coefficients = {catmull_rom(self.alpha, self.tension, p0, p1, p2, p3)}
end

function spline:sample(segment_index,t)
	[[
		Purpose:
			Sample a segment for t between 0 and 1 using the polynomial fit
	]]
	local segment = self.segments[segment_index]
	if not segment then
		return
	end
	local coef = segment.coefficients
	return coef[1] * t*t*t + coef[2] * t*t + coef[3] * t + coef[4]
end

function spline:segment_length(segment_index, iterations)
	[[
		Purpose:
			Compute length of a single segment
	]]
	local segment = self.segments[segment_index]
	if not segment then 
		return 
	end
	-- Use a linear step for t and compute length for each step
	-- This could be improved using a numerical integration method
	local step = 1 / iterations
	local t = 0
	local old_point = segment.p0.pos
	local new_point
	local length = 0
	for i = 1, steps do
		t = t + fraction
		new_point = self:sample(segment_index, t)
		length = length + old_point:Distance2D(new_point)
		old_point = new_point
	end
	return length
end

function spline:segment()
	[[
		Purpose:
			Generate segments from the list of points, assumes they are ordered according to ascending X value
	]]
	self.segments = {}
	local previous_point
	for i, point in ipairs(self.points) do
		if not previous_point then
			previous_point = self.control0
		end
		table.insert(self.segments, {p0 = previous_point, p1 = point})
		previous_point = point
	end
	-- Add final segment which contains last point and control point
	table.insert(self.segments, {p0 = previous_point, p1 = control1})
end

function spline:add_point(point)
	[[
		Purpose:
			Add a point to the spline and recompute
	]]
	table.insert(self.points, point)
	table.sort(self.points, 
		function(p0, p1)
			return p0.x < p1.x
		end)
	self.segment()
end