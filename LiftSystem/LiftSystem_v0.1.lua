local mon = peripheral.find("monitor")
local modem
local chanel = 44
local mhight
local mwidth
local floors = {}
local curPage = 1
local numPage = 1
local Bnext=""
local Bback=""
local BnextE=""
local BbackE=""
local isControler = true
local CursX, CursY
local LFP=0
local LCP=0
local OldMessage= {}
local CMessage
local MyAddress ={"X1",1} 
local myArg = {...}
local timerRid
local timerSid
 
function main()
while true do
    local eventData = {os.pullEvent()}
    local event = eventData[1]    
    if event == "modem_message" then
        CMessage = eventData[5]       
        if OldHandler() then          
            MesHandler()          
            modem.transmit(chanel,chanel,CMessage)
        end
    end
    if event == "monitor_touch" then 
        CursX = eventData[3]
        CursY = eventData[4]
        writeMyM()
    end
    if event == "redstone" then
        RedSender()
    end
    if event == "timer" then
        if eventData[2] == timerRid then
        os.reboot()
        end
        if eventData[2] == timerSid then
        sendMe()
        end
    print(eventData[2])
    OldMessage = {{0,0},{0,0},{0,0,0},{0,0}}
    end
end
end

function OldHandler()
local OutBul = false
if CMessage[1] == "LiftPos" then
    if not (CMessage[2]==OldMessage[1]) then 
        OldMessage[1] = CMessage[2]
        OutBul = true
    end
end
if CMessage[1] == "LiftAddress" then
    if not (CMessage[2] == OldMessage[2]) then
        OldMessage[2] = CMessage[2]
        OutBul =true
    end
end
if CMessage[1] == "AllFloor" then
    OutBul = true
    for p=1, table.getn(floors),1 do
        if CMessage[3]==floors[p][2] then
        --print(CMessage[3])
            OutBul = false
        end        
    end
end
if CMessage[1] == "MyReset" then
    if not(CMessage[2] == OldMessage[4]) then
        OldMessage[4] = CMessage[2]
        OutBul = true
    end
end
return OutBul
end

function RedHandler()
if isControler then
    if LFP<LCP then
        redstone.setOutput("right",true)
        redstone.setOutput("left",false)
    elseif LFP>LCP then
        redstone.setOutput("right",false)
        redstone.setOutput("left",false)
    else 
        redstone.setOutput("left",true)
    end
else  
    if LFP == MyAddress[2] then
        redstone.setOutput("left",false)
    else
    redstone.setOutput("left",true)
    end
end
end

function RedSender()
if not isControler then
    if redstone.getInput("right") then
        modem.transmit(chanel,chanel,{"LiftPos",MyAddress[2]})
    end
end
end

function MesHandler()
if CMessage[1] == "LiftPos" then
    LCP = CMessage[2] 
    RedHandler()
    print("Lift arrive to "..LCP)
    if not isControler then
        CursX=0
        CursY=0
        writeMyM() 
    end 
end
if CMessage[1]=="LiftAddress"then
    LFP = CMessage[2]
    RedHandler()
end
if (CMessage[1]=="AllFloor" and not isControler) then
    local minVal=0
    for p=1, table.getn(floors),1 do        
        if (CMessage[3]==floors[p][2]) then
           minVal=-1
            break 
        end
        if not (minVal==-1) then
            if CMessage[3] < floors[p][2] then
                minVal = p            
            end
        end
    end
    if not(minVal==-1) then
        table.insert(floors, minVal+1, {CMessage[2],CMessage[3]})
    if not isControler then
        clMon()
    end
    end
end
if (CMessage[1]=="MyReset") then
    if not isControler then
        sendMe()
        RedSender()
        timerRid = os.startTimer(5)  
    end
end
end

function Ini()
print("Mrbiglizard's lift system V 1.1")
write("started at "..textutils.formatTime(os.time("local"),true))
print(" ".. os.date("%A %d %B %Y"))
OldMessage ={{0,0},{0,0},{0,0,0},{0,0}}
if not (myArg[1] == nil) then
    MyAddress[1]= myArg[1]
    MyAddress[2]= tonumber(myArg[2])
    chanel =tonumber(myArg[3])
    print("With address:"..myArg[1].." "..myArg[2].." on chanel "..myArg[3])
else
    print("With no argument")
end
table.insert(floors,{MyAddress[1],MyAddress[2]})
modemIni()
if not (mon==nil) then
    isControler = false 
    monitorIni()  
    RedSender()
    print("i'm station")
end
end

function modemIni()
local Imod = {peripheral.find("modem",function(name,modem)
return modem.isWireless()
end)}
modem = Imod[1]
modem.open(chanel)
sendMe()
end

function sendMe()
if isControler then
else
    modem.transmit(chanel,chanel,{"AllFloor",MyAddress[1],MyAddress[2]})
end
end
 
function monitorIni()
mon.setCursorPos(1,1)
mon.setTextColor(colors.white)
mon.setBackgroundColor(colors.black)
mwidth, mhight = mon.getSize()
mon.clear()
local k = (mwidth-3)/2
for i=1,k,1 do
    Bback = "<"..tostring(Bback)
    BbackE = " "..BbackE
end
k=mwidth-3-string.len(Bback)
for i=1,k,1 do
    Bnext = ">"..Bnext
    BnextE = " "..BnextE
end
clMon()
writeMyM()
end

function clMon()
numPage = math.floor(table.getn(floors)/(mhight-1)+0.99)
CursX=0
CursY=0
end

function writeMyM()
mon.clear()
for i=1, mhight, 1 do
    local xC  
    local yC 
    xC, yC = mon.getCursorPos()
    if yC < mhight then
        local k = (curPage-1)*(mhight-1)
        if i+k<=table.getn(floors) then
            if CursY == i then
               mWhite()
               modem.transmit(chanel,chanel,{"LiftAddress",floors[i+k][2]})
            end
            if LCP==LFP and LFP == floors[i+k][2] then
                mon.write("*")
            elseif floors[i+k][2]==LCP then
                mon.write("=")
            elseif floors[i+k][2]==LFP then
                mon.write(">")
            else
                mon.write(" ")
            end
            mon.write(floors[i+k][1])
        else
            mon.write("")
        end
    else
        local Bn = Bnext
        local Bb = Bback
        local butChek = (CursY == mhight)
        if curPage == 1 then         
            Bb=BbackE
        elseif (butChek) and (CursX <= string.len(Bback)) then
            curPage = curPage-1
            os.queueEvent("monitor_touch","top",0,0)
            mWhite()             
        end
        mon.write(Bb)
        mBlack()
        mon.write(" ")
        if curPage == numPage then
            Bn = BnextE            
        elseif (butChek) and (string.len(Bb)+1<CursX) and (string.len(Bb)+string.len(Bn)+2>CursX) then
            curPage = curPage+1
            os.queueEvent("monitor_touch","top",0,0)
        end
        mon. write(Bn)
        mBlack()            
        if (butChek) and (CursX==mwidth) then
            mWhite()
            floors = {}
            table.insert(floors,{MyAddress[1],MyAddress[2]})
            modem.transmit(chanel,chanel,{"MyReset",MyAddress[2]})
            sendMe()
        end
        mon.write(" U")           
    end 
    mon.setCursorPos(1 ,yC+1 )
    mBlack()
end
mon.setCursorPos(1,1)
end

function mWhite()
mon.setBackgroundColor(colors.white)
mon.setTextColor(colors.black)
end

function mBlack()
mon.setBackgroundColor(colors.black)
mon.setTextColor(colors.white)
end

--StartFromHere--
Ini()
timerSid = os.startTimer(2)
main()

