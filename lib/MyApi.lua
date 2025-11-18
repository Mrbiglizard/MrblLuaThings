local function Command()
    local completion = require "cc.shell.completion"
    local completions = require "cc.completion"
    local Fullpath = "ff"
    local Name
    local FileName
    local OneProgram = true
    local isnINI = true
    local commands = { ["stop"] = error }
    local complete

    local function makeName()
        Fullpath = shell.getRunningProgram()
        local t = {}
        --print(Fullpath)
        for str in string.gmatch(Fullpath, "([^/]+)") do
            table.insert(t, str)
        end
        if Name == nil then
            Name = t[#t]
        end
        FileName = t[#t]
    end
    local function Ini()
        if isnINI then
            makeName()
        end
        isnINI = false
    end
    local function MakeComp()
        Ini()
        --print(Fullpath)
        local t = {}
        local n = 0
        for k, v in pairs(commands) do
            n = n + 1
            t[n] = k
        end
        complete = t
        --print(FileName)
        shell.setCompletionFunction(Fullpath, completion.build({ completion.choice, t }))
        -- local complete = completion.build(
        --     { completion.choice, t }
        -- )
        -- shell.setCompletionFunction(Fullpath, complete)
    end

    local function SetName(name)
        Name = name
    end

    local function completeFn(text)
        return completions.choice(text, complete)
    end

    local function isMeOpen()
        local result = false
        for i = 1, multishell.getCount(), 1 do
            if (Name == multishell.getTitle(i)) then
                result = true
            end
        end
        return result
    end

    local function addComand(command, func)
        Ini()
        commands[command] = func
        MakeComp()
    end
    local function exec(command, comArg)
        --print(comArg)
        commands[command](comArg)
    end



    local function Update(eventData)
        if (eventData[1] == "Command") then
            local t = { eventData[2] }
            if eventData[2][1] == Fullpath then
                local t = { eventData[2][3][1] }
                exec(eventData[2][2], t)
            end
        end
    end
    local function SendComannd(command)
        if (commands[command[1]] ~= nil) then
            local name = command[1]
            table.remove(command, 1)
            local ed = { Fullpath, name, command }
            os.queueEvent("Command", ed)
        end
    end
    local function ReadCommand()
        local Rcom = read(nil, nil, completeFn)
        local t = {}
        for str in string.gmatch(Rcom, "([^%s]+)") do
            table.insert(t, str)
        end
        SendComannd(t)
    end



    local function OpenNewWindow(arg)
        Ini()
        SendComannd(arg)
        if OneProgram then
            if isMeOpen() then
                print("Program " .. Name .. " already started")
                error()
            end
        end
        --makeDate()
        if (multishell.getCurrent() == 1) then
            --    multishell.launch({},shell.getRunningProgram())
            local _curPath = shell.dir()
            shell.setDir("/")
            local id = shell.openTab(Fullpath)
            shell.switchTab(id)
            multishell.setTitle(id, Name)
            --print("exit 1 2 3 4 5 6 7 8 9")
            --select(2, debug.getupvalue(multishell.getCount, 1))[multishell.getCurrent()].bInteracted = true
            --_G.printError("0")
            shell.setDir(_curPath)
            error()
            --select(2, debug.getupvalue(multishell.getCount, 1))[multishell.getCurrent()].bInteracted = true
        end
    end
    return {
        OpenNewWindow = OpenNewWindow,
        SetName = SetName,
        AddComand = addComand,
        Update = Update,
        ReadCommand = ReadCommand,
        completeFn = completeFn,
        exec = exec
    }
end

local function Display(window)
    local window = window
    local buttons = {}
    local size = { 0, 0 }
    local curPage = 1
    local prefixesButton = {}
    local CursX = 1
    local CursY = 1
    local UpdateFunc
    local timer_id
    local function numPage()
        return math.floor(#buttons / (size[2] - 1) + 0.99)
    end
    local function addButton(Name, ID, func)
        local button = { ID = ID, Name = Name, func = func, prefixes = "" }
        --prefixesButton[Name] = ""
        table.insert(buttons, button)
        size[1], size[2] = window.getSize()
        CursX = 0
        CursY = 0
        table.sort(buttons, function(a, b)
            return a.ID > b.ID
        end)
    end

local function removeButton(Name)
    if not buttons[Name] == nil then
        table.remove(buttons,Name)
    end
end
    
local function clearButton()
    buttons = {}
end

    local function SetPrefix(st, Pos)
        --if Pos == nil then
        for key, value in pairs(buttons) do
            if Pos == nil then
                value.prefixes = st
            else
                if value.ID == Pos then
                    value.prefixes = st
                end
            end
        end
    end
    local function UpdFunc(_func)
        UpdateFunc = _func
    end
    local function genNextB(c)
        local result = ""
        for i = 1, (size[1] - 3) / 2, 1 do
            result = c .. result
        end
        return result
    end

    local function mWhite()
        window.setBackgroundColor(colors.white)
        window.setTextColor(colors.black)
    end

    local function mBlack()
        window.setBackgroundColor(colors.black)
        window.setTextColor(colors.white)
    end


    local function writeMyM()
        window.clear()
        for i = 1, size[2], 1 do
            local xC
            local yC
            xC, yC = window.getCursorPos()
            if yC < size[2] then
                local k = (curPage - 1) * (size[2] - 1)
                if i + k <= #buttons then
                    if CursY == i then
                        buttons[i + k]["func"](buttons[i + k]["ID"], buttons[i + k]["Name"])
                        mWhite()
                    end
                    window.write(buttons[i + k].prefixes)
                    window.write(buttons[i + k]["Name"])
                else
                    window.write("")
                end
            else
                local Bn = genNextB(">")
                local Bb = genNextB("<")
                local butChek = (CursY == size[2])
                if curPage == 1 then
                    Bb = genNextB(" ")
                elseif (butChek) and (CursX <= ((size[1] - 3) / 2)) then
                    curPage = curPage - 1
                    mWhite()
                end
                window.write(Bb)
                mBlack()
                window.write(" ")
                if curPage == numPage() then
                    Bn = genNextB(" ")
                elseif (butChek) and (((size[1] - 3) / 2 + 1) < CursX) and ((size[1] - 2) > CursX) then
                    curPage = curPage + 1
                    mWhite()
                end
                window.write(Bn)
                mBlack()
                if (butChek) and (CursX == size[1]) then
                    mWhite()
                    UpdateFunc()
                    --table.insert(buttons, { MyAddress[1], MyAddress[2] })
                end
                window.write(" U")
            end
            window.setCursorPos(1, yC + 1)
            mBlack()
        end
        window.setCursorPos(1, 1)
    end

    local function write(sec) 
        if sec == nil then
            writeMyM()
        else
            timer_id = os.startTimer(sec)
        end
    end 

    local function eventHandler(event)
        --print(event[1])
        if event[1] == "monitor_touch" or event[1] == "mouse_click" then
            CursX = event[3]
            CursY = event[4]
            writeMyM()
            elseif event[1] == "timer"  and event[2]== timer_id then
                CursX = 0
                CursY = 0
                writeMyM()
        end
    end
    return { removeButton = removeButton, clearButton =clearButton, addButton = addButton, write = write, Update = eventHandler, updFunc = UpdFunc, SetPrefix = SetPrefix }
end

local function ModemET()
    local Channel
    --local modem = peripheral.find("modem", function(name, modem5) return modem5.isWireless() end)
    local modem = peripheral.find("modem", function(name, modem5) return true end)
    local OldMesage = {{Type = "", id = 0, Sender = "", Data = ""} }
    local MyName
    local Mesage = { Type = "", id = 0, Sender = "", Data = "" }
    local FuncHandler

    local function MesUtil()
        if #OldMesage > 30 then
           table.remove(OldMesage)
        end
        if Mesage.id > 100 then
            Mesage.id = 1
        end
    end
    local function SetHandler(Handler)
        FuncHandler = Handler
    end
    --local function SetModem(_modem)
    --    modem = _modem
    --end
    local function SetName(_Name)
        if _Name == nil then
            MyName = os.getComputerID()
        else
            MyName = _Name
        end
    end
    local function SetChannel(_Channel)
        if not Channel == nil then
            modem.close(Channel)
        end
        Channel = _Channel
        modem.open(Channel)
    end
    local function tableEater(t)
        if type(t) == "table" then
            for k, v in pairs(t) do
                if type(v) == "table" then
                    print(k .."= table".." <"..type(v)..">")
                    tableEater(v)
                else
                    print(k .. " = " .. v.." <"..type(v)..">")
                end
            end
        else
            print(t.." <"..type(t)..">")
        end
    end
    local function resedMesage(Mesage)
        local t = { Protocol = "MRBL_MET", Mesage = Mesage }
        --tableEater(Mesage)
        modem.transmit(Channel, Channel, t)
    end
    local function makeOld(_Sender, _id, _type)
        local t = {Sender=_Sender,id = _id,Type= _type}
        table.insert(OldMesage, 1, t)
    end
    local function SendMesage(Type, Data)
        --local t = { Protocol = "MRBL_MET" }
        local t = {}
        t.Type = Type
        t.Sender = MyName
        t.Data = Data
        t.id = Mesage.id + 1
        Mesage.id = t.id
        resedMesage(t)
        makeOld(t.Sender,t.id,t.Type)
        MesUtil()
    end
    
    local function IsThisMesageOld(_message,_oldMesage)
        --print("Type "..tostring(_message.Type == _oldMesage.Type).._oldMesage.Type.._message.Type)
        --print("Sender "..tostring(_message.Sender == _oldMesage.Sender).._message.Sender .. _oldMesage.Sender)
        --print("id "..tostring(_message.id == _oldMesage.id).._message.id .. _oldMesage.id)
       return (_message.Type == _oldMesage.Type) and (_message.Sender == _oldMesage.Sender) and (_message.id == _oldMesage.id)
    end
    

    local function IsMesageNew(_message)
        --os.sleep(1)
        --tableEater(_message)
        --tableEater(OldMesage)
        --print(#OldMesage)
        for k, v in pairs(OldMesage) do
            if IsThisMesageOld(v,_message) then
                --print("new mes")
                --print(k)
                --print(v) 
                --makeOld(_message.Sender,_message.id,_message.Type)
                return false
            end
        end
        return true
    end
    local function update(eventData)
        if (eventData[1] == "modem_message" and eventData[3] == Channel) then
            --print(Channel)
            
            if eventData[5].Protocol == "MRBL_MET" then
                --print("Prot")
                --print("test")
                if IsMesageNew(eventData[5].Mesage) then
--print("new mes")
                    --tableEater(eventData[5].Mesage)
                    --print(type( eventData[5].Mesage.Data))
                    --print(not (IsMesageOld(eventData[5].Mesage)))
                    makeOld(eventData[5].Mesage.Sender,eventData[5].Mesage.id,eventData[5].Mesage.Type)
                    resedMesage(eventData[5].Mesage)
                    --tableEater(eventData[5].Mesage)
                    -- OldMesage:insert(1, eventData[5].Mesage)
                    FuncHandler(eventData[5].Mesage.Type, eventData[5].Mesage.Data)
                end
            end
        end
    end

    return {
        SetChannel = SetChannel,
        SetName = SetName,
        Update = update,
        SendMesage = SendMesage,
        --SetModem = SetModem,
        SetHandler = SetHandler
    }
end


return { Display = Display, Command = Command, ModemET = ModemET }
