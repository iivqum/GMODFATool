fatool.directory = "fatool/"

file.CreateDir(fatool.directory)

function fatool.save(sequence, sequence_identifier, model_name)
	local json_table = {animations = {}, model = model_name}
	for animation_id, animation in pairs(sequence:get_animations()) do
		local animation_table = {
			start = animation:get_start(),
			stop = animation:get_stop(),
			motions = {}
		}
		for motion_id, motion in pairs(animation:get_motions()) do
			local motion_table = {}
			for point_index, point in ipairs(motion:get_points()) do
				motion_table[point_index] = point
			end
			animation_table.motions[motion_id] = motion_table
		end
		json_table.animations[animation_id] = animation_table
	end
	local json_string = util.TableToJSON(json_table, true)
	file.Write(fatool.directory .. sequence_identifier .. ".json", json_string)
end

function fatool.load(filename)
	local json_string = file.Read(fatool.directory .. filename)
	if not json_string then
		return
	end
	local json_table = util.JSONToTable(json_string)
	if not json_table then
		return
	end
	local sequence = fatool.sequence()
	for animation_id, animation in pairs(json_table.animations) do
		local sequence_animation = sequence:add_animation(animation_id)
		sequence_animation:set_start(animation.start)
		sequence_animation:set_stop(animation.stop)
		for motion_id, motion in pairs(animation.motions) do
			local sequence_motion = sequence_animation:add_motion(motion_id)
			for point_index, point in ipairs(motion) do
				sequence_motion:add_point(point)
			end
		end
	end
	return {
		sequence = sequence,
		load_model = json_table.model
	}
end