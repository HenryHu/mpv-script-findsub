utils = require 'mp.utils'

EXTENSIONS = {'srt','ssa','ass', '[VeryCD.com].ssa'}

LANGUAGES = {'en','Eng','chs','Chs','cn','sc_v2', 'sc','SC','uni_gb','gb','GBK','GB','cht','chi','tc','TC','uni_big5','neta'}

function find_subs(file_path)
    file_dir, file_name = utils.split_path(file_path)
    ret = string.match(file_name, "(.*)%.(.*)$")
    if ret == nil then
        return {}
    end
    base_name, ext = ret
    subs = {}
    for i, lang in ipairs(LANGUAGES) do
        for j, sub_ext in ipairs(EXTENSIONS) do
            if lang == nil then
                sub_name = table.concat({base_name, sub_ext}, ".")
            else
                sub_name = table.concat({base_name, lang, sub_ext}, ".")
            end
            sub_path = utils.join_path(file_dir, sub_name)
            -- check if the file exists
            if os.rename(sub_path, sub_path) then
                subs[#subs + 1] = sub_path
            end
        end
    end
    return subs
end

function start_file_cb(event)
    print("start playback")
    file_path = mp.get_property("path")
    ret = find_subs(file_path)
    for i, sub_path in ipairs(ret) do
        -- if we don't use auto, it results in assertion failure
        mp.commandv("sub_add", sub_path, "auto")
    end
end

function file_loaded_cb(event)
    mp.commandv("sub_reload", 1)
end

mp.add_key_binding("b", "auto_find_subs", find_sub)
mp.register_event("start-file", start_file_cb)
mp.register_event("file-loaded", file_loaded_cb)
