arg = { ... }
local width, height = term.getSize()
local Mconfig = {}
local STARTCMD = "shell.run(\"LiftSystem/LiftSys.lua\")"


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
    local lineI = 1
    local YBfloor = 7
    local function WR(text)
        term.setCursorPos(1, lineI)
        write(text)
        lineI = lineI + 1
    end
    local function Confirm(Text)
        term.setCursorPos(1, YBfloor + 1)
        term.clearLine()
        write(Text)
        local val = read()
        if val == "y" or val == "Y" then
            return true
        else
            return false
        end
    end
    local function FloorStation()
        WR("Set name of floor: ")
        Mconfig["Name"] = read()
        bar(0.8, YBfloor)
        WR("Set floor number: ")
        Mconfig["Floor"] = read()
    end
    local function InsertLineToFile(File, number, text)
        local lines = {}
        local file_in = io.open(File, "r")
        if file_in then
            for line in file_in:lines() do
                if line == text then
                    file_in:close()
                    return
                end
                table.insert(lines, line)
            end
            file_in:close()
        end
        if number == 1 then
            table.insert(lines, number, text)
        end
        local temp_filename = File .. ".temp"
        local file_out = io.open(temp_filename, "w")
        if file_out then
            for _, line in ipairs(lines) do
                file_out:write(line)
                --file_out:write("\n")
            end
            if not (number == 1) then
                file_out:write(text)
            end
            file_out:close()
        end
        fs.delete(File)
        fs.move(temp_filename, File)
    end

    term.setBackgroundColor(colors.gray)
    term.clear()
    writeTesxCenter('Installing "Mrbiglizard lift system"', lineI)
    lineI = lineI + 1
    bar(0.1, YBfloor)
    WR("Set modem channel: ")
    Mconfig["Channel"] = read()
    os.sleep(0.5)
    if not (peripheral.find("monitor") == nil) then
        WR("This computer have a monitor")
        bar(0.3, YBfloor)
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
        WR("This computer does not have a monitor.")
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
    bar(0.7, YBfloor)
    local file = fs.open("Config.conf", "w")
    file.write(textutils.serialize(Mconfig))
    file.close()
    if fs.exists("startup.lua") then
        WR("startup.lua allready exist")
        if Confirm("Add line in file or delete file (Y/N):") then
            bar(0.8, YBfloor)
            if Confirm("Add as first line or last (Y/N):") then
                bar(0.9, YBfloor)
                InsertLineToFile("startup.lua", 1, STARTCMD)
            else
                InsertLineToFile("startup.lua", -1, STARTCMD)
            end
        else
            fs.delete("startup.lua")
            InsertLineToFile("startup.lua", 1, STARTCMD)
        end
    else
        local file = fs.open("startup.lua", "w")
        file.close()
        InsertLineToFile("startup.lua", 1, STARTCMD)
    end


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
