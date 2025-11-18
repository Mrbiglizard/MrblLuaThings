arg = { ... }

local function update()
    error("I can not be update by installer!")
end

local function install()
    print("I'm installer! I install example!")
    print("Let's run this!")
    shell.run("ExPr/example.lua")
end

local function delete()
    error("I can not be deleted by installer! Do this manual!")
end

if #arg <= 0 then
    install()
end
if #arg >= 1 and arg[1] == "install" then
    install()
elseif #arg >= 1 and arg[1] == "update" then
    update()
elseif #arg >= 1 and arg[1] == "delete" then
    delete()
end
