
-- // LOCALISATIONS STRINGS //
local loc_data = {
  en = {
    task = "Follow-up task",
    done = "Done"
  },
  ru = {
    task = "Сделайте самостоятельно",
    done = "Сделано"
  }
}
-- // END OF LOCALISATION STRINGS //

-- localisation helper function
local M = {}
local current_loc_data = loc_data["en"] -- default language: english

-- set localisation language
function M.load(lang)
  current_loc_data = loc_data[lang] or loc_data["en"]
end

function M.get(key)
  return current_loc_data[key] or loc_data["en"][key] or key
end

-- make table callable
setmetatable(M, {
  __call = function(_, key)
    return M.get(key)
  end
})

return M