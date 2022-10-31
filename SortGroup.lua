SortGroupInformation = {};
local L = LibStub("AceLocale-3.0"):GetLocale("SortGroup");

-- Main Frame
local Main_Frame = CreateFrame("Frame", "MainPanel", InterfaceOptionsFramePanelContainer);

--default values
local defaultValues_DB = {
    Top = true,
    TopDescending = true,
    TopAscending = false,
    Bottom = false,
    BottomDescending = false,
    BottomAscending = false,
    ChatMessagesOn = true,
    -- Middle = false,
    -- MiddleParty1Top = false,
    -- MiddleParty2Top = false,
    -- VisibilityInCombat = true
}

--saved values, loaded by loadData()
local savedValues_DB = {};

-- Options, which are only changeable here atm. These can cause taint and errors, but can also be useful. Activate on your own "risk"
local changeableValues_DB = {
    ChangesInCombat = false; --You can change options in combat
    RaidProfileBlockInCombat = true
}

--values changes by events
local internValues_DB = {
    showChatMessages = false, -- true when "PLAYER_ENTERING_WORLD" fired or cb Event gets triggered
    inCombat = false, -- true when "PLAYER_REGEN_DISABLED" fired
}

local UpdateTable = {}; --saved functions, blocked in combat

--*End Variables*
--Text
local Main_Title = Main_Frame:CreateFontString("MainTitle", "OVERLAY", "GameFontHighlight");
local Main_Text_Version = CreateFrame("SimpleHTML", "MainTextVersion", Main_Frame);
local Main_Text_Author = CreateFrame("SimpleHTML", "MainTextAuthor", Main_Frame);
local intern_version = "5.1.02 Beta";
local intern_versionOutput = "|cFF00FF00Version|r  " .. intern_version;
local intern_author = "Collabo93";
local intern_authorOutput = "|cFF00FF00Author|r   " .. intern_author;

--Checkboxes
local Main_cb_Top = CreateFrame("CheckButton", "MainCbTop", Main_Frame, "UICheckButtonTemplate");
local Main_cb_Bottom = CreateFrame("CheckButton", "MainCbBottom", Main_Frame, "UICheckButtonTemplate");
local Main_cb_Middle = CreateFrame("CheckButton", "MainCbMiddle", Main_Frame, "UICheckButtonTemplate");
local Main_cb_TopDescending = CreateFrame("CheckButton", "MainCbTopDescending", Main_cb_Top, "UICheckButtonTemplate");
local Main_cb_TopAscending = CreateFrame("CheckButton", "MainCbTopAscending", Main_cb_Top, "UICheckButtonTemplate");
local Main_cb_BottomDescending = CreateFrame("CheckButton", "MainCbBottomDescending", Main_cb_Bottom,
    "UICheckButtonTemplate");
local Main_cb_BottomAscending = CreateFrame("CheckButton", "MainCbBottomAscending", Main_cb_Bottom,
    "UICheckButtonTemplate");
local Main_cb_MiddleParty1Top = CreateFrame("CheckButton", "MainCbMiddleParty1Top", Main_cb_Middle,
    "UICheckButtonTemplate");
local Main_cb_MiddleParty2Top = CreateFrame("CheckButton", "MainCbMiddleParty2Top", Main_cb_Middle,
    "UICheckButtonTemplate");
local Option_cb_ChatMessagesOn = CreateFrame("CheckButton", "OptionCbChatMessagesOn", Main_Frame,
    "UICheckButtonTemplate");

--*End Variables*
local function ColorText(text, operation)
    local defaultColor = "#FFFFFF";
    if (operation == "option") then
        local cacheText = text:gsub("SortGroup:", function(cap)
            cap = cap:sub(1, -1);
            local color = "|cff00FF7F" or defaultColor;
            return color .. cap .. "|r";
        end)
        return cacheText;
    elseif (operation == "disable") then
        local color = "|cff888888" or defaultColor;
        return color .. text;
    elseif (operation == "green") then
        local color = "|cff00ff00" or defaultColor;
        return color .. text;
    elseif (operation == "red") then
        local color = "|cffff0000" or defaultColor;
        return color .. text;
    elseif (operation == "white") then
        local color = "|cffffffff" or defaultColor;
        return color .. text;
    end
end

--Top, Descending
local function SortTopDescending()

    --Group status check
    if (IsInGroup() and GetNumGroupMembers() <= 5 and HasLoadedCUFProfiles()) then
        local CRFSort_TopDownwards = function(t1, t2)
            if not UnitExists(t1) then
                return false;
            elseif not UnitExists(t2) then
                return true
            elseif UnitIsUnit(t1, "player") then
                return true;
            elseif UnitIsUnit(t2, "player") then
                return false;
            else
                return t1 < t2;
            end
        end
        --CompactRaidFrameContainerMixin:SetFlowFilterFunction(CRFSort_TopDownwards);
        CompactPartyFrame_SetFlowSortFunction(CRFSort_TopDownwards);
    end

    if (internValues_DB.showChatMessages == true) then
        if (savedValues_DB.ChatMessagesOn == true) then
            print(ColorText(L["SortGroup_sort_top_descending_output"], "option"));
        end

    end
end

--Top, Ascending
local function SortTopAscending()

    --Group status check
    if (IsInGroup() and GetNumGroupMembers() <= 5 and HasLoadedCUFProfiles()) then
        local CRFSort_TopUpwards = function(t1, t2)
            if not UnitExists(t1) then
                return false;
            elseif not UnitExists(t2) then
                return true
            elseif UnitIsUnit(t1, "player") then
                return true;
            elseif UnitIsUnit(t2, "player") then
                return false;
            else
                return t1 > t2;
            end
        end
        --CompactRaidFrameContainerMixin:SetFlowFilterFunction(CRFSort_TopUpwards);
        CompactPartyFrame_SetFlowSortFunction(CRFSort_TopUpwards);
    end

    if (internValues_DB.showChatMessages == true) then
        if (savedValues_DB.ChatMessagesOn == true) then
            print(ColorText(L["SortGroup_sort_top_ascending_output"], "option"));
        end

    end
end

--Bottom, Descending
local function SortBottomDescending()

    --Group status check
    if (IsInGroup() and GetNumGroupMembers() <= 5 and HasLoadedCUFProfiles()) then
        local CRFSort_BottomUpwards = function(t1, t2)
            if not UnitExists(t1) then
                return false;
            elseif not UnitExists(t2) then
                return true
            elseif UnitIsUnit(t1, "player") then
                return false;
            elseif UnitIsUnit(t2, "player") then
                return true;
            else
                return t1 > t2;
            end
        end
        --CompactRaidFrameContainerMixin:SetFlowSortFunction(CRFSort_BottomUpwards);
        CompactPartyFrame_SetFlowSortFunction(CRFSort_BottomUpwards);
    end

    if (internValues_DB.showChatMessages == true) then
        if (savedValues_DB.ChatMessagesOn == true) then
            print(ColorText(L["SortGroup_sort_bottom_descending_output"], "option"));
        end

    end
end

--Bottom, Ascending
local function SortBottomAscending()

    --Group status check
    if (IsInGroup() and GetNumGroupMembers() <= 5 and HasLoadedCUFProfiles()) then
        local CRFSort_BottomDownwards = function(t1, t2)
            if not UnitExists(t1) then
                return false;
            elseif not UnitExists(t2) then
                return true
            elseif UnitIsUnit(t1, "player") then
                return false;
            elseif UnitIsUnit(t2, "player") then
                return true;
            else
                return t1 < t2;
            end
        end
        --CompactRaidFrameContainerMixin:SetFlowSortFunction(CRFSort_BottomDownwards);
        CompactPartyFrame_SetFlowSortFunction(CRFSort_BottomDownwards);
    end

    if (internValues_DB.showChatMessages == true) then
        if (savedValues_DB.ChatMessagesOn == true) then
            print(ColorText(L["SortGroup_sort_bottom_ascending_output"], "option"));
        end

    end

end

-- Middle, Party1 on Top
-- Later: Added at antoher point
-- local function SortMiddleParty1Top()
--     local CRFSort_MiddleParty1Top = function(t1, t2)
--         if UnitIsUnit(t1, "party1") then
--             return true;
--         elseif UnitIsUnit(t1, "player") or UnitIsUnit(t2, "player") or UnitIsUnit(t2, "party1") then
--             return false;
--         else
--             return t1 < t2;
--         end
--     end
--     CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_MiddleParty1Top);
-- end

-- Middle, Party2 on Top
-- local function SortMiddleParty2Top()
--     local CRFSort_MiddleParty2Top = function(t1, t2)
--         if UnitIsUnit(t1, "party2") then
--             return true;
--         elseif UnitIsUnit(t1, "player") or UnitIsUnit(t2, "player") or UnitIsUnit(t2, "party2") then
--             return false;
--         else
--             return t1 < t2;
--         end
--     end
--     CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_MiddleParty2Top);
-- end

-- Later
-- local CheckProfileOptions(){
--     // To Do
-- }

--Decision which sort option to activate
local function ApplySort()

    --combat status check
    if (internValues_DB.inCombat == false) then

        --Everything is fine, sorting can get applied
        if (savedValues_DB.Top) then
            if (savedValues_DB.TopDescending == true) then

                --CheckProfileOptions();
                SortTopDescending();
            end
            if (savedValues_DB.TopAscending == true) then

                --CheckProfileOptions();
                SortTopAscending();
            end
        elseif (savedValues_DB.Bottom) then
            if (savedValues_DB.BottomDescending == true) then

                --CheckProfileOptions();
                SortBottomAscending();
            end
            if (savedValues_DB.BottomAscending == true) then


                --CheckProfileOptions();
                SortBottomDescending();
            end
        else
            if (internValues_DB.showChatMessages == true) then
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_sort_no_output"], "option"));
                end
            end
        end

    end

    internValues_DB.showChatMessages = false;
end

--Update cbs - Checked/Unchecked, Text + Text Color, Enabled/Disabledj
local function UpdateComboBoxes()

    --Player Top/Bottom/Middle
    if (savedValues_DB.Top == true) then
        Main_cb_Top:SetChecked(true);
        Main_cb_Bottom:SetChecked(false);
        Main_cb_Middle:SetChecked(false);

        Main_cb_TopDescending:Enable();
        Main_cb_TopAscending:Enable();
        Main_cb_BottomDescending:Disable();
        Main_cb_BottomAscending:Disable();
        Main_cb_MiddleParty1Top:Disable();
        Main_cb_MiddleParty2Top:Disable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],
            "white"));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "white"));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"]
            , "disable"));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "disable"));
        getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],
            "disable"));
        getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],
            "disable"));
    elseif (savedValues_DB.Bottom == true) then
        Main_cb_Top:SetChecked(false);
        Main_cb_Bottom:SetChecked(true);
        Main_cb_Middle:SetChecked(false);

        Main_cb_TopDescending:Disable();
        Main_cb_TopAscending:Disable();
        Main_cb_BottomDescending:Enable();
        Main_cb_BottomAscending:Enable();
        Main_cb_MiddleParty1Top:Disable();
        Main_cb_MiddleParty2Top:Disable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],
            "disable"));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "disable"));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"]
            , "white"));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "white"));
        getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],
            "disable"));
        getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],
            "disable"));
    elseif (savedValues_DB.Middle == true) then
        Main_cb_Top:SetChecked(false);
        Main_cb_Bottom:SetChecked(false);
        Main_cb_Middle:SetChecked(true);

        Main_cb_TopDescending:Disable();
        Main_cb_TopAscending:Disable();
        Main_cb_BottomDescending:Disable();
        Main_cb_BottomAscending:Disable();
        Main_cb_MiddleParty1Top:Enable();
        Main_cb_MiddleParty2Top:Enable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],
            "disable"));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "disable"));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"]
            , "disable"));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "disable"));
        getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],
            "white"));
        getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],
            "white"));
    else
        Main_cb_Top:SetChecked(false);
        Main_cb_Bottom:SetChecked(false);
        Main_cb_Middle:SetChecked(false);

        Main_cb_TopDescending:Disable();
        Main_cb_TopAscending:Disable();
        Main_cb_BottomDescending:Disable();
        Main_cb_BottomAscending:Disable();
        Main_cb_MiddleParty1Top:Disable();
        Main_cb_MiddleParty2Top:Disable();

        getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],
            "disable"));
        getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "disable"));
        getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"]
            , "disable"));
        getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
            "disable"));
        getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],
            "disable"));
        getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],
            "disable"));
    end

    --Top, Ascending/Descending
    if (savedValues_DB.TopDescending == true) then
        Main_cb_TopDescending:SetChecked(true);
        Main_cb_TopAscending:SetChecked(false);
    elseif (savedValues_DB.TopAscending == true) then
        Main_cb_TopAscending:SetChecked(true);
        Main_cb_TopDescending:SetChecked(false);
    else
        Main_cb_TopDescending:SetChecked(false);
        Main_cb_TopAscending:SetChecked(false);
    end

    --Bottom, Ascending/Descending
    if (savedValues_DB.BottomDescending == true) then
        Main_cb_BottomDescending:SetChecked(true);
        Main_cb_BottomAscending:SetChecked(false);
    elseif (savedValues_DB.BottomAscending == true) then
        Main_cb_BottomDescending:SetChecked(false);
        Main_cb_BottomAscending:SetChecked(true);
    else
        Main_cb_BottomDescending:SetChecked(false);
        Main_cb_BottomAscending:SetChecked(false);
    end

    --Middle, Party 1 Top/ Party 2 Top
    if (savedValues_DB.MiddleParty1Top == true) then
        Main_cb_MiddleParty1Top:SetChecked(true);
        Main_cb_MiddleParty2Top:SetChecked(false);
    elseif (savedValues_DB.MiddleParty2Top == true) then
        Main_cb_MiddleParty1Top:SetChecked(false);
        Main_cb_MiddleParty2Top:SetChecked(true);
    else
        Main_cb_MiddleParty1Top:SetChecked(false);
        Main_cb_MiddleParty2Top:SetChecked(false);
    end

    --Chat messages
    if (savedValues_DB.ChatMessagesOn == true) then
        Option_cb_ChatMessagesOn:SetChecked(true);
    else
        Option_cb_ChatMessagesOn:SetChecked(false);
    end
end

-- Hooks for container updates
-- later: 10.0 neccessary?
local function resetRaidContainer()
    if (changeableValues_DB.RaidProfileBlockInCombat == true) then


        -- print(DEFAULT_OBJECTIVE_TRACKER_MODULE:MarkBlocksUnused("OnEvent"))

        -- local origActionBarButtonEventsFrameMixin_OnEvent = CompactPartyFrame_RefreshMembers;
        -- CompactPartyFrame_RefreshMembers = function(self)
        --     print('in');
        --     if (internValues_DB.inCombat == true) then
        --         UpdateTable[self:GetName()] = "CompactPartyFrame_RefreshMembers"
        --     else
        --         return origActionBarButtonEventsFrameMixin_OnEvent(self);
        --     end
        -- end


        -- local UIParentRightManagedFrameContainer_SetPoint_orig = ActionBarButtonEventsFrameMixin.OnEvent;
        -- function ActionBarButtonEventsFrameMixin.OnEvent(event, ...)
        --     print('in');
        --     if (internValues_DB.inCombat == true) then
        --         UpdateTable[self:GetName()] = "ActionBarButtonEventsFrameMixin.OnEvent"


        --     else
        --         return UIParentRightManagedFrameContainer_SetPoint_orig(self, ...);
        --     end

        -- end

        -- hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)

        --     --check if not empty
        --     if frame and frame.displayedUnit then

        --         --ignore nameplates. We dont wont to touch those
        --         if string.find(frame.displayedUnit, "nameplate") then
        --             return;

        --             --unit exists
        --         elseif UnitExists(frame.displayedUnit) then
        --             frame:SetScript("OnEnter", UnitFrame_OnEnter);

        --             --unit doesnt exist -> make the frame unclickable to prevent taint
        --         else
        --             frame:SetScript("OnEnter", nil)
        --             frame.name:SetText("?")
        --         end
        --     end
        --     return;
        -- end)
    end
end

--Fired by player logout + cbs
local function SaveOptions()
    for key in pairs(savedValues_DB) do
        if (savedValues_DB[key] ~= nil and savedValues_DB[key] ~= "") then
            SortGroupInformation[key] = savedValues_DB[key];
        end
    end
end

local function createFrame()
    Main_Frame.name = "SortGroup";
    Main_Title:SetFont("Fonts\\FRIZQT__.TTF", 18);
    Main_Title:SetTextColor(1, 0.8, 0);
    Main_Title:SetPoint("TOPLEFT", 12, -18);
    Main_Title:SetText("SortGroup");

    InterfaceOptions_AddCategory(Main_Frame);
end

local function createText()
    Main_Text_Version:SetPoint("TOPLEFT", 20, -45);
    Main_Text_Version:SetFontObject('p', 'GameTooltipTextSmall');
    Main_Text_Version:SetText(intern_versionOutput);
    Main_Text_Version:SetSize(string.len(intern_versionOutput), 10);

    Main_Text_Author:SetPoint("TOPLEFT", 20, -55);
    Main_Text_Author:SetFontObject('p', 'GameFontHighlightSmall');
    Main_Text_Author:SetText(intern_authorOutput);
    Main_Text_Author:SetSize(string.len(intern_authorOutput), 10);
end

local function createCheckbox()
    --the three main cbs
    Main_cb_Top:SetPoint("TOPLEFT", Main_Title, 10, -100);
    Main_cb_Bottom:SetPoint("TOPLEFT", Main_Title, 10, -200);
    -- Main_cb_Middle:SetPoint("TOPLEFT", Main_Title, 10, -300);

    --cb chidlren
    Main_cb_TopDescending:SetPoint("TOPLEFT", 30, -30);
    Main_cb_TopAscending:SetPoint("TOPLEFT", 30, -55);
    Main_cb_BottomDescending:SetPoint("TOPLEFT", 30, -30);
    Main_cb_BottomAscending:SetPoint("TOPLEFT", 30, -55);
    -- Main_cb_MiddleParty1Top:SetPoint("TOPLEFT", 30, -30);
    -- Main_cb_MiddleParty2Top:SetPoint("TOPLEFT", 30, -55);

    --set Text to cbs
    --Main frame
    getglobal(Main_cb_Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Top_Text"], "white"));
    getglobal(Main_cb_Bottom:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Bottom_Text"], "white"));
    -- getglobal(Main_cb_Middle:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Middle_Text"], "white"))
    getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],
        "white"));
    getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"], "white"));
    getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],
        "white"));
    getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],
        "white"));
    -- getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],
    --     "white"));
    -- getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],
    --     "white"));

    --Option frame
    Option_cb_ChatMessagesOn:SetPoint("TOPLEFT", Main_Title, 400, -100);


    getglobal(Option_cb_ChatMessagesOn:GetName() .. 'Text'):SetText(ColorText(L[
        "SortGroup_Option_cb_ChatMessagesOn_Text"], "white"));
end

--*End Creating*
local function loadData()
    --load defaults first
    for key in pairs(defaultValues_DB) do
        savedValues_DB[key] = defaultValues_DB[key];
    end

    --load saved data, fallback are the defaulValues
    for key in pairs(SortGroupInformation) do
        if (SortGroupInformation[key] ~= nil and SortGroupInformation[key] ~= "") then
            savedValues_DB[key] = SortGroupInformation[key];
        end
    end
end

--Events
local function frameEvent()
    Main_Frame:RegisterEvent("COMPACT_UNIT_FRAME_PROFILES_LOADED");
    Main_Frame:RegisterEvent("PLAYER_LOGOUT");
    Main_Frame:RegisterEvent("PLAYER_REGEN_DISABLED");
    Main_Frame:RegisterEvent("PLAYER_REGEN_ENABLED");
    Main_Frame:RegisterEvent("GROUP_ROSTER_UPDATE");
    Main_Frame:SetScript("OnEvent",
        function(self, event, ...)
            if (event == "PLAYER_LOGOUT") then
                SaveOptions();
                Main_Frame:UnregisterEvent(event);
            elseif (event == "PLAYER_REGEN_DISABLED") then
                internValues_DB.inCombat = true;
            elseif (event == "PLAYER_REGEN_ENABLED") then
                internValues_DB.inCombat = false;

                ApplySort();

                for k, v in pairs(UpdateTable) do
                    UpdateTable[k] = nil
                    _G[v](_G[k])
                end
            elseif (event == "GROUP_ROSTER_UPDATE") then
                ApplySort();
            elseif (event == "COMPACT_UNIT_FRAME_PROFILES_LOADED") then
                loadData();
                UpdateComboBoxes();

                --Get informations
                resetRaidContainer(); -- hooks
                internValues_DB.showChatMessages = true;

                ApplySort();

                Main_Frame:UnregisterEvent(event);
            end
        end);
end

--ComboBox Events
local function checkBoxEvent()

    --Combobox Top
    Main_cb_Top:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_Top:GetChecked() == true) then
                    savedValues_DB.Top = true;
                    savedValues_DB.Bottom = false;
                    savedValues_DB.Middle = false;
                    if (Main_cb_TopDescending:GetChecked() == false and Main_cb_TopAscending:GetChecked() == false) then
                        savedValues_DB.TopDescending = true;
                    end
                elseif (Main_cb_Top:GetChecked() == false) then
                    savedValues_DB.Top = false;
                end
                SaveOptions();
                UpdateComboBoxes();
                ApplySort();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_Top:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Top_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Top_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_Top:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Bottom
    Main_cb_Bottom:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_Bottom:GetChecked() == true) then
                    savedValues_DB.Top = false;
                    savedValues_DB.Bottom = true;
                    savedValues_DB.Middle = false;
                    if (Main_cb_BottomDescending:GetChecked() == false and Main_cb_BottomAscending:GetChecked() == false
                        ) then
                        savedValues_DB.BottomAscending = true;
                        Main_cb_BottomAscending:SetChecked(true);
                    end
                elseif (Main_cb_Bottom:GetChecked() == false) then
                    savedValues_DB.Bottom = false;
                end
                SaveOptions();
                UpdateComboBoxes();
                ApplySort();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_Bottom:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Bottom_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Bottom_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_Bottom:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Middle
    Main_cb_Middle:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_Middle:GetChecked() == true) then
                    savedValues_DB.Top = false;
                    savedValues_DB.Bottom = false;
                    savedValues_DB.Middle = true;
                    if (Main_cb_MiddleParty1Top:GetChecked() == false and Main_cb_MiddleParty2Top:GetChecked() == false) then
                        savedValues_DB.MiddleParty1Top = true;
                        Main_cb_MiddleParty1Top:SetChecked(true);
                    end
                elseif (Main_cb_Middle:GetChecked() == false) then
                    savedValues_DB.Middle = false;
                end
                SaveOptions();
                UpdateComboBoxes();
                ApplySort();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_Middle:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Middle_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Middle_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_Middle:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Main_cb_TopDescending
    Main_cb_TopDescending:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_TopDescending:GetChecked() == true) then
                    savedValues_DB.TopDescending = true;
                    savedValues_DB.TopAscending = false;
                elseif (Main_cb_TopDescending:GetChecked() == false) then
                    savedValues_DB.TopDescending = false;
                end
                SaveOptions();
                UpdateComboBoxes();
                ApplySort();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_TopDescending:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Descending_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Descending_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_TopDescending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Main_cb_TopDescending
    Main_cb_TopAscending:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_TopAscending:GetChecked() == true) then
                    savedValues_DB.TopDescending = false;
                    savedValues_DB.TopAscending = true;
                elseif (Main_cb_TopAscending:GetChecked() == false) then
                    savedValues_DB.TopAscending = false;
                end
                SaveOptions();
                UpdateComboBoxes();
                ApplySort();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_TopAscending:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Ascending_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Ascending_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_TopAscending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Main_cb_TopDescending
    Main_cb_BottomDescending:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_BottomDescending:GetChecked() == true) then
                    savedValues_DB.BottomDescending = true;
                    savedValues_DB.BottomAscending = false;
                elseif (Main_cb_BottomDescending:GetChecked() == false) then
                    savedValues_DB.BottomDescending = false;
                end
                SaveOptions();
                ApplySort();
                UpdateComboBoxes();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_BottomDescending:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Descending_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Descending_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_BottomDescending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Main_cb_TopDescending
    Main_cb_BottomAscending:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_BottomAscending:GetChecked() == true) then
                    savedValues_DB.BottomDescending = false;
                    savedValues_DB.BottomAscending = true;
                elseif (Main_cb_BottomAscending:GetChecked() == false) then
                    savedValues_DB.BottomAscending = false;
                end
                SaveOptions();
                ApplySort();
                UpdateComboBoxes();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_BottomAscending:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Ascending_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Ascending_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_BottomAscending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Main_cb_MiddleParty1Top
    Main_cb_MiddleParty1Top:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_MiddleParty1Top:GetChecked() == true) then
                    savedValues_DB.MiddleParty1Top = true;
                    savedValues_DB.MiddleParty2Top = false;
                elseif (Main_cb_MiddleParty1Top:GetChecked() == false) then
                    savedValues_DB.MiddleParty1Top = false;
                end
                SaveOptions();
                ApplySort();
                UpdateComboBoxes();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_MiddleParty1Top:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Party1Top_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Party1Top_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_MiddleParty1Top:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox Main_cb_MiddleParty2Top
    Main_cb_MiddleParty2Top:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                internValues_DB.showChatMessages = true;
                if (Main_cb_MiddleParty2Top:GetChecked() == true) then
                    savedValues_DB.MiddleParty1Top = false;
                    savedValues_DB.MiddleParty2Top = true;
                elseif (Main_cb_MiddleParty2Top:GetChecked() == false) then
                    savedValues_DB.MiddleParty2Top = false;
                end
                SaveOptions();
                ApplySort();
                UpdateComboBoxes();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Main_cb_MiddleParty2Top:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Main_cb_Party2Top_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_Party2Top_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Main_cb_MiddleParty2Top:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

    --Combobox savedValues_DB.ChatMessagesOn
    Option_cb_ChatMessagesOn:SetScript("OnClick",
        function()
            if (internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true) then
                if (Option_cb_ChatMessagesOn:GetChecked() == true) then
                    savedValues_DB.ChatMessagesOn = true;
                    print(ColorText(L["SortGroup_sort_chat_Messages_On_output"], "option"));
                elseif (Option_cb_ChatMessagesOn:GetChecked() == false) then
                    savedValues_DB.ChatMessagesOn = false;
                end
                SaveOptions();
                UpdateComboBoxes();
            else
                UpdateComboBoxes();
                if (savedValues_DB.ChatMessagesOn == true) then
                    print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
                end
            end
        end);
    Option_cb_ChatMessagesOn:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(L["SortGroup_Option_cb_ChatMessagesOn_Text"] ..
                "\n\n" .. ColorText(L["SortGroup_Main_cb_ChatMessagesOn_ToolTip"], "white"), nil, nil, nil, 1);
            GameTooltip:Show();
        end);
    Option_cb_ChatMessagesOn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end

---End Events
local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");
loader:SetScript("OnEvent", function(self, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == "SortGroup") then
        createFrame();
        createText();
        createCheckbox();
        frameEvent();
        checkBoxEvent();
        self:UnregisterEvent("ADDON_LOADED");
    end
end);
