local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')

local is_bazel_workspace = function () 
	response = vim.system(
			{ 'bazel', 'info', 'workspace' }, 
			{ text = true, cwd = vim.fn.expand("%:p:h") }
		):wait()
	if response.code ~= 0 or not response.stdout or response.stdout == '' then
		return nil
	end
	return response.stdout
end

local find_bazel_targets = function (root)
	local current_dir = vim.fn.expand("%:p:h")
	local bazel_query = build_bazel_query(root, current_dir)
	response = vim.system(
			{ 'bazel', 'query', bazel_query }, 
			{ text = true, cwd = current_dir }
		):wait()
	if response.code ~= 0 or not response.stdout or response.stdout == '' then
		return {}
	end
	return extract_bazel_targets(response.stdout)
end

local build_bazel_query = function (root, current_dir) 
	local target_base = string.sub(current_dir, string.len(root))
	if string.len(target_base) == 0 then
		return "//..."
	end
	return "//" .. target_base .. "/..."
end

local extract_bazel_targets = function (input_string)
	local targets = {} 
  	for target in input_string:gmatch("//[^\n]+") do
		table.insert(targets, target)
	end
	return targets
end

local bazel_target_picker = function ()
	bazel_workspace = is_bazel_workspace()
	if not bazel_workspace then
		print("Not in a bazel workspace")
		return
	end

	bazel_targets = find_bazel_targets(bazel_workspace)
	for target in bazel_targets do
		print(target)
	end
	-- opts = {}
	-- pickers.new(opts, {
	-- 	prompt_title = "Bazel Targets",
	-- 	finder = finders.new_table {
	-- 		results = bazel_targets,
	-- 	},
	-- 	sorter = conf.generic_sorter(opts),
	-- }):find()

end

bazel_target_picker()
