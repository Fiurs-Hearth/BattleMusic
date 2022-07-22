local _G, _ = _G or getfenv()
local inCombat = false
local lingering = false
local timeLinger

function BattleMusic_OnLoad()
    math.randomseed(time())

    this:SetScript("OnEvent", function()

        if(arg1) then
            if(arg1  == "BattleMusic" and battleMusic == nil) then
                battleMusic={}
                battleMusic.songs=6
                battleMusic.linger=5
            end
            return
        end

        if(inCombat == false) then
            inCombat = true
        else
            inCombat = false
        end

        if(inCombat and lingering == false) then
            isPlayed = PlayMusic("Interface\\AddOns\\BattleMusic\\music\\combat_"..tostring(math.random(1,battleMusic.songs))..".mp3", "music")
        else
            if(battleMusic.linger > 0)then
                lingering = true
                timeLinger = 0

                battleLingerFrame:SetScript("OnUpdate", function()
                
                    timeLinger = timeLinger + arg1
                    if(timeLinger > battleMusic.linger)then
            
                        if(inCombat == false)then
                            lingering = false
                            StopMusic()
                        end
                        this:SetScript("OnUpdate", nil)
                    end
            
                end)
            else
                StopMusic()
            end
        end
    end)
    this:RegisterEvent("ADDON_LOADED")
    this:RegisterEvent("PLAYER_REGEN_DISABLED")
    this:RegisterEvent("PLAYER_REGEN_ENABLED")

    if( not _G['battleLingerFrame'] ) then
		battleLingerFrame = CreateFrame("Frame", "battleLingerFrame", UIParent, nil)
	end

end