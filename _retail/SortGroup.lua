SortGroupInformation = {};
local L = LibStub('AceLocale-3.0'):GetLocale('SortGroup');

-- Main Frame
local Main_Frame = CreateFrame('Frame', 'MainPanel', InterfaceOptionsFramePanelContainer);

-- default values
local defaultValues_DB = {
    Top = true,
    TopDescending = true,
    TopAscending = false,
    Bottom = false,
    BottomDescending = false,
    BottomAscending = false,
    Middle = false,
    MiddleUnevenTop = false,
    MiddleUnevenBottom = false,
    ChatMessagesOn = true,
    HideInactiveSlots = true
}

-- saved values, loaded by loadData()
local savedValues_DB = {};

-- filters
-- change Strings, if you want a specific filter
local filter_DB = {
    top = {
        descending = {"player", "party1", "party2", "party3", "party4"},
        ascending = {"player", "party4", "party3", "party2", "party1"}
    },
    bottom = {
        descending = {"party1", "party2", "party3", "party4", "player"},
        ascending = {"party4", "party3", "party2", "party1", "player"}
    },
    middle = {
        unevenTop = {"party3", "party1", "player", "party2", "party4"},
        unevenBottom = {"party4", "party2", "player", "party1", "party3"}
    }
};

-- Options, which are only changeable here atm. These can cause taint and errors, but can also be useful. Activate on your own 'risk'
local changeableValues_DB = {
    ChangesInCombat = false, -- You can change options in combat
    RaidProfileBlockInCombat = true
}

-- values changed by events
local internValues_DB = {
    showChatMessages = false, -- true when 'PLAYER_ENTERING_WORLD' fired or cb Event gets triggered
    firstLoad = true
}

local UpdateTable = {}
-- *End Variables*

-- Text
local Main_Title = Main_Frame:CreateFontString('MainTitle', 'OVERLAY', 'GameFontHighlight');
local Main_Text_Version = CreateFrame('SimpleHTML', 'MainTextVersion', Main_Frame);
local Main_Text_Author = CreateFrame('SimpleHTML', 'MainTextAuthor', Main_Frame);
local SortBy_Text = CreateFrame('SimpleHTML', 'SortBy_Text', Main_Frame);
local Option_Text = CreateFrame('SimpleHTML', 'Option_Text', Main_Frame);
local intern_version = '5.2.0';
local intern_versionOutput = '|cFF00FF00Version|r  ' .. intern_version;
local intern_author = 'Collabo93';
local intern_authorOutput = '|cFF00FF00Author|r   ' .. intern_author;

-- Checkboxes
local Main_cb_Top = CreateFrame('CheckButton', 'MainCbTop', Main_Frame, 'UICheckButtonTemplate');
local Main_cb_Bottom = CreateFrame('CheckButton', 'MainCbBottom', Main_Frame, 'UICheckButtonTemplate');
local Main_cb_Middle = CreateFrame('CheckButton', 'MainCbMiddle', Main_Frame, 'UICheckButtonTemplate');
local Main_cb_TopDescending = CreateFrame('CheckButton', 'MainCbTopDescending', Main_cb_Top, 'UICheckButtonTemplate');
local Main_cb_TopAscending = CreateFrame('CheckButton', 'MainCbTopAscending', Main_cb_Top, 'UICheckButtonTemplate');
local Main_cb_BottomDescending = CreateFrame('CheckButton', 'MainCbBottomDescending', Main_cb_Bottom,
    'UICheckButtonTemplate');
local Main_cb_BottomAscending = CreateFrame('CheckButton', 'MainCbBottomAscending', Main_cb_Bottom,
    'UICheckButtonTemplate');
local Main_cb_MiddleUnevenTop = CreateFrame('CheckButton', 'MainCbMiddlePUnevenTop', Main_cb_Middle,
    'UICheckButtonTemplate');
local Main_cb_MiddlePUnevenBottom = CreateFrame('CheckButton', 'MainCbMiddleUnevenBottom', Main_cb_Middle,
    'UICheckButtonTemplate');
local Option_cb_ChatMessagesOn = CreateFrame('CheckButton', 'OptionCbChatMessagesOn', Option_Text,
    'UICheckButtonTemplate');
local Option_cb_HideInactiveSlots = CreateFrame('CheckButton', 'OptionCbHideInactiveSlots', Option_Text,
    'UICheckButtonTemplate');

-- *End Variables*

local function ColorText(text, operation)
    local defaultColor = '#FFFFFF';
    if operation == 'option' then
        local cacheText = text:gsub('SortGroup:', function(cap)
            cap = cap:sub(1, -1);
            local color = '|cff00FF7F' or defaultColor;
            return color .. cap .. '|r';
        end)
        return cacheText;
    elseif operation == 'disable' then
        local color = '|cff888888' or defaultColor;
        return color .. text;
    elseif operation == 'green' then
        local color = '|cff00ff00' or defaultColor;
        return color .. text;
    elseif operation == 'red' then
        local color = '|cffff0000' or defaultColor;
        return color .. text;
    elseif operation == 'white' then
        local color = '|cffffffff' or defaultColor;
        return color .. text;
    end
end

function ApplyFilter(filter)

    if IsInGroup() and GetNumGroupMembers() <= 5 and HasLoadedCUFProfiles() then

        -- possible implementation for other frames
        local frames = {
            ["Blizzard"] = "CompactPartyFrameMember"
            -- ["ElvUI"] = "ElvUF_PartyGroup"
        };

        local units = {};

        for index, token in ipairs(filter) do
            table.insert(units, token);
        end

        for index, realPartyMemberToken in ipairs(units) do
            local unitFrame = _G[frames.Blizzard .. index];
            CompactUnitFrame_ClearWidgetSet(unitFrame);
            unitFrame:Hide();
            unitFrame.unitExists = false;
        end

        local playerDiplayed = false;
        for index, realPartyMemberToken in ipairs(units) do
            local unitFrame = _G[frames.Blizzard .. index];
            local usePlayerOverride = EditModeManagerFrame:ArePartyFramesForcedShown() and
                                          not UnitExists(realPartyMemberToken);
            local unitToken = usePlayerOverride and "player" or realPartyMemberToken;

            if savedValues_DB.HideInactiveSlots and not UnitExists(unitToken) then
                if playerDiplayed then
                    return false;
                end
                unitToken = "player";
            end

            if unitToken == "player" then
                playerDiplayed = true;
            end

            CompactUnitFrame_SetUnit(unitFrame, unitToken);
            CompactUnitFrame_SetUpFrame(unitFrame, DefaultCompactUnitFrameSetup);
            CompactUnitFrame_SetUpdateAllEvent(unitFrame, "GROUP_ROSTER_UPDATE");
        end

        CompactRaidGroup_UpdateBorder(CompactPartyFrame);
        PartyFrame:UpdatePaddingAndLayout();
    end
end

local function optionsCorrect()
    if not EditModeManagerFrame:UseRaidStylePartyFrames() then
        if internValues_DB.showChatMessages then
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_no_raid_style_frames'], 'option'));
            end
        end
        return false;
    end
    return true;
end

-- Decision which filter option to activate
local function ApplySort()

    -- combat status check
    if not InCombatLockdown() and optionsCorrect() then

        -- Everything is fine, sorting can get applied
        if savedValues_DB.Top then
            if savedValues_DB.TopDescending then
                ApplyFilter(filter_DB.top.descending);
                if internValues_DB.showChatMessages then
                    if savedValues_DB.ChatMessagesOn then
                        print(ColorText(L['SortGroup_sort_top_descending_output'], 'option'));
                    end
                end

            end
            if savedValues_DB.TopAscending then
                ApplyFilter(filter_DB.top.ascending);
                if internValues_DB.showChatMessages then
                    if savedValues_DB.ChatMessagesOn then
                        print(ColorText(L['SortGroup_sort_top_ascending_output'], 'option'));
                    end
                end

            end
        elseif savedValues_DB.Bottom then
            if savedValues_DB.BottomDescending then
                ApplyFilter(filter_DB.bottom.descending);
                if internValues_DB.showChatMessages then
                    if savedValues_DB.ChatMessagesOn then
                        print(ColorText(L['SortGroup_sort_top_descending_output'], 'option'));
                    end
                end

            end
            if savedValues_DB.BottomAscending then
                ApplyFilter(filter_DB.bottom.ascending);
                if internValues_DB.showChatMessages then
                    if savedValues_DB.ChatMessagesOn then
                        print(ColorText(L['SortGroup_sort_bottom_ascending_output'], 'option'));
                    end
                end

            end
        elseif savedValues_DB.Middle then
            if savedValues_DB.MiddleUnevenTop then
                ApplyFilter(filter_DB.middle.unevenTop);
                if internValues_DB.showChatMessages then
                    if savedValues_DB.ChatMessagesOn then
                        print(ColorText(L['SortGroup_sort_uneven_top_output'], 'option'));
                    end
                end

            end
            if savedValues_DB.MiddleUnevenBottom then
                ApplyFilter(filter_DB.middle.unevenBottom);
                if internValues_DB.showChatMessages then
                    if savedValues_DB.ChatMessagesOn then
                        print(ColorText(L['SortGroup_sort_uneven_bottom_output'], 'option'));
                    end
                end

            end

        else
            if internValues_DB.showChatMessages then
                if savedValues_DB.ChatMessagesOn then
                    print(ColorText(L['SortGroup_sort_no_output'], 'option'));
                end
            end

        end
    end
    internValues_DB.showChatMessages = false;
end

-- Update cbs - Checked/Unchecked, Text + Text Color, Enabled/Disabledj
local function UpdateComboBoxes()

    -- Player Top/Bottom/Middle
    if savedValues_DB.Top then
        Main_cb_Top:SetChecked(true);
        Main_cb_Bottom:SetChecked(false);
        Main_cb_Middle:SetChecked(false);

        Main_cb_TopDescending:Enable();
        Main_cb_TopAscending:Enable();
        Main_cb_BottomDescending:Disable();
        Main_cb_BottomAscending:Disable();
        Main_cb_MiddleUnevenTop:Disable();
        Main_cb_MiddlePUnevenBottom:Disable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Descending_Text'], 'white'));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'white'));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_Descending_Text'], 'disable'));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'disable'));
        getglobal(Main_cb_MiddleUnevenTop:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_UnevenTop_Text'], 'disable'));
        getglobal(Main_cb_MiddlePUnevenBottom:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_UnevenBottom_Text'], 'disable'));
    elseif savedValues_DB.Bottom then
        Main_cb_Top:SetChecked(false);
        Main_cb_Bottom:SetChecked(true);
        Main_cb_Middle:SetChecked(false);

        Main_cb_TopDescending:Disable();
        Main_cb_TopAscending:Disable();
        Main_cb_BottomDescending:Enable();
        Main_cb_BottomAscending:Enable();
        Main_cb_MiddleUnevenTop:Disable();
        Main_cb_MiddlePUnevenBottom:Disable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Descending_Text'], 'disable'));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'disable'));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_Descending_Text'], 'white'));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'white'));
        getglobal(Main_cb_MiddleUnevenTop:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_UnevenTop_Text'], 'disable'));
        getglobal(Main_cb_MiddlePUnevenBottom:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_UnevenBottom_Text'], 'disable'));
    elseif savedValues_DB.Middle then
        Main_cb_Top:SetChecked(false);
        Main_cb_Bottom:SetChecked(false);
        Main_cb_Middle:SetChecked(true);

        Main_cb_TopDescending:Disable();
        Main_cb_TopAscending:Disable();
        Main_cb_BottomDescending:Disable();
        Main_cb_BottomAscending:Disable();
        Main_cb_MiddleUnevenTop:Enable();
        Main_cb_MiddlePUnevenBottom:Enable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Descending_Text'], 'disable'));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'disable'));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_Descending_Text'], 'disable'));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'disable'));
        getglobal(Main_cb_MiddleUnevenTop:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_UnevenTop_Text'], 'white'));
        getglobal(Main_cb_MiddlePUnevenBottom:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_UnevenBottom_Text'], 'white'));
    else
        Main_cb_Top:SetChecked(false);
        Main_cb_Bottom:SetChecked(false);
        Main_cb_Middle:SetChecked(false);

        Main_cb_TopDescending:Disable();
        Main_cb_TopAscending:Disable();
        Main_cb_BottomDescending:Disable();
        Main_cb_BottomAscending:Disable();
        Main_cb_MiddleUnevenTop:Disable();
        Main_cb_MiddlePUnevenBottom:Disable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Descending_Text'], 'disable'));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'disable'));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_Descending_Text'], 'disable'));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'disable'));
        getglobal(Main_cb_MiddleUnevenTop:GetName() .. 'Text'):SetText(
            ColorText(L['SortGroup_Main_cb_UnevenTop_Text'], 'disable'));
        getglobal(Main_cb_MiddlePUnevenBottom:GetName() .. 'Text'):SetText(ColorText(
            L['SortGroup_Main_cb_UnevenBottom_Text'], 'disable'));
    end

    -- Top, Ascending/Descending
    if savedValues_DB.TopDescending then
        Main_cb_TopDescending:SetChecked(true);
        Main_cb_TopAscending:SetChecked(false);
    elseif savedValues_DB.TopAscending then
        Main_cb_TopAscending:SetChecked(true);
        Main_cb_TopDescending:SetChecked(false);
    else
        Main_cb_TopDescending:SetChecked(false);
        Main_cb_TopAscending:SetChecked(false);
    end

    -- Bottom, Ascending/Descending
    if savedValues_DB.BottomDescending then
        Main_cb_BottomDescending:SetChecked(true);
        Main_cb_BottomAscending:SetChecked(false);
    elseif savedValues_DB.BottomAscending then
        Main_cb_BottomDescending:SetChecked(false);
        Main_cb_BottomAscending:SetChecked(true);
    else
        Main_cb_BottomDescending:SetChecked(false);
        Main_cb_BottomAscending:SetChecked(false);
    end

    -- Middle, Party 1 Top/ Party 2 Top
    if savedValues_DB.MiddleUnevenTop then
        Main_cb_MiddleUnevenTop:SetChecked(true);
        Main_cb_MiddlePUnevenBottom:SetChecked(false);
    elseif savedValues_DB.MiddleUnevenBottom then
        Main_cb_MiddleUnevenTop:SetChecked(false);
        Main_cb_MiddlePUnevenBottom:SetChecked(true);
    else
        Main_cb_MiddleUnevenTop:SetChecked(false);
        Main_cb_MiddlePUnevenBottom:SetChecked(false);
    end

    -- Chat messages
    if savedValues_DB.ChatMessagesOn then
        Option_cb_ChatMessagesOn:SetChecked(true);
    else
        Option_cb_ChatMessagesOn:SetChecked(false);
    end

    if savedValues_DB.HideInactiveSlots then
        Option_cb_HideInactiveSlots:SetChecked(true);
    else
        Option_cb_HideInactiveSlots:SetChecked(false);
    end
end

-- Hooks for container updates
local function resetRaidContainer()
    if changeableValues_DB.RaidProfileBlockInCombat then

        for _, frame in ipairs(ActionBarButtonEventsFrame.frames) do
            hooksecurefunc(frame, "UpdateAction", checkFrame);
        end

        hooksecurefunc('CompactUnitFrame_UpdateVisible', function(frame)
            if not frame then
                return;
            end
            if frame:IsForbidden() then
                return;
            end
            local name = frame:GetName();
            if not name or not name:match('^CompactPartyFrameMember') then
                return;
            end

            if InCombatLockdown() then
                if not UpdateTable[frame] then
                    UpdateTable[frame] = true
                end
            else
                return;
            end
        end)
    end
end

-- Fired by player logout + cbs
local function SaveOptions()
    for key in pairs(savedValues_DB) do
        if savedValues_DB[key] ~= nil and savedValues_DB[key] ~= '' then
            SortGroupInformation[key] = savedValues_DB[key];
        end
    end
end

local function createFrame()
    Main_Frame.name = 'SortGroup';
    Main_Title:SetFont('Fonts\\FRIZQT__.TTF', 18);
    Main_Title:SetTextColor(1, 0.8, 0);
    Main_Title:SetPoint('TOPLEFT', 12, -18);
    Main_Title:SetText('SortGroup');

    InterfaceOptions_AddCategory(Main_Frame);
end

local function createText()
    Main_Text_Version:SetPoint('TOPLEFT', 20, -45);
    Main_Text_Version:SetFontObject('p', 'GameTooltipTextSmall');
    Main_Text_Version:SetText(intern_versionOutput);
    Main_Text_Version:SetSize(string.len(intern_versionOutput), 10);

    Main_Text_Author:SetPoint('TOPLEFT', 20, -55);
    Main_Text_Author:SetFontObject('p', 'GameFontHighlightSmall');
    Main_Text_Author:SetText(intern_authorOutput);
    Main_Text_Author:SetSize(string.len(intern_authorOutput), 10);

    SortBy_Text:SetPoint("TOPLEFT", Main_Title, 10, -105);
    SortBy_Text:SetFontObject('p', GameFontHighlightMedium);
    SortBy_Text:SetText(L["SortGroup_SortBy_Text"]);
    SortBy_Text:SetSize(string.len(L["SortGroup_SortBy_Text"]), 10);

    Option_Text:SetPoint("TOPLEFT", Main_Title, 350, -105);
    Option_Text:SetFontObject('p', GameFontHighlightMedium);
    Option_Text:SetText(L["SortGroup_Option_Text"]);
    Option_Text:SetSize(string.len(L["SortGroup_Option_Text"]), 10);

end

local function createCheckbox()
    -- the three main cbs
    Main_cb_Top:SetPoint('TOPLEFT', SortBy_Text, 10, -25);
    Main_cb_Bottom:SetPoint('TOPLEFT', SortBy_Text, 10, -125);
    Main_cb_Middle:SetPoint('TOPLEFT', SortBy_Text, 10, -225);

    -- cb chidlren
    Main_cb_TopDescending:SetPoint('TOPLEFT', 30, -30);
    Main_cb_TopAscending:SetPoint('TOPLEFT', 30, -55);
    Main_cb_BottomDescending:SetPoint('TOPLEFT', 30, -30);
    Main_cb_BottomAscending:SetPoint('TOPLEFT', 30, -55);
    Main_cb_MiddleUnevenTop:SetPoint('TOPLEFT', 30, -30);
    Main_cb_MiddlePUnevenBottom:SetPoint('TOPLEFT', 30, -55);

    -- set Text to cbs
    -- Main frame
    getglobal(Main_cb_Top:GetName() .. 'Text'):SetText(ColorText(L['SortGroup_Main_cb_Top_Text'], 'white'));
    getglobal(Main_cb_Bottom:GetName() .. 'Text'):SetText(ColorText(L['SortGroup_Main_cb_Bottom_Text'], 'white'));
    getglobal(Main_cb_Middle:GetName() .. 'Text'):SetText(ColorText(L['SortGroup_Main_cb_Middle_Text'], 'white'));
    getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(
        ColorText(L['SortGroup_Main_cb_Descending_Text'], 'white'));
    getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(
        ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'white'));
    getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(
        ColorText(L['SortGroup_Main_cb_Descending_Text'], 'white'));
    getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(
        ColorText(L['SortGroup_Main_cb_Ascending_Text'], 'white'));
    getglobal(Main_cb_MiddlePUnevenBottom:GetName() .. 'Text'):SetText(
        ColorText(L['SortGroup_Main_cb_UnevenTop_Text'], 'white'));
    getglobal(Main_cb_MiddleUnevenTop:GetName() .. 'Text'):SetText(
        ColorText(L['SortGroup_Main_cb_UnevenBottom_Text'], 'white'));

    -- Option frame
    Option_cb_ChatMessagesOn:SetPoint('TOPLEFT', Option_Text, 10, -25);
    Option_cb_HideInactiveSlots:SetPoint('TOPLEFT', Option_Text, 10, -50);

    getglobal(Option_cb_ChatMessagesOn:GetName() .. 'Text'):SetText(ColorText(
        L['SortGroup_Option_cb_ChatMessagesOn_Text'], 'white'));
    getglobal(Option_cb_HideInactiveSlots:GetName() .. 'Text'):SetText(ColorText(
        L['SortGroup_Option_cb_HideInactiveSlots_Text'], 'white'));

end

-- *End Creating*
local function loadData()
    -- load defaults first
    for key in pairs(defaultValues_DB) do
        savedValues_DB[key] = defaultValues_DB[key];
    end

    -- load saved data, fallback are the defaulValues
    for key in pairs(SortGroupInformation) do
        if SortGroupInformation[key] ~= nil and SortGroupInformation[key] ~= '' then
            savedValues_DB[key] = SortGroupInformation[key];
        end
    end
end

function checkFrame(frame)
    if not issecurevariable(frame, "action") and not InCombatLockdown() then
        frame.action = nil
        frame:SetAttribute("action");
    end
end

-- Events
local function frameEvent()
    Main_Frame:RegisterEvent('PLAYER_LOGOUT');
    Main_Frame:RegisterEvent('PLAYER_REGEN_ENABLED');
    Main_Frame:RegisterEvent('GROUP_ROSTER_UPDATE');
    Main_Frame:RegisterEvent('PLAYER_ENTERING_WORLD');
    Main_Frame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED");
    -- Main_Frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");

    Main_Frame:SetScript('OnEvent', function(self, event, ...)
        if event == 'PLAYER_LOGOUT' then
            SaveOptions();
            Main_Frame:UnregisterEvent(event);
        elseif event == 'PLAYER_REGEN_ENABLED' then
            for frame, _ in pairs(UpdateTable) do
                UpdateTable[frame] = nil
            end

            ApplySort();
        elseif event == 'GROUP_ROSTER_UPDATE' then
            ApplySort()
        elseif event == 'ACTIVE_TALENT_GROUP_CHANGED' then
            for frame, _ in ipairs(ActionBarButtonEventsFrame.frames) do
                checkFrame(frame);
            end
        elseif event == 'PLAYER_ENTERING_WORLD' then
            if internValues_DB.firstLoad then
                loadData();
                UpdateComboBoxes();
                resetRaidContainer(); -- hooks
                internValues_DB.showChatMessages = true;
                internValues_DB.firstLoad = false;
                -- if Enum.EditModeAccountSetting.ShowTargetAndFocus == 1 then
                --     EditModeManagerFrame:OnAccountSettingChanged(Enum.EditModeAccountSetting.ShowTargetAndFocus, 0);
                -- end
            end
            ApplySort();
        end
    end);
end

-- ComboBox Events
local function checkBoxEvent()

    -- Combobox Top
    Main_cb_Top:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_Top:GetChecked() then
                savedValues_DB.Top = true;
                savedValues_DB.Bottom = false;
                savedValues_DB.Middle = false;
                if Main_cb_TopDescending:GetChecked() == false and Main_cb_TopAscending:GetChecked() == false then
                    savedValues_DB.TopDescending = true;
                end
            elseif Main_cb_Top:GetChecked() == false then
                savedValues_DB.Top = false;
            end
            SaveOptions();
            UpdateComboBoxes();
            ApplySort();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_Top:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Top_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Top_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_Top:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Bottom
    Main_cb_Bottom:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_Bottom:GetChecked() then
                savedValues_DB.Top = false;
                savedValues_DB.Bottom = true;
                savedValues_DB.Middle = false;
                if Main_cb_BottomDescending:GetChecked() == false and Main_cb_BottomAscending:GetChecked() == false then
                    savedValues_DB.BottomAscending = true;
                    Main_cb_BottomAscending:SetChecked(true);
                end
            elseif Main_cb_Bottom:GetChecked() == false then
                savedValues_DB.Bottom = false;
            end
            SaveOptions();
            UpdateComboBoxes();
            ApplySort();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_Bottom:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Bottom_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Bottom_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_Bottom:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Middle
    Main_cb_Middle:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_Middle:GetChecked() then
                savedValues_DB.Top = false;
                savedValues_DB.Bottom = false;
                savedValues_DB.Middle = true;
                if Main_cb_MiddleUnevenTop:GetChecked() == false and Main_cb_MiddlePUnevenBottom:GetChecked() == false then
                    savedValues_DB.MiddleUnevenTop = true;
                    Main_cb_MiddleUnevenTop:SetChecked(true);
                end
            elseif Main_cb_Middle:GetChecked() == false then
                savedValues_DB.Middle = false;
            end
            SaveOptions();
            UpdateComboBoxes();
            ApplySort();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_Middle:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Middle_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Middle_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_Middle:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Main_cb_TopDescending
    Main_cb_TopDescending:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_TopDescending:GetChecked() then
                savedValues_DB.TopDescending = true;
                savedValues_DB.TopAscending = false;
            elseif Main_cb_TopDescending:GetChecked() == false then
                savedValues_DB.TopDescending = false;
            end
            SaveOptions();
            UpdateComboBoxes();
            ApplySort();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_TopDescending:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Descending_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Descending_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_TopDescending:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Main_cb_TopDescending
    Main_cb_TopAscending:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_TopAscending:GetChecked() then
                savedValues_DB.TopDescending = false;
                savedValues_DB.TopAscending = true;
            elseif Main_cb_TopAscending:GetChecked() == false then
                savedValues_DB.TopAscending = false;
            end
            SaveOptions();
            UpdateComboBoxes();
            ApplySort();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_TopAscending:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Ascending_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Ascending_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_TopAscending:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Main_cb_TopDescending
    Main_cb_BottomDescending:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_BottomDescending:GetChecked() then
                savedValues_DB.BottomDescending = true;
                savedValues_DB.BottomAscending = false;
            elseif Main_cb_BottomDescending:GetChecked() == false then
                savedValues_DB.BottomDescending = false;
            end
            SaveOptions();
            ApplySort();
            UpdateComboBoxes();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_BottomDescending:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Descending_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Descending_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_BottomDescending:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Main_cb_TopDescending
    Main_cb_BottomAscending:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_BottomAscending:GetChecked() then
                savedValues_DB.BottomDescending = false;
                savedValues_DB.BottomAscending = true;
            elseif Main_cb_BottomAscending:GetChecked() == false then
                savedValues_DB.BottomAscending = false;
            end
            SaveOptions();
            ApplySort();
            UpdateComboBoxes();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_BottomAscending:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_Ascending_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_Ascending_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_BottomAscending:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Main_cb_MiddleUnevenTop
    Main_cb_MiddleUnevenTop:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_MiddleUnevenTop:GetChecked() then
                savedValues_DB.MiddleUnevenTop = true;
                savedValues_DB.MiddleUnevenBottom = false;
            elseif Main_cb_MiddleUnevenTop:GetChecked() == false then
                savedValues_DB.MiddleUnevenTop = false;
            end
            SaveOptions();
            ApplySort();
            UpdateComboBoxes();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_MiddleUnevenTop:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_UnevenTop_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_UnevenTop_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_MiddleUnevenTop:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Main_cb_MiddlePUnevenBottom
    Main_cb_MiddlePUnevenBottom:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            internValues_DB.showChatMessages = true;
            if Main_cb_MiddlePUnevenBottom:GetChecked() then
                savedValues_DB.MiddleUnevenTop = false;
                savedValues_DB.MiddleUnevenBottom = true;
            elseif Main_cb_MiddlePUnevenBottom:GetChecked() == false then
                savedValues_DB.MiddleUnevenBottom = false;
            end
            SaveOptions();
            ApplySort();
            UpdateComboBoxes();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Main_cb_MiddlePUnevenBottom:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Main_cb_UnevenBottom_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_UnivenBottom_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Main_cb_MiddlePUnevenBottom:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox savedValues_DB.ChatMessagesOn
    Option_cb_ChatMessagesOn:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            if Option_cb_ChatMessagesOn:GetChecked() then
                savedValues_DB.ChatMessagesOn = true;
                print(ColorText(L['SortGroup_sort_chat_Messages_On_output'], 'option'));
            elseif Option_cb_ChatMessagesOn:GetChecked() == false then
                savedValues_DB.ChatMessagesOn = false;
            end
            SaveOptions();
            UpdateComboBoxes();
        else
            UpdateComboBoxes();
            if savedValues_DB.ChatMessagesOn then
                print(ColorText(L['SortGroup_in_combat_options_output'], 'option'));
            end
        end
    end);
    Option_cb_ChatMessagesOn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Option_cb_ChatMessagesOn_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Main_cb_ChatMessagesOn_ToolTip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Option_cb_ChatMessagesOn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)

    -- Combobox Option_cb_HideInactiveSlots
    Option_cb_HideInactiveSlots:SetScript('OnClick', function()
        if not InCombatLockdown() or changeableValues_DB.ChangesInCombat then
            if Option_cb_HideInactiveSlots:GetChecked() then
                savedValues_DB.HideInactiveSlots = true;
            else
                savedValues_DB.HideInactiveSlots = false;
            end
            SaveOptions();
            ApplySort();
            UpdateComboBoxes();
        else
            UpdateComboBoxes();
        end
    end);
    Option_cb_HideInactiveSlots:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:AddLine(L['SortGroup_Option_cb_HideInactiveSlots_Text'] .. '\n\n' ..
                                ColorText(L['SortGroup_Option_cb_HideInactiveSlots_Tooltip'], 'white'), nil, nil, nil, 1);
        GameTooltip:Show();
    end);
    Option_cb_HideInactiveSlots:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
end

---End Events
local loader = CreateFrame('Frame');
loader:RegisterEvent('ADDON_LOADED');
loader:SetScript('OnEvent', function(self, event, arg1)
    if event == 'ADDON_LOADED' and arg1 == 'SortGroup' then
        createFrame();
        createText();
        createCheckbox();
        frameEvent();
        checkBoxEvent();
        self:UnregisterEvent('ADDON_LOADED');
    end
end);
