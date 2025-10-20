
local options = {
    
    sub_folder = {"sub"},
    sub_ext = {"srt", "ass"}
    
}

mp.options = require "mp.options"
mp.options.read_options(options, "loadsub")

mp.msg = require "mp.msg"
mp.utils = require "mp.utils"

local function get_season_episode(filename)
    local season, episode = string.match(filename, "[sS]0*(%d+)%D*[eE]0*(%d+)")
    return season, episode
end

local function is_sub_ext(ext)
    if not ext then
        return false
    end
    for _, target_sub in ipairs(options.sub_ext) do
        if ext == target_sub then
            return true
        end
    end
end

local function load_dir_sub(dir, key)
    local files = mp.utils.readdir(dir, "files")
    if not files then
        return
    end
    for _, file in ipairs(files) do
        local ext = string.match(file, key)
        if is_sub_ext(ext) then
            local full_path = mp.utils.join_path(dir, file)
            mp.msg.info(full_path)
            mp.commandv("sub-add", full_path, "cached")
        end
    end
end

local function loadsub()
    local path = mp.get_property("path")
    local dir, filename = mp.utils.split_path(path)
    local season, episode = get_season_episode(filename)
    if not (season and episode) then
        return
    end

    local new_match = "[sS]0*"..season.."%D*[eE]0*"..episode.."%D.*%.(%w+)$"

    load_dir_sub(dir, new_match)
    for _, sub_folder in ipairs(options.sub_folder) do
        local sub_folder = mp.utils.join_path(dir, sub_folder)
        load_dir_sub(sub_folder, new_match)
    end
end



mp.register_event("file-loaded", loadsub)