local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')

get_bazel_workspace = function () 
	local workspace = vim.fn.system('bazel info workspace 2> /dev/null')
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return workspace
end

bazel_target_picker = function (kind_pattern, completion)
	local workspace = get_bazel_workspace()
	print(workspace)
	if not workspace then
		print("Not in a bazel workspace")
		return
	end
	
	kind_pattern = kind_pattern or ".*"
	local opts = {}
	local relative_directory = string.sub(vim.fn.expand("%:p:h"), #workspace + 1)
	local query = string.format('kind("%s", //%s/...)', kind_pattern, relative_directory)	

	local finder = finders.new_oneshot_job({ 'bazel', 'query', query }, {})
	local picker = pickers.new(opts, {
		results_title = 'bazel targets',
		prompt_title = 'bazel targets',
		finder = finder, 
		sorter = conf.generic_sorter(opts),
		attach_mappings = function (bufnr, map)
			actions.select_default:replace(function () 
				actions.close(bufnr)
				local selection = actions_state.get_selected_entry()
				completion(selection[1])
			end)
			return true
		end
	})
	picker:find()
end

