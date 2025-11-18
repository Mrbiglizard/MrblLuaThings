local ExampleLib = require "api/ExampleLib"
local NormalBehavior = 1

term.setTextColor(colors.gray)
if fs.exists("ExPr/api/ExampleLib.lua") then
    print("api exist")
    NormalBehavior = NormalBehavior + 1
end
if fs.exists("ExPr/file") then
    print("file exist")
    if ExampleLib.ExampleLib().Test() then
        NormalBehavior = NormalBehavior + 1
        print("Library connected")
    end
    NormalBehavior = NormalBehavior + 1
end
if fs.exists("ExPr/installer.lua") then
    print("installer exist")
    NormalBehavior = NormalBehavior + 1
end

if NormalBehavior == 5 then
    term.setTextColor(colors.green)
    print("All work fine!")
    term.setTextColor(colors.white)
    print("You can delete me, i am do nothing!")
else
    term.setTextColor(colors.red)
    print("Something wrong.")
end
