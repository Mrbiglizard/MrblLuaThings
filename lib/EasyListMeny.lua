
local function writeMyM()
    mon.clear()
    for i = 1, mhight, 1 do
        local xC
        local yC
        xC, yC = mon.getCursorPos()
        if yC < mhight then
            local k = (curPage - 1) * (mhight - 1)
            if i + k <= table.getn(floors) then
                if CursY == i then
                    mWhite()
                    modem.transmit(chanel, chanel, { "LiftAddress", floors[i + k][2] })
                end
                if LCP == LFP and LFP == floors[i + k][2] then
                    mon.write("*")
                elseif floors[i + k][2] == LCP then
                    mon.write("=")
                elseif floors[i + k][2] == LFP then
                    mon.write(">")
                else
                    mon.write(" ")
                end
                mon.write(floors[i + k][1])
            else
                mon.write("")
            end
        else
            local Bn = Bnext
            local Bb = Bback
            local butChek = (CursY == mhight)
            if curPage == 1 then
                Bb = BbackE
            elseif (butChek) and (CursX <= string.len(Bback)) then
                curPage = curPage - 1
                os.queueEvent("monitor_touch", "top", 0, 0)
                mWhite()
            end
            mon.write(Bb)
            mBlack()
            mon.write(" ")
            if curPage == numPage then
                Bn = BnextE
            elseif (butChek) and (string.len(Bb) + 1 < CursX) and (string.len(Bb) + string.len(Bn) + 2 > CursX) then
                curPage = curPage + 1
                os.queueEvent("monitor_touch", "top", 0, 0)
            end
            mon.write(Bn)
            mBlack()
            if (butChek) and (CursX == mwidth) then
                mWhite()
                floors = {}
                table.insert(floors, { MyAddress[1], MyAddress[2] })
                modem.transmit(chanel, chanel, { "MyReset", MyAddress[2] })
                sendMe()
            end
            mon.write(" U")
        end
        mon.setCursorPos(1, yC + 1)
        mBlack()
    end
    mon.setCursorPos(1, 1)
end