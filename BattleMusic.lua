local _G, _ = _G or getfenv()
local inCombat = false
local lingering = false
local timeLinger

-- Settings
local CONFIG_FRAME_NAME = "bmusic_config"
local NR_OF_COLUMNS = 2
local INPUT_HEIGHT = 40
local INPUT_WIDTH = 156
local SPACING_X = 18
local SPACING_Y = 45

function BattleMusic_OnLoad()
    math.randomseed(time())

    this:SetScript("OnEvent", function()

        if(arg1) then
            if(arg1  == "BattleMusic" and battleMusic == nil) then
                battleMusic={}
                battleMusic.songs=6
                battleMusic.linger=5
            end
            CONFIG_SETTINGS_BMUSIC = {
                [1] = {"Number of songs", "bm_songs", battleMusic.songs, 6, "songs"},
                [2] = {"Linger time (seconds) ", "bm_lingerTime", battleMusic.linger, 5, "linger"}
            }
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

local function CreateCheckbox(text, name, column, row, data, isColor)

    local currentEditBox

    if(not _G[CONFIG_FRAME_NAME..name])then
        currentEditBox = CreateFrame("CheckButton", CONFIG_FRAME_NAME.."_"..name, _G[CONFIG_FRAME_NAME], "OptionsCheckButtonTemplate")
    end

    _G[CONFIG_FRAME_NAME.."_"..name.."Text"]:SetText(text)

    currentEditBox:SetPoint(
        "TOPLEFT",
        17 + ((INPUT_WIDTH + SPACING_X) * (column)),
        -20 - (row * SPACING_Y)
    )
    currentEditBox:SetChecked(data)
    currentEditBox:Show()
end

local function SaveData()
    for k,v in pairs(CONFIG_SETTINGS_BMUSIC)do

        local frame = _G[CONFIG_FRAME_NAME.."_"..v[2]]
       
        -- frame is a checkbox  
        if(type(v[4]) == "boolean")then

            local isChecked = frame:GetChecked() or false
            battleMusic[v[5]] = isChecked

        else
            local input_data = frame:GetText()
            if(input_data == "" or input_data == "nil")then
                input_data = nil
            end

            if(v[6])then
                input_data = loadstring("return " .. input_data)()
                battleMusic[v[5]] = input_data
            else
                battleMusic[v[5]] = tonumber(input_data) or input_data
            end
        end
    end

end

local function ResetData()
    for k,v in pairs(CONFIG_SETTINGS_BMUSIC)do

        local frame = _G[CONFIG_FRAME_NAME.."_"..v[2]]

        if( type(v[4]) == "table" ) then
            local table_string = ""
            for kk,vv in pairs(v[4])do
                table_string = table_string .. tostring(vv) .. ", "
            end
            table_string =  string.sub(table_string, 1, -3)
            frame:SetText("{"..table_string.."}")
        elseif(type(v[4]) == "boolean")then

            local isChecked = v[4]
            frame:SetChecked(isChecked)

        else
            frame:SetText(tostring(v[4]))
        end

    end
end


local function CreateInputField(text, name, column, row, data, isColor)
    
    local currentEditBox

    if(not _G[CONFIG_FRAME_NAME..name])then
        currentEditBox = CreateFrame("EditBox", CONFIG_FRAME_NAME.."_"..name, _G[CONFIG_FRAME_NAME], "InputBoxTemplate")
        currentEditBox.text = currentEditBox:CreateFontString("", "OVERLAY");
        currentEditBox:SetScript("OnEnterPressed", function()
          
        end)
    end
    currentEditBox:SetHeight(40)
    currentEditBox:SetWidth(INPUT_WIDTH)
    currentEditBox:SetPoint(
        "TOPLEFT",
        24 + ((INPUT_WIDTH + SPACING_X) * (column)),
        -20 - (row * SPACING_Y)
    )
    currentEditBox:SetAutoFocus(false)
    currentEditBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    currentEditBox.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
    currentEditBox.text:SetPoint("TOPLEFT", -3, 4)
    currentEditBox.text:SetText(text)
    if(type(data) == "table")then
        
        local table_string = ""
        for kk,vv in pairs(data)do
            table_string = table_string .. tostring(vv) .. ", "
        end
        table_string =  string.sub(table_string, 1, -3)
        currentEditBox:SetText("{"..table_string.."}")
        currentEditBox:SetTextColor(unpack(data))
    else
        currentEditBox:SetText(tostring(data))
    end

    currentEditBox:Show()
    currentEditBox.text:Show()

    if(isColor)then
        currentEditBox:SetScript("OnMouseUp", function() 
            CustomColorPicker(currentEditBox)
        end)
    end
end

-- Generate config frame
SLASH_BMUSIC1 = "/bmusic"
SlashCmdList["BMUSIC"] = function(self, txt)
    local config_frame

    -- Create config frame if it doesn't exist
    if(not(_G[CONFIG_FRAME_NAME]))then
        
        local count_settings = 0
        for _ in pairs(CONFIG_SETTINGS_BMUSIC) do
            count_settings = count_settings + 1
        end

        config_frame = CreateFrame("frame", CONFIG_FRAME_NAME, UIParent)
        config_frame:SetWidth((24*2) + (NR_OF_COLUMNS * INPUT_WIDTH) + (SPACING_X * (NR_OF_COLUMNS - 1)))
        config_frame:SetHeight(40 + ((count_settings/NR_OF_COLUMNS) * INPUT_HEIGHT) + (INPUT_HEIGHT + SPACING_Y))
        config_frame:SetPoint("CENTER", 0, 0)
        config_frame:EnableMouse(true)
        config_frame:SetMovable(true)
        config_frame:RegisterForDrag("LeftButton")
        config_frame:SetScript("OnDragStart", function()
            this:StartMoving()
        end)
        config_frame:SetScript("OnDragStop", function()
            this:StopMovingOrSizing()
        end)

        config_frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            edgeSize = 24,
            insets={left=8, right=8, top=8, bottom=8}
        })
        config_frame:SetBackdropColor(
            0.4,
            0.4,
            0.4
        )

        local close_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_close_button", config_frame, "UIPanelCloseButton")
        close_button:SetPoint("TOPRIGHT", 7, 7)

        local save_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_save_button", config_frame, "OptionsButtonTemplate")
        save_button:SetPoint("BOTTOMRIGHT", -15, 14)
        save_button:SetText("Save")
        save_button:SetScript("OnClick", function()
            SaveData()
        end)

        local reset_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_reset_button", config_frame, "OptionsButtonTemplate")
        reset_button:SetPoint("BOTTOMLEFT", 15, 14)
        reset_button:SetText("Reset")
        reset_button:SetScript("OnClick", function()
            ResetData()
        end)

        local reload_button = CreateFrame("Button", CONFIG_FRAME_NAME.."_reload_button", config_frame, "OptionsButtonTemplate")
        reload_button:SetPoint("BOTTOMLEFT", 115, 14)
        reload_button:SetText("Reload UI")
        reload_button:SetScript("OnClick", function()
            ReloadUI()
        end)

        local column, row = 0, 0

        for k,v in pairs(CONFIG_SETTINGS_BMUSIC) do
            
            if(type(v[4]) == "boolean") then
                CreateCheckbox(v[1], v[2], column, row, v[3], v[6])
            else
                CreateInputField(v[1], v[2], column, row, v[3], v[6])
            end

            if(column > (NR_OF_COLUMNS - 2))then
                column = 0
                row = row + 1
            else
                column = column + 1
            end
        end

    else
        _G[CONFIG_FRAME_NAME]:Show()
    end

end
