local todo = {}

local opts = {
    fullpath = vim.env.XDG_CONFIG_HOME .. '/todo.md',
    keymap = '<leader>td',
    win_opts = {
        relative = 'editor',
        width = 80,
        height = 20,
        col = math.floor((vim.o.columns - 80) / 2),
        row = math.floor((vim.o.lines - 20) / 2),
        style = 'minimal',
        border = 'single',
        title = 'TODO',
        title_pos = 'center'
    }
}

local state = {
    buf = -1,
    win = -1
}

local open_popup = function()
    if not vim.api.nvim_buf_is_valid(state.buf) then
        state.buf = vim.api.nvim_create_buf(false, false)
    end
    state.win = vim.api.nvim_open_win(state.buf, true, opts.win_opts)
    vim.cmd("edit" .. opts.fullpath)
end

local close_popup = function()
    vim.api.nvim_win_close(state.win, true)
end

local window_exists = function(window_id)
    local windows = vim.api.nvim_list_wins()
    for _, win_id in ipairs(windows) do
        if win_id == window_id then
            return true
        end
    end
    return false
end

local toggle_popup = function()
    if window_exists(state.win) then
        close_popup()
    else
        open_popup()
    end
end

local function merge_config(t1, t2)
    for key, value in pairs(t2) do
        if t1[key] == nil then
            t1[key] = value
        else
            if type(value) == "table" and type(t1[key]) == "table" then
                merge_config(t1[key], value)
            else
                t1[key] = value
            end
        end
    end
    return t1
end

todo.setup = function(input_opts)
    if input_opts ~= nil then
        merge_config(opts, input_opts)
    end
    vim.keymap.set("n", opts.keymap, function() toggle_popup() end)
end

return todo
