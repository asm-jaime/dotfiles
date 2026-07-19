local params = {...}

if #params == 1 and params[1] ~= "" then
  Clipbrd.SetAsText(params[1])
end
