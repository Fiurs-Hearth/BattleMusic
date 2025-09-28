local function print(string)
    ChatFrame1:AddMessage(string)
end

-- =====================================================
-- BattleMusic Addon
-- =====================================================
local _G, _ = _G or getfenv()
local rows = {}

local function BM_ValidateLevelRangeInput(editBox)
    local text = editBox:GetText()

    if not text or text == "" then
        return
    end

    -- allow: digits only
    if string.find(text, "^[0-9]+$") then
        return
    end

    -- allow: digits-digits (any numbers)
    if string.find(text, "^[0-9]+%-[0-9]*$") then
        return
    end

    -- otherwise: strip invalid characters
    local cleaned = string.gsub(text, "[^0-9%-]", "")
    -- remove extra dashes (keep only first one)
    local dashPos = string.find(cleaned, "%-")
    if dashPos then
        local before = string.sub(cleaned, 1, dashPos)
        local after  = string.gsub(string.sub(cleaned, dashPos + 1), "%-", "")
        cleaned = before .. after
    end

    editBox:SetText(cleaned)
end


local function WhereAmI()
    local zone = GetZoneText()
    ChatFrame1:AddMessage("You are in: "..zone)
end

-- =====================================================
-- Main Config Frame
-- =====================================================
local f = CreateFrame("Frame", "BattleMusicFrame", UIParent)
f:SetWidth(1240)
f:SetHeight(400)
f:SetPoint("CENTER", 0, 0)
f:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0.5,0.5,0.5, 1)
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", function() this:StartMoving() end)
f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
f:RegisterEvent("VARIABLES_LOADED")
f:Hide()

-- Title
local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("BattleMusic Config")

-- =====================================================
-- Data frame
-- =====================================================
local df = CreateFrame("Frame", "BattleMusicDataFrame", UIParent)
local stf = CreateFrame("Frame", "BattleMusicSongTimeFrame", UIParent)

-- =====================================================
-- Help / Info Button
-- =====================================================
local helpBtn = CreateFrame("Button", nil, BattleMusicFrame)
helpBtn:SetWidth(50)
helpBtn:SetHeight(50)
helpBtn:SetPoint("TOPRIGHT", BattleMusicFrame, "TOPRIGHT", -22, -20)

-- use the "?" icon (Interface\\Buttons has one)
helpBtn:SetNormalTexture("Interface\\TUTORIALFRAME\\TutorialFrame-QuestionMark")
helpBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

helpBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:AddLine("BattleMusic", 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "This addon lets you manage custom battle music tracks.\n\n"
        .."• Linger time: How long in seconds the music will play when leaving combat.\n\n"
        .."• Randomize next track: Randomize tracks or when disabled, plays songs in order.\n\n\n"
        .."• Disabled: Will ignore the song when checked.\n\n"
        .."• Song: Path to the song (from the music folder), don't forget to add the file format at the end (.mp3 or .wav).\n\n"
        .."• Length: Song duration in seconds, is used to change song after set seconds, leave at 0 to loop song.\n\n"
        .."• Elite: If song should only be played while fighting elites.\n\n"
        .."• Boss: If song should only be played while fighting skull level.\n\n"
        .."• Zone: Restrict song to specific zone.\n\n"
        .."• Level range: Restrict song to specific mob level range.\n\n"
        .."• X: Remove song.\n\n"
        .."Use Save to store changes, Clear will automatically save.", 0.9, 0.9, 0.9, 1)
    GameTooltip:Show()
end)

helpBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- =====================================================
-- Linger Time Input
-- =====================================================
local lingerLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
lingerLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -50)
lingerLabel:SetText("Linger Time (seconds)")

local lingerInput = CreateFrame("EditBox", "BattleMusicLingerInput", f, "InputBoxTemplate")
lingerInput:SetWidth(100)
lingerInput:SetHeight(20)
lingerInput:SetPoint("TOPLEFT", lingerLabel, "BOTTOMLEFT", 0, -4)
lingerInput:SetAutoFocus(false)

-- =====================================================
-- Randomize Checkbox
-- =====================================================
local randomizeCheck = CreateFrame("CheckButton", "BattleMusicRandomizeCheck", f, "UICheckButtonTemplate")
randomizeCheck:SetPoint("LEFT", lingerInput, "RIGHT", 40, 0)

local randomizeLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
randomizeLabel:SetPoint("LEFT", randomizeCheck, "RIGHT", 4, 0)
randomizeLabel:SetText("Randomize next track")

-- =====================================================
-- ScrollFrame
-- =====================================================
local scrollFrame = CreateFrame("ScrollFrame", "BattleMusicSongListScroll", f)
scrollFrame:SetWidth(1195)
scrollFrame:SetHeight(240)
scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -110)
scrollFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeSize = 2,
})
scrollFrame:SetBackdropColor(0.85, 0.75 ,0.5, 1)
scrollFrame:SetBackdropBorderColor(0,0,0, 1)

local scrollChild = CreateFrame("Frame", "BattleMusicSongListScrollChild", scrollFrame)
scrollChild:SetWidth(520)
scrollChild:SetHeight(400)
scrollFrame:SetScrollChild(scrollChild)

local scrollbar = CreateFrame("Slider", "BattleMusicSongListScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -16)
scrollbar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 16)
scrollbar:SetMinMaxValues(0, 400)
scrollbar:SetValueStep(20)
scrollbar:SetValue(0)
scrollbar:SetWidth(16)
scrollbar:SetScript("OnValueChanged", function()
    scrollFrame:SetVerticalScroll(this:GetValue())
end)

-- Enable mouse scrolling
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function()
    local current = BattleMusicSongListScrollBar:GetValue()
    local step = 20 -- pixels per wheel notch
    if arg1 > 0 then
        -- scroll up
        BattleMusicSongListScrollBar:SetValue(current - step)
    elseif arg1 < 0 then
        -- scroll down
        BattleMusicSongListScrollBar:SetValue(current + step)
    end
end)

-- =====================================================
-- + Add Song Button inside scrollframe
-- =====================================================
local addSongBtn = CreateFrame("Button", "BattleMusicAddSongButton", scrollChild, "UIPanelButtonTemplate")
addSongBtn:SetWidth(24)
addSongBtn:SetHeight(24)
addSongBtn:SetText("+")

-- Fix for Editbox layering issue with scrollframe
local function EditboxFix(editbox)

    local name = editbox:GetName()

    _G[name.."Left"]:SetTexture("")
    _G[name.."Middle"]:SetTexture("")
    _G[name.."Right"]:SetTexture("")
    editbox:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        insets = {
        left = -2,
        right = -2,
        top = 0,
        bottom = 0,
        }
    })

end

-- =====================================================
-- + Button positioning
-- =====================================================
local function UpdateScrollRange()
    local viewHeight = scrollFrame:GetHeight()
    local row_sum = table.getn(rows)*24

    if (row_sum + 25) > viewHeight then
        BattleMusicSongListScrollBar:SetMinMaxValues(0, row_sum - 8)
    else
        BattleMusicSongListScrollBar:SetMinMaxValues(0, 0)
        BattleMusicSongListScrollBar:SetValue(0)
    end
end

-- Reposition rows + button
local function PositionRows()
    local y = -4
    for i, row in ipairs(rows) do
        if row:IsShown() and not row.markedForRemoval then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, y)
            y = y - row:GetHeight() - 4
        end
    end
    addSongBtn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 8, y - 3)

    -- expand scrollChild height so all rows fit
    local totalHeight = -y + 30
    if totalHeight < 256 then totalHeight = 256 end -- minimum height
    scrollChild:SetHeight(totalHeight)
    UpdateScrollRange()
end

-- =====================================================
-- Song Row Creator
-- =====================================================
local function CreateSongRow(parent, index)
    local row = CreateFrame("Frame", "BattleMusicRow"..index, parent)
    row:SetWidth(1195)
    row:SetHeight(24)

    local disableLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    disableLabel:SetPoint("LEFT", row, "LEFT", 4, -2)
    disableLabel:SetText("Disabled:")

    row.disable = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.disable:SetPoint("LEFT", disableLabel, "RIGHT", 4, 0)

    local nameLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameLabel:SetPoint("LEFT", row.disable, "RIGHT", 4, 0)
    nameLabel:SetText("Song:")

    row.name = CreateFrame("EditBox", "bm_editbox_name_"..index, row, "InputBoxTemplate")
    row.name:SetWidth(280)
    row.name:SetHeight(20)
    row.name:SetPoint("LEFT", nameLabel, "RIGHT", 7, 0)
    row.name:SetAutoFocus(false)
    EditboxFix(row.name)

    local lenLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lenLabel:SetPoint("LEFT", row.name, "RIGHT", 6, 0)
    lenLabel:SetText("Length:")

    row.length = CreateFrame("EditBox", "bm_editbox_length_"..index, row, "InputBoxTemplate")
    row.length:SetWidth(40)
    row.length:SetHeight(20)
    row.length:SetPoint("LEFT", lenLabel, "RIGHT", 6, 0)
    row.length:SetAutoFocus(false)
    EditboxFix(row.length)

    row.elite = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.elite:SetPoint("LEFT", row.length, "RIGHT", 40, 0)
    local eliteLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    eliteLabel:SetPoint("LEFT", row.elite, "RIGHT", 2, 0)
    eliteLabel:SetText("Elite")

    row.boss = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.boss:SetPoint("LEFT", eliteLabel, "RIGHT", 40, 0)
    local bossLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bossLabel:SetPoint("LEFT", row.boss, "RIGHT", 2, 0)
    bossLabel:SetText("Boss")

    local zoneLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zoneLabel:SetPoint("LEFT", bossLabel, "RIGHT", 20, 0)
    zoneLabel:SetText("Zone:")

    row.zone = CreateFrame("EditBox", "bm_editbox_zone_"..index, row, "InputBoxTemplate")
    row.zone:SetWidth(240)
    row.zone:SetHeight(20)
    row.zone:SetPoint("LEFT", zoneLabel, "RIGHT", 7, 0)
    row.zone:SetAutoFocus(false)
    EditboxFix(row.zone)

    local levelLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelLabel:SetPoint("LEFT", row.zone, "RIGHT", 12, 0)
    levelLabel:SetText("Level range:")

    row.levelRange = CreateFrame("EditBox", "bm_editbox_levelRange_"..index, row, "InputBoxTemplate")
    row.levelRange:SetWidth(60)
    row.levelRange:SetHeight(20)
    row.levelRange:SetPoint("LEFT", levelLabel, "RIGHT", 7, 0)
    row.levelRange:SetAutoFocus(false)
    row.levelRange:SetScript("OnChar", function()
        BM_ValidateLevelRangeInput(this)
    end)
    EditboxFix(row.levelRange)

    -- Remove button
    row.removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    row.removeBtn:SetWidth(20)
    row.removeBtn:SetHeight(20)
    row.removeBtn:SetText("x")
    row.removeBtn:SetPoint("LEFT", row.levelRange, "RIGHT", 14, 0)

    row.removeBtn:SetScript("OnClick", function()
        -- mark but don’t delete yet
        row.markedForRemoval = true
        row:Hide()
        -- re-position remaining rows visually
        PositionRows()
    end)

    return row
end

-- Add a new empty row
local function AddSongRow(data)
    local i = table.getn(rows) + 1
    local row = CreateSongRow(scrollChild, i)

    local s = data or {}
    row.disable:SetChecked(s.disabled)
    row.name:SetText(s.name or "")
    row.length:SetText(s.length or "")
    row.elite:SetChecked(s.elite)
    row.boss:SetChecked(s.boss)
    row.zone:SetText(s.zone or "")
    row.levelRange:SetText(s.levelRange or "")

    row:Show()
    rows[i] = row
    PositionRows()
end

-- Hook up + button
addSongBtn:SetScript("OnClick", function()
    AddSongRow()
end)

-- =====================================================
-- ScrollFrame Content
-- =====================================================
local function RefreshSongList()
    -- hide existing rows but don't wipe the table
    for i=1, table.getn(rows) do rows[i]:Hide() end

    if(type(battleMusic.songs) == "number" or table.getn(battleMusic.songs) == nil)then
        battleMusic.songs = {}
        return
    end

    -- rebuild from saved songs
    for i=1, table.getn(battleMusic.songs) do
        if not rows[i] then
            rows[i] = CreateSongRow(scrollChild, i)
        end
        local row = rows[i]

        local s = battleMusic.songs[i]
        row.disable:SetChecked(s.disabled)
        row.name:SetText(s.name or "")
        row.length:SetText(s.length or "")
        row.elite:SetChecked(s.elite)
        row.boss:SetChecked(s.boss)
        row.zone:SetText(s.zone or "")
        row.levelRange:SetText(s.levelRange or "")

        row:Show()
    end
    
    PositionRows()
end

-- =====================================================
-- Save + Reset
-- =====================================================
local saveBtn = CreateFrame("Button", "BattleMusicSaveButton", f, "UIPanelButtonTemplate")
saveBtn:SetWidth(100)
saveBtn:SetHeight(24)
saveBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 20)
saveBtn:SetText("Save")
saveBtn:SetScript("OnClick", function()
    battleMusic.lingerTime = tonumber(lingerInput:GetText()) or 5
    battleMusic.randomize = randomizeCheck:GetChecked() and true or false

    local newSongs = {}
    for i, row in ipairs(rows) do

        if not row.markedForRemoval then
            table.insert(newSongs, {
                disabled   = row.disable:GetChecked(),
                name       = row.name:GetText(),
                length     = row.length:GetText(),
                elite      = row.elite:GetChecked(),
                boss       = row.boss:GetChecked(),
                zone       = row.zone:GetText(),
                levelRange = row.levelRange:GetText(),
            })
        end
        
    end
    battleMusic.songs = newSongs
end)

local resetBtn = CreateFrame("Button", "BattleMusicResetButton", f, "UIPanelButtonTemplate")
resetBtn:SetWidth(130)
resetBtn:SetHeight(24)
resetBtn:SetPoint("RIGHT", saveBtn, "LEFT", -10, 0)
resetBtn:SetText("Clear and Save")
-- =====================================================
-- Reset Button (double-click protection)
-- =====================================================
local lastResetClick = 0
local resetConfirmTimeout = 2 -- seconds

resetBtn:SetScript("OnClick", function()
    local now = GetTime()
    if (now - lastResetClick) < resetConfirmTimeout then
        -- double click detected -> really reset
        battleMusic.songs = {}
        for _, row in ipairs(rows) do
            row.markedForRemoval = false
            row:Show()
        end
        RefreshSongList()

        print("|cffff0000BattleMusic:|r All rows have been reset.")
        lastResetClick = 0
        resetBtn:SetText("Reset")
    else
        -- first click, warn user
        print("|cffff0000BattleMusic:|r Click again to confirm reset.")
        resetBtn:SetText("Confirm")
        lastResetClick = now
    end
end)

-- =====================================================
-- Where Am I? Button
-- =====================================================
local whereAmIbtn = CreateFrame("Button", "BattleMusicWhereAmIButton", f, "UIPanelButtonTemplate")
whereAmIbtn:SetWidth(100)
whereAmIbtn:SetHeight(24)
whereAmIbtn:SetPoint("BOTTOMLEFT", BattleMusicFrame, "BOTTOMLEFT", 20, 20)
whereAmIbtn:SetText("Where am I?")
whereAmIbtn:SetScript("OnClick", function()
    WhereAmI()
end)

-- =====================================================
-- Close Button
-- =====================================================
local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
closeBtn:SetScript("OnClick", function()
    BattleMusicFrame:Hide()
end)

-- =====================================================
-- OnShow Init
-- =====================================================
f:SetScript("OnShow", function()
    lingerInput:SetText(battleMusic.lingerTime)
    randomizeCheck:SetChecked(battleMusic.randomize)
    RefreshSongList()
end)

-- =====================================================
-- Slash Command
-- =====================================================
SLASH_BATTLEMUSIC1 = "/bmusic"
SlashCmdList["BATTLEMUSIC"] = function()
    if BattleMusicFrame:IsShown() then
        BattleMusicFrame:Hide()
    else
        BattleMusicFrame:Show()
    end
end

-- =====================================================
-- Logic
-- =====================================================

local function BM_CheckUnitClassificationPresent()
    -- Check if Unit is elite/rareelite or boss
    local function checkClassification(unit)
        if UnitExists(unit) then
            local c = UnitClassification(unit)
            if c == "elite" or c == "rareelite" or c == "worldboss" then
                if(c == "elite" or c == "rareelite")then
                    return "elite"
                else
                    return "worldboss"
                end
            end
        end
        return false
    end
    -- Check your target
    if checkClassification("target") then return checkClassification("target") end
    -- Check your target's target
    if checkClassification("targettarget") then return checkClassification("targettarget") end

    -- check party members' targets and their target's target
    if GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            if checkClassification("party"..i.."target") then
                return checkClassification("party"..i.."target")
            end
            if checkClassification("party"..i.."targettarget") then
                return checkClassification("party"..i.."targettarget")
            end
        end
    end

    -- check raid members' targets and their target's target
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            if checkClassification("raid"..i.."target") then
                return checkClassification("raid"..i.."target")
            end
            if checkClassification("raid"..i.."targettarget") then
                return checkClassification("raid"..i.."targettarget")
            end
        end
    end

    return false

end

local function BM_CheckUnitLevel()
    -- Check if Unit is elite/rareelite or boss
    local function checkLevel(unit)
        if UnitExists(unit) then
            local level = UnitLevel(unit)
            return level
        end
        return false
    end
    -- Check your target
    if checkLevel("target") then return checkLevel("target") end
    -- Check your target's target
    if checkLevel("targettarget") then return checkLevel("targettarget") end

    -- check party members' targets and their target's target
    if GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            if checkLevel("party"..i.."target") then
                return checkLevel("party"..i.."target")
            end
            if checkLevel("party"..i.."targettarget") then
                return checkLevel("party"..i.."targettarget")
            end
        end
    end

    -- check raid members' targets and their target's target
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            if checkLevel("raid"..i.."target") then
                return checkLevel("raid"..i.."target")
            end
            if checkLevel("raid"..i.."targettarget") then
                return checkLevel("raid"..i.."targettarget")
            end
        end
    end

    return false

end

-- Parse text into low, high
local function BM_ParseLevelRange(text)
    if not text or text == "" then
        return nil, nil
    end

    local dashPos = string.find(text, "%-")
    if dashPos then
        local lowStr  = string.sub(text, 1, dashPos - 1)
        local highStr = string.sub(text, dashPos + 1)

        local low  = tonumber(lowStr)
        local high = tonumber(highStr)
        return low, high
    else
        -- single number
        local low = tonumber(text)
        return low, low
    end
end


local function FilterSongs()

    local zone_name = GetZoneText()
    local filtered_songs = {}

    for i, row in ipairs(battleMusic.songs) do
        -- Skip if marked for removal, no path, or disabled

        if(not row.markedForRemoval and not row.disabled and row.name and row.name ~= "" ) then

            local b_addSong = true
            -- Check if zone check is enabled and name is correct
            if(row.zone and row.zone ~= "" and row.zone ~= zone_name) then
                b_addSong = false
            end

            if(row.elite and not row.boss and BM_CheckUnitClassificationPresent() ~= "elite")then
                b_addSong = false
            end

            if(row.boss and not row.elite and BM_CheckUnitClassificationPresent() ~= "worldboss")then
                b_addSong = false
            end

            if(row.boss and row.elite and not (BM_CheckUnitClassificationPresent() == "elite" or BM_CheckUnitClassificationPresent() == "worldboss"))then
                b_addSong = false
            end

            -- Check level range
            if(row.levelRange and row.levelRange ~= "")then

                local unit_level = BM_CheckUnitLevel()
                local level_range_min, level_range_max = BM_ParseLevelRange(row.levelRange)

                if(unit_level == false or unit_level < level_range_min or unit_level > level_range_max)then
                    b_addSong = false
                end

            end

            -- Add if it passed the filter
            if(b_addSong == true)then
                table.insert(filtered_songs, row)
            end
        end

    end

    return filtered_songs
end

-- =====================================================
-- Collect songs from UI rows
-- =====================================================

local function PlayTrack()

    -- Filtered Songs
    local songs = FilterSongs()
    local size = table.getn(songs)

    if(size == 0 or size == nil)then
        return
    end

    if(not(battleMusic.currentSong))then
        battleMusic.currentSong = 0
    end

    if(battleMusic.randomize)then
        math.randomseed(math.floor(GetTime() * 1000)) -- used for randomizing songs
        battleMusic.currentSong = math.random(1, size)
    else
        battleMusic.currentSong = battleMusic.currentSong + 1
        if(battleMusic.currentSong > size)then
            battleMusic.currentSong = 1
        end
    end

    local song = songs[battleMusic.currentSong]

    if(not BattleMusicFrame.lingering)then
        PlayMusic("Interface\\AddOns\\BattleMusic\\music\\".. song.name, "music")

        if(song.length ~= "" and tonumber(song.length) > 0) then
            BattleMusicSongTimeFrame.time = 0
            BattleMusicSongTimeFrame.maxTime = tonumber(song.length)
            BattleMusicSongTimeFrame:SetScript("OnUpdate", function()
                BattleMusicSongTimeFrame.time = BattleMusicSongTimeFrame.time + arg1

                if(BattleMusicDataFrame.lingering)then

                    local time_left = BattleMusicSongTimeFrame.maxTime - BattleMusicSongTimeFrame.time
                    -- don't start a new song near end of song
                    if(time_left < battleMusic.lingerTime)then
                        if(BattleMusicSongTimeFrame.time > BattleMusicSongTimeFrame.maxTime)then
                            StopMusic()
                            BattleMusicSongTimeFrame:SetScript("OnUpdate", nil)
                        end

                    end
                
                -- song length ended, change song
                elseif(BattleMusicSongTimeFrame.time > BattleMusicSongTimeFrame.maxTime)then
                    BattleMusicSongTimeFrame:SetScript("OnUpdate", nil)
                    PlayTrack()
                end
            end)
        end
    end
end

f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

f:SetScript("OnEvent", function() 
    if event == "VARIABLES_LOADED" then

        if not battleMusic then
            battleMusic = {
                lingerTime = 5,
                randomize = true,
                songs = {}
            }
        end
        RefreshSongList()

    -- TODO: Generate Readme for git
    -- TODO: Upload to git

    -- We enter combat
    elseif event == "PLAYER_REGEN_DISABLED" then

        if(BattleMusicDataFrame.lingering ~= true)then
            PlayTrack()
        else
            -- stop the linger from cancelling the song, we entered combat before the time ended
            BattleMusicDataFrame:SetScript("OnUpdate", nil)
            BattleMusicDataFrame.lingering = false
        end

    -- We leave combat
    elseif("PLAYER_REGEN_ENABLED")then

        if(battleMusic.lingerTime and tonumber(battleMusic.lingerTime) > 0)then

            BattleMusicDataFrame.lingering = true
            BattleMusicDataFrame.timeLinger = 0

            BattleMusicDataFrame:SetScript("OnUpdate", function()

                BattleMusicDataFrame.timeLinger = BattleMusicDataFrame.timeLinger + arg1

                if (BattleMusicDataFrame.timeLinger > battleMusic.lingerTime) then
                    BattleMusicDataFrame:SetScript("OnUpdate", nil)
                    BattleMusicSongTimeFrame:SetScript("OnUpdate", nil)
                    BattleMusicDataFrame.lingering = false
                    StopMusic()
                end

            end)

        else
            StopMusic()
        end
    end
end)
