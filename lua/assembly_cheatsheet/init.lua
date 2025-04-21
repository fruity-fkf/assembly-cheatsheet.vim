local M = {}

local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  vim.notify("Telescope is required for assembly_cheatsheet", vim.log.levels.ERROR)
  return
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")

local function plugin_dir()
  local str = debug.getinfo(1, "S").source:sub(2)
  return str:match("(.*/assembly_cheatsheet/)")
end

local function load_instructions()
  local path = plugin_dir() .. "instructions.json"
  local f = io.open(path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  return vim.json.decode(content)
end

function M.cheatsheet()
  local instructions = load_instructions()

  local displayer = entry_display.create({
    separator = " │ ",
    items = {
      { width = 10 },
      { remaining = true },
    },
  })

  pickers.new({}, {
    prompt_title = "Assembly Instruction Cheatsheet",
    finder = finders.new_table({
      results = instructions,
      entry_maker = function(entry)
        return {
          value = entry,
          display = function(e)
            return displayer({ e.value.instruction, e.value.description })
          end,
          ordinal = entry.instruction .. " " .. entry.description,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
          "Instruction: " .. entry.value.instruction,
          "",
          "Description:",
          entry.value.description,
        })
      end,
    }),
  }):find()
end

return M

