function checkPlayerNomination(ply,text,team)
    dbg("Nomination has been called with text: " .. text)
    if (string.sub(text, 0, 9) == "!nominate") then
        text = string.sub(text,11,#text)
        -- The sent string only contains "!nominate"
        if (#text == 0) then 
            timer.Create("respondNominateChat", (1/30), 1, function()
                ply:PrintMessage(HUD_PRINTTALK, "!nominate <map> : Adds a map to the mapvote queue")
            end )
        end
        -- The command "!nominate list" was invoked
        if (text == "list") then
            timer.Create("respondNominateChatList", (1/30), 1, function()
                if (#approvedNominations > 0) then
                        ply:PrintMessage(HUD_PRINTTALK, "Nominated maps:")
                    for i=1,#approvedNominations do
                        ply:PrintMessage(HUD_PRINTTALK, approvedNominations[i])
                    end
                else
                    ply:PrintMessage(HUD_PRINTTALK, "No maps have been nominated yet! Why not add one?")
                end
            end )
            return
        end

        local function mapIsValid(map)
            dbg("checking validity of " .. map .. ".")
            -- if map is available
            dbg(usableMaps)
            if tableContains(usableMaps,map) then  
                dbg("checking validity")
                -- if map is not duplicate
                if not tableContains(approvedNominations, map) then 
                    if determineMapRatioLegal(map) then
                        return true
                    end
                end
            end
            return false
        end

        if (#approvedNominations < getMaxNominations()) then 
            if mapIsValid(text) then 
                table.insert(approvedNominations,text)
                net.Start("RCMVchat")
                message = {}
                message.Nick, message.Text = ply:Nick(), text
                net.WriteTable(message)
                net.Broadcast()
            else
                if not tableContains(usableMaps,text) then
                    timer.Create("invalidMapResponse", (1/30), 1, function()
                        ply:PrintMessage(HUD_PRINTTALK, text .. " is not a valid map.")
                    end)
                end
                if tableContains(approvedNominations,text) then
                    timer.Create("invalidMapResponse", (1/30), 1, function()
                        ply:PrintMessage(HUD_PRINTTALK, text .. " was already nominated!")
                    end)
                end
                local err,msg = determineMapRatioLegal(text)
                if not err then 
                    timer.Create("invalidMapResponse", (1/30), 1, function()
                        ply:PrintMessage(HUD_PRINTTALK, text .. " was not nominated because " .. msg)
                    end)
                end
            end
        else
            timer.Create("invalidMapResponse", (1/30), 1, function()
                ply:PrintMessage(HUD_PRINTTALK, "All nomination slots have been filled!")
            end)
        end
    end
end