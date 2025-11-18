arg = { ... }
local width, height = term.getSize()
local Mconfig = {}

local function Confirm(Text)
    write(Text)
    local val = read()
    if val == "y" or val == "Y" then
        return true
    else
        return false
    end
end

local function writeTesxCenter(text, Y)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.yellow)
    term.setCursorPos(1, Y)
    term.clearLine()
    term.setCursorPos(math.floor(width / 2 - string.len(text) / 2), Y)
    write(text)
end

local function bar(ratio, Y)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lime)
    term.setCursorPos(1, Y)
    write("[")
    for i = 1, width - 2 do
        if (i / (width - 1) < ratio) then
            write("#")
        else
            write("_")
        end
    end
    write("]")
end

local function update()
    error("I can not be update by installer! Do this manual!")
end

local function install()
    
    Mconfig = { Name = "", Floor = 0, Channel = 0, TypeSt = "FloorStation" } 
    local YBfloor = 7
    local function FloorStation()
        term.setCursorPos(1, 5)
        write("Set name of floor: ")
        Mconfig["Name"] = read()
        bar(0.8, YBfloor)
        term.setCursorPos(1, 6)
        write("Set floor number: ")
        Mconfig["Floor"] = read()
    end
    term.setBackgroundColor(colors.gray)
    term.clear()
    writeTesxCenter('Installing "Mrbiglizard lift system"', 1)
    bar(0.1, YBfloor)
    term.setCursorPos(1, 2)
    write("Set modem channel: ")
    Mconfig["Channel"] = read()
    os.sleep(0.5)
    term.setCursorPos(1, 3)
    if not (peripheral.find("monitor") == nil) then
        write("This computer have a monitor")
        bar(0.3, YBfloor)
        term.setCursorPos(1, 4)
        os.sleep(0.5)
        if Confirm("Set this computer as floor station(Y/N):") then
            Mconfig["TypeSt"] = "FloorStation"
            bar(0.6, YBfloor)
            FloorStation()
        else
            Mconfig["TypeSt"] = "LiftContoler"
            bar(0.6, YBfloor)
        end
    else
        write("This computer does not have a monitor.")
        term.setCursorPos(1, 4)
        bar(0.3, YBfloor)
        if Confirm("Set this computer as lift controller(Y/N):") then
            Mconfig["TypeSt"] = "LiftContoler"
            bar(0.6, YBfloor)
        else
            Mconfig["TypeSt"] = "FloorStation"
            bar(0.6, YBfloor)
            FloorStation()
        end
    end
    bar(9, YBfloor)

    local file = fs.open("Config.conf", "w")
    file.write(textutils.serialize(Mconfig))
    file.close()
    bar(1, YBfloor)
    os.sleep(2)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, 1)
    term.clear()
    
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