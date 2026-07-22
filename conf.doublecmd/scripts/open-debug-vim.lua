local params = {...}

local function shell_quote(value)
  return "'" .. string.gsub(value, "'", "'\"'\"'") .. "'"
end

if #params == 2 and params[1] ~= "" and params[2] ~= "" then
  local command = "/bin/bash " .. shell_quote(params[1]) .. " " .. shell_quote(params[2])
  local result = os.execute(command)
  if result == nil or result == false or (type(result) == "number" and result ~= 0) then
    Dialogs.MessageBox("Could not start shared debug Vim.", "Double Commander", 0x0000)
  end
end
