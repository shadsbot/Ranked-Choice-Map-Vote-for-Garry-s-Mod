print("RCMVChatCMD LOADED IN O7")


maplist = {}
-- Get the maplist
net.Receive("RCMVreqmaps", function()
	maps = net.ReadString()
	print(maps)
	-- Ensure we haven't received the broadcast
	if #maplist < 1 then
		for map in maps:gmatch("%S+") do table.insert(maplist, map) end
	end
end)

-- Get postition to paste this, put it in line with where Maestro puts it
local chatx, chaty = chat.GetChatBoxPos()
chatx = chatx + ScrW() * .08 + 125 -- move it a bit to the side so it's not covered by the HUD
chaty = chaty + ScrH() / 4 + 4

local function closeChat()
	hook.Remove( "HUDPaint", "nominateAC" )
end

function chatComplete(maps, typed)
--	if string.match(typed,"!nom") then
		local matched = {}
		for i=1,#maps do
			if string.sub(maps[i],1,#typed) == typed then
				table.insert(matched,maps[i])
			end
		end 
		--table.sort(matched)
		local returnString = ""
		for i=1,#matched do
			returnString = returnString .. matched[i] .. "\n"
		end
		return returnString
	end
--end

function chatupdate(str)
	-- Only shows up after typing "!nom" to make it play nice with Maestro
	if string.sub(str,1,4) == "!nom" then
		local text = "!nominate map\n!nominate list"
		if string.sub(str,1,10) == "!nominate " then
			sofar = string.sub(str,11)
			if (#sofar > 1) then
				text = chatComplete(maplist,sofar)
			end
		else
			closeChat()
		end
		hook.Add( "HUDPaint", "nominateAC", function()
			draw.DrawText(text,"ChatFont",chatx,chaty, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		end )
	else
		closeChat()
	end
end
function autocomplete(str) 
	if string.match(str,"!nominate") then
		local ret = chatComplete(maplist,string.sub(str,1,11))
		local a = string.sub(str,11)
		local b = chatComplete(maplist,a)
		a = string.find(b,'\n')
		local ret = string.sub(b,1,a)
		return "!nominate " .. ret
	end
end

hook.Add("FinishChat","RCMVchatcomplete",closeChat)
hook.Add("ChatTextChanged","RCMVchatchange",chatupdate)
hook.Add("OnChatTab","RCMVautocomplete", autocomplete)