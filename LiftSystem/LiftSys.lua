local MyApi = require "api/MyApi"
local CONF_PATH = "LiftSystem/Config.conf"
local DAT_PATH = "LiftSystem/floors.dat"
local INSTALLER_PATH = "LiftSystem/installer.lua"
local Com = MyApi.Command()
local modem = MyApi.ModemET()
local Display = MyApi.Display(peripheral.find("monitor"))
local FloorsList = { Floors = {} }
local Me = { Name = "", Floor = 0, Channel = 0, TypeSt = "FloorStation" } 
local Lift = { CurFloor = 0, NextFloor = 0 }
local timer_id
Com.SetName("LiftSys")

local function LiftUp()
    redstone.setOutput("right", true)
    redstone.setOutput("left", false)
end
local function LiftDown()
    redstone.setOutput("right", false)
    redstone.setOutput("left", false)
end
local function LiftStop()
    redstone.setOutput("left", true)
end
local function Door(open)
    redstone.setOutput("right", open)
end
local function ReleaseFloor(thisStop)
    redstone.setOutput("left", not thisStop)
end
local function PrefixSet()
    Display.SetPrefix(" ")
    if Lift.NextFloor == Lift.CurFloor then
        Display.SetPrefix("#", Lift.NextFloor)
    else
        Display.SetPrefix(">", Lift.NextFloor)
        Display.SetPrefix("=", Lift.CurFloor)
    end
end
local function UpdateAll()
    os.sleep(3)
end
Com.AddComand("updateAll", UpdateAll())

local function clear(cl_arg)
    if cl_arg[1] == "me" then
        FloorsList = { Floors = {} }
        fs.delete("floors.dat")
        local MYkey = Me.Me.Name
        FloorsList.Floors[MYkey] = Me.Me.Floor
        timer_id = os.startTimer(3)
    elseif cl_arg[1] == "all" then
        modem.SendMesage("ClearAll", "ALL")
        clear({ "me" })
    else
        print("Use argument <all> or <me>!")
    end
end
Com.AddComand("clear", clear)

local function getFloors()
    modem.SendMesage("SendFloors", FloorsList)
end

if Me.Me.TypeSt == "FloorStation" then
Com.AddComand("getfloors", getFloors)
end

local function tableEater(t)
    if type(t) == "table" then
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(k .. v .. " <" .. type(v) .. ">")
                tableEater(v)
            else
                print(k .. " = " .. v .. " <" .. type(v) .. ">")
            end
        end
    else
        print(t .. " <" .. type(t) .. ">")
    end
end

local function ReadFile()
    shell.setDir("/")
    if fs.exists(CONF_PATH) then
        local file = fs.open(CONF_PATH, "r")
        Me = textutils.unserialise(file.readAll())
        file.close()
    else
        error("No Config.conf at " .. CONF_PATH)
    end
    if fs.exists(DAT_PATH) then
        local file = fs.open(DAT_PATH, "r")
        FloorsList = textutils.unserialise(file.readAll())
        file.close()
    else
        clear({ "me" })
    end
    modem.SetName(Me.Me.Name)
    modem.SetChannel(44)
    table.sort(FloorsList.Floors, function(a, b)
        return tonumber(a) < tonumber(b)
    end)
end

local function Goto(floor)
    if floor == "stop" then
        modem.SendMesage("Lift_stop")
    else
        modem.SendMesage("SetFloor", floor[1])
        Lift.NextFloor = tonumber(floor[1])
        PrefixSet()
    end
end
Com.AddComand("goto", Goto)

local function Myexit()
    print("stoping...")
    sleep(1)
    error()
end
Com.AddComand("stop", Myexit)

local function save(cl_arg)
    if cl_arg[1] == "me" then
        local file = fs.open(DAT_PATH, "w")
        file.write(textutils.serialize(FloorsList))
        print("saving...")
        file.close()
    elseif cl_arg[1] == "all" then
        modem.SendMesage("Save")
        save({ "me" })
    else
        print("Use argument <all> or <me>!")
    end
end
Com.AddComand("save", save)

local function reboot(cl_arg)
    if cl_arg[1] == "me" then
        print("rebooting...")
        shell.run("reboot")
    elseif cl_arg[1] == "all" then
        modem.SendMesage("Reboot", "")
        reboot({ "me" })
    else
        print("Use argument <all> or <me>!")
    end
end
Com.AddComand("reboot", reboot)

local function floorButton(ID, Name)
    Lift.NextFloor = ID
    PrefixSet()
    Goto({ ID })
    ReleaseFloor((tonumber(Lift.NextFloor) == tonumber(Me.Me.Floor)))
    Display.write(1)
end

local function updButton()
    if Me.Me.TypeSt == "FloorStation" then
        Display.clearButton()
        for key, value in pairs(FloorsList.Floors) do
            Display.addButton(key, value, floorButton)
        end
        PrefixSet()
        Display.write(0.5)
    end
end

local function TryAddFloor(data)
    --print(not (data["Floors"] == nil))
    if not (data["Floors"] == nil) then
        for key, value in pairs(data.Floors) do
            if FloorsList.Floors[key] == nil then
                FloorsList.Floors[key] = value
                updButton()
                print("Add " .. key .. " with " .. value)
            end
        end
    end
end

function MesageHandler(Type, data)
    if Type == "FloorInfo" then
        Lift.CurFloor = tonumber(data)
    elseif Type == "SetFloor" then
        Lift.NextFloor = tonumber(data)
    elseif Type == "Reboot" then
        os.sleep(2)
        reboot({ "me" })
    end
end

local function StationMesageHandler(Type, data)
    MesageHandler(Type, data)
    if Type == "FloorInfo" or Type == "SetFloor" then
        if Lift.CurFloor < Lift.NextFloor then
            LiftUp()
        elseif Lift.CurFloor > Lift.NextFloor then
            LiftDown()
        else
            LiftStop()
        end
    elseif Type == "Lift_stop" then
        LiftStop()
    end
end

local function FloorMesageHandler(Type, data)
    MesageHandler(Type, data)
    PrefixSet()
    if Type == "ClearAll" then
        clear({ "me" })
    elseif Type == "SendFloors" then
        TryAddFloor(data)
        modem.SendMesage("SendMe", FloorsList)
    elseif Type == "SendMe" then
        TryAddFloor(data)
    elseif Type == "SetFloor" then
        ReleaseFloor((tonumber(Lift.NextFloor) == tonumber(Me.Me.Floor)))
        --print((tonumber(Lift.NextFloor) == tonumber(Me.Me.Floor)))
        if (Lift.NextFloor <= Me.Me.Floor and Lift.CurFloor >= Me.Me.Floor) or (Lift.NextFloor >= Me.Me.Floor and Lift.CurFloor <= Me.Me.Floor) then
            Door(true)
        else
            Door(Lift.NextFloor == Me.Me.Floor)
        end
        Display.write(1)
    elseif Type == "FloorInfo" then
        Display.write(1)
    elseif Type == "Save" then
        save({ "me" })
    end
end


local function redstoneHandler()
    if Me.Me.TypeSt == "FloorStation" then
        if redstone.getInput("right") then
            modem.SendMesage("FloorInfo", Me.Me.Floor)
            Lift.CurFloor = tonumber(Me.Me.Floor)
            PrefixSet()
            Display.write(1)
        end
    end
end

local function EventHandler()
    while true do
        local eventData = { os.pullEvent() }
        if eventData[1] == "redstone" then
            redstoneHandler()
        end
        if eventData[1] == "timer" then
            if eventData[2] == timer_id then
                updButton()
            end
        end
        Com.Update(eventData)
        modem.Update(eventData)
        if Me.Me.TypeSt == "FloorStation" then
            Display.Update(eventData)
        end
    end
end

local function Reader()
    while true do
        Com.ReadCommand()
    end
end


local function Setup()
    if Me.Me.TypeSt == "LiftContoler" then
        print("I'm lift mechanic controler")
        modem.SetHandler(StationMesageHandler)
    end
    if Me.Me.TypeSt == "FloorStation" then
        modem.SetHandler(FloorMesageHandler)
        print("I'm lift floor station")
        Display.updFunc(updButton)
        updButton()
        Display.write()
        --end
    end
end

local function main()
    ReadFile()
    Setup()
    parallel.waitForAll(EventHandler, Reader)
end

os.sleep(1)
main()
