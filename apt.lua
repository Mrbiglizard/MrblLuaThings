---
--- Based on SirEndii(https://github.com/SirEndii)
--- Rework by Mrbiglizard for Mrbiglizard in 2025
---


local githuburl = "https://raw.githubusercontent.com/Mrbiglizard/MrblLuaThings/refs/heads/main/ProgramList"
local programs = {}
local args = { ... }

local function loadSources()
    term.setTextColor(colors.gray)
    local dl = http.get(githuburl)
    if dl then
        print("Load data from github")
        programs = textutils.unserialise(dl.readAll())
        print(#programs)
        dl.close()
    else
        print("Github not available")
    end
end
local function Confirm(Text)
    print(Text)
    local val = read()
    if val == "y" or val == "Y" then
        return true
    else
        return false
    end
end
local function NowMachFileType(program, type)
    local n = 0
    for k, v in ipairs(programs[program]["files"]) do
        if (v.type == type) then
            n = n + 1
        end
    end
    return n
end
local function IsContainProgram(program)
    local out = false
    for k, v in pairs(programs) do
        out = out or (k == program)
    end
    return out
end
local function IsProgramExist(program)
    if program == "" or program == nil then
        term.setTextColor(colors.yellow)
        print("Pleace write name of program.")
        term.setTextColor(colors.gray)
        print("Use apt ls for show list of program.")
        return false
    end
    if (IsContainProgram(program) == false) then
        term.setTextColor(colors.yellow)
        print("Program '" .. program .. "' does not exists!")
        term.setTextColor(colors.gray)
        print("Use apt ls for show list of program.")
        return false
    end
    return true
end
local function Deletefiles(program, type)
    local isAll = type == "All"
    for k, v in ipairs(programs[program]["files"]) do
        if (v.type == type or isAll) then
            if v.type == "api" then
                fs.delete(programs[program]["path"] .. "/api/" .. v.name)
                print("Delete " .. programs[program]["path"] .. "/api/" .. v.name)
            else
                fs.delete(programs[program]["path"] .. "/" .. v.name)
                print("Delete " .. programs[program]["path"] .. "/" .. v.name)
            end
        end
    end
end
local function Downloadfiles(program, type)
    local isAll = type == "All"
    for k, v in ipairs(programs[program]["files"]) do
        if (v.type == type or isAll) then
            term.setTextColor(colors.gray)
            if v.type == "api" then
                if not fs.exists(programs[program]["path"] .. "/api/" .. v.name) then
                    shell.run("wget " .. v.link .. " " .. programs[program]["path"] .. "/api/" .. v.name)
                    if fs.exists(programs[program]["path"] .. "/api/" .. v.name) then
                        term.setTextColor(colors.lime)
                        print("api download " .. v.name)
                    else
                        term.setTextColor(colors.red)
                        print("Not download " .. v.name)
                    end
                else
                    print(v.name .. " allready exist")
                end
            else
                if not fs.exists(programs[program]["path"] .. "/" .. v.name) then
                    shell.run("wget " .. v.link .. " " .. programs[program]["path"] .. "/" .. v.name)
                    if fs.exists(programs[program]["path"]) then
                        term.setTextColor(colors.lime)
                        print("download " .. v.name)
                    else
                        term.setTextColor(colors.red)
                        print("Not download " .. v.name)
                    end
                else
                    print(v.name .. " allready exist")
                end
            end
        end
    end
end
local function DownloadProgram(program)
    if (not IsProgramExist(program)) then
        error()
    end
    if NowMachFileType(program, "api") > 0 then
        term.setTextColor(colors.yellow)
        print("Downloading library..")
        Downloadfiles(program, "api")
    end

    if NowMachFileType(program, "program") > 0 then
        term.setTextColor(colors.yellow)
        print("Downloading main program..")
        Downloadfiles(program, "program")
    end

    if NowMachFileType(program, "installer") > 0 then
        term.setTextColor(colors.yellow)
        print("Downloading installer..")
        Downloadfiles(program, "installer")
    end

    if NowMachFileType(program, "file") > 0 then
        term.setTextColor(colors.yellow)
        print("Downloading other file and config..")
        Downloadfiles(program, "file")
    end
    term.setTextColor(colors.lime)
    print("Program " .. programs[program]["name"] .. " complited")
    term.setTextColor(colors.white)
end
local function install(program)
    local _curPath = shell.dir()
    shell.setDir("/")
    DownloadProgram(program)
    term.setTextColor(colors.white)
    if shell.run(programs[program].install .. " install") then
        term.setTextColor(colors.lime)
        print("Install complited. Have a nice day")
    else
        term.setTextColor(colors.yellow)
        print("Download complited. Installation not implemented")
    end
    shell.setDir(_curPath)
end
local function showHelp()
    term.setTextColor(colors.lightGray)
    print("---- [Installer] ----")
    term.setTextColor(colors.white)
    print("apt help              - Shows this menu")              --V
    print("apt ls                - Lists all available programs") --V
    print("apt get <program>     - Download programs")            --V
    print("apt install <program> - Install program")              --V
    print("apt update <program>  - Updates program")              --V
    print("apt delete <program>  - Deletes program")              --V
    term.setTextColor(colors.lightGray)
    print("---- [=========] ----")
    term.setTextColor(colors.white)
end
local function DeleteProgram(program)
    if (not IsProgramExist(program)) then
        error()
    end
    if not fs.exists(programs[program].path) then
        term.setTextColor(colors.yellow)
        print("Program " .. programs[program].name .. " not install")
        error()
    end
    term.setTextColor(colors.yellow)
    if Confirm("Are you sure to delete " .. programs[program].name .. " y/n") then
        local _curPath = shell.dir()
        shell.setDir("/")
        if (not shell.run(programs[program].install .. " delete")) then
            term.setTextColor(colors.yellow)
            print("Uninstallation: " .. programs[program].name)
            term.setTextColor(colors.gray)
            print("Deleting files")
            Deletefiles(program, "All")
            if fs.exists(programs[program].path .. "/api") then
                if #fs.list(programs[program].path .. "/api") == 0 then
                    term.setTextColor(colors.gray)
                    print("Deleting folder: " .. programs[program].path .. "/api")
                    fs.delete(programs[program].path .. "/api")
                else
                    term.setTextColor(colors.yellow)
                    print("In " .. programs[program].path .. "/api something is left")
                end
            end
            if #fs.list(programs[program].path) == 0 then
                term.setTextColor(colors.gray)
                print("Deleting folder: " .. programs[program].path)
                fs.delete(programs[program].path)
            else
                term.setTextColor(colors.yellow)
                print("In " .. programs[program].path .. " something is left")
                if Confirm("Are you sure to force delete " .. programs[program].path .. " y/n") then
                    print("Deleting force folder: " .. programs[program].path)
                    fs.delete(programs[program].path)
                end
            end
            term.setTextColor(colors.lime)
            print("Uninstallation: " .. programs[program].name .. " complete")
            shell.setDir(_curPath)
        end
    end
end
local function UpdateProgram(program)
    if (IsProgramExist(program)) then
        local _curPath = shell.dir()
        shell.setDir("/")
        if (not shell.run(programs[program].install .. " update")) then
            term.setTextColor(colors.yellow)
            print("Updating " .. programs[program].name)
            term.setTextColor(colors.gray)
            print("Deleting files")
            Deletefiles(program, "api")
            Deletefiles(program, "program")
            Deletefiles(program, "installer")
        end
        term.setTextColor(colors.gray)
        print("Download " .. programs[program].name)
        DownloadProgram(program)
        print("Update complete!")

        shell.setDir(_curPath)
    end
end
local function showList()
    for name, table in pairs(programs) do
        term.setTextColor(colors.green)
        write(name)
        term.setTextColor(colors.lightGray)
        write(" -- ")
        term.setTextColor(colors.cyan)
        write(table.desc .. "\n")
    end
end
local function executeInput()
    if #args <= 0 then
        showHelp()
    end
    if #args >= 1 and args[1] == "help" then
        showHelp()
    elseif #args >= 1 and args[1] == "ls" then
        showList()
    elseif #args >= 1 and args[1] == "get" then
        DownloadProgram(args[2])
    elseif #args >= 1 and args[1] == "install" then
        install(args[2])
    elseif #args >= 1 and args[1] == "update" then
        UpdateProgram(args[2])
    elseif #args >= 1 and args[1] == "delete" then
        DeleteProgram(args[2])
    elseif #args >= 1 then
        print("Could not find command '" .. args[1] .. "'")
    end
end
local function comp()
    local complete
    local res, completion = pcall(require, "cc.shell.completion")
    if (res) then
        local t = {}
        local n = 0
        for k, v in pairs(programs) do
            n = n + 1
            t[n] = k
        end
        complete = completion.build(
            { completion.choice, { "help", "ls", "get", "install", "update", "delete" } },
            { completion.choice, t }
        )
        shell.setCompletionFunction("apt.lua", complete)
    end
end
loadSources()
comp()
executeInput()
