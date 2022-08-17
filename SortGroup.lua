SortGroupInformation = {};
local L = LibStub("AceLocale-3.0"):GetLocale("SortGroup");
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0");

-- Main Frame
local Main_Frame = CreateFrame("Frame", "MainPanel", InterfaceOptionsFramePanelContainer);
local Option_Frame = CreateFrame("Frame", "OptionPanel", Main_Frame);

--default values
local defaultValues_DB = {
	Top = true,
	TopDescending = true,
	TopAscending = false,
	Bottom = false,
	BottomDescending = false,
	BottomAscending = false,
	Middle = false,
	MiddleParty1Top = false,
	MiddleParty2Top = false,
	AlwaysActive = false,
	AutoActivate = true,
	Profile = nil,
	RaidProfileBlockInCombat = true,
	ChatMessagesOn = true,
	ShowGroupMembersInCombat = false,
	VisibilityInCombat = true
}

--saved values, loaded by loadData()
local savedValues_DB = {};

-- Options, which are only changeable here atm. These can cause taint and errors, but can also be useful. Activate on your own "risk"  
local changeableValues_DB = {
	EscIntepretAsOK = false, --Pressing Cancel/Esc will be interpretet as OK
	ChangesInCombat = false; --You can change options in combat
}

--values changes by events
local internValues_DB = {
	showChatMessages = false, -- true when "PLAYER_ENTERING_WORLD" fired or cb Event gets triggered
	inCombat = false, -- true when "PLAYER_REGEN_DISABLED" fired	
	ddmItems = {}, -- ddm profile content
	GroupMembersOoC = 0 --value 
}

local UpdateTable = {}; --saved functions, blocked in combat
local manager = CompactRaidFrameManager; -- CompactRaidFrameManager Container for sort options -> CompactRaidFrameManager_SetSortMode()
--*End Variables*

--Text
local Main_Title = Main_Frame:CreateFontString("MainTitle", "OVERLAY", "GameFontHighlight");
local Option_Title = Option_Frame:CreateFontString("OptionTitle", "OVERLAY", "GameFontHighlight");
local Main_Text_Version = CreateFrame("SimpleHTML", "MainTextVersion", Main_Frame);
local Main_Text_Author = CreateFrame("SimpleHTML", "MainTextAuthor", Main_Frame); 
local intern_version = "5.0.4 Beta";
local intern_versionOutput = "|cFF00FF00Version|r  " .. intern_version;
local intern_author = "Collabo93";
local intern_authorOutput = "|cFF00FF00Author|r   " .. intern_author;
local Option_Text_General = CreateFrame("SimpleHTML", "OptionTextGeneral", Option_Frame);
local Option_Text_Combat = CreateFrame("SimpleHTML", "OptionTextCombat", Option_Frame);

--Checkboxes
local Main_cb_Top = CreateFrame("CheckButton", "MainCbTop", Main_Frame, "UICheckButtonTemplate");
local Main_cb_Bottom = CreateFrame("CheckButton", "MainCbBottom", Main_Frame, "UICheckButtonTemplate");
local Main_cb_Middle = CreateFrame("CheckButton", "MainCbMiddle", Main_Frame, "UICheckButtonTemplate");
local Main_cb_TopDescending = CreateFrame("CheckButton", "MainCbTopDescending", Main_cb_Top, "UICheckButtonTemplate");
local Main_cb_TopAscending = CreateFrame("CheckButton", "MainCbTopAscending", Main_cb_Top, "UICheckButtonTemplate");
local Main_cb_BottomDescending = CreateFrame("CheckButton", "MainCbBottomDescending", Main_cb_Bottom, "UICheckButtonTemplate");
local Main_cb_BottomAscending = CreateFrame("CheckButton", "MainCbBottomAscending", Main_cb_Bottom, "UICheckButtonTemplate");
local Main_cb_MiddleParty1Top = CreateFrame("CheckButton", "MainCbMiddleParty1Top", Main_cb_Middle, "UICheckButtonTemplate");
local Main_cb_MiddleParty2Top = CreateFrame("CheckButton", "MainCbMiddleParty2Top", Main_cb_Middle, "UICheckButtonTemplate");
local Main_cb_AlwaysActive = CreateFrame("CheckButton", "MainCbAlwaysActive", Main_Frame, "UICheckButtonTemplate");
local Main_cb_AutoActivate = CreateFrame("CheckButton", "MainCbAutoActivate", Main_cb_AlwaysActive, "UICheckButtonTemplate");
local Option_cb_ChatMessagesOn = CreateFrame("CheckButton", "OptionCbChatMessagesOn", Option_Text_General, "UICheckButtonTemplate");
local Option_cb_RaidProfilesUpdateInCombat = CreateFrame("CheckButton", "OptionCbRaidProfilesUpdateInCombat", Option_Text_Combat, "UICheckButtonTemplate");
local Option_cb_ShowGroupMembersInCombat = CreateFrame("CheckButton", "OptionCbShowGroupMembersInCombat", Option_cb_RaidProfilesUpdateInCombat, "UICheckButtonTemplate");
local Option_cb_VisibilityInCombat = CreateFrame("CheckButton", "OptionCbVisibilityInCombat", Option_cb_RaidProfilesUpdateInCombat, "UICheckButtonTemplate");

--DropDownMenu
--local Main_ddm_Profiles = CreateFrame("Button", "MainDdmProfiles", Main_cb_AutoActivate, "UIDropDownMenuTemplate");
local Main_ddm_Profiles = LibDD:Create_UIDropDownMenu("MainDdmProfiles", Main_cb_AutoActivate);
--*End Variables*

local function ColorText(text, operation)
	local defaultColor = "#FFFFFF";
	if ( operation == "option" ) then
		local cacheText = text:gsub("SortGroup:" , function(cap)
			cap = cap:sub(1, -1);
			local color = "|cff00FF7F" or defaultColor;
			return color..cap.."|r";
		end)
		return cacheText;
	elseif ( operation == "disable" ) then
		local color = "|cff888888" or defaultColor;
		return color..text;
	elseif ( operation == "green" ) then
		local color = "|cff00ff00" or defaultColor;
		return color..text;
	elseif ( operation == "red" ) then
		local color = "|cffff0000" or defaultColor;
		return color..text;
	elseif ( operation == "white" ) then
		local color = "|cffffffff" or defaultColor;
		return color..text;
	end
end

--Fills internValues_DB.ddmItems with raidprofiles and checks if raidprofil exists
local function ProfileExists(raidProfile)
	local raidprofilexists = false;
	internValues_DB.ddmItems = {};
	for i=1, GetNumRaidProfiles(), 1 do
		internValues_DB.ddmItems[i] = GetRaidProfileName(i);
		if ( internValues_DB.ddmItems[i] == raidProfile ) then
			raidprofilexists = true;
		end
	end
	return raidprofilexists;
end

--Set the first Profile to default
--Used by first login event and by ApplySort()
local function SetDefaultProfile()
	local cachePrintSendSortOptionToSortBy = L["SortGroup_RaidProfil_dont_exists_output"]:gsub("'replacement'", savedValues_DB.Profile);
	savedValues_DB.Profile = GetRaidProfileName(1);
	if ( savedValues_DB.ChatMessagesOn == true ) then
		print(ColorText(cachePrintSendSortOptionToSortBy:gsub("'replacement2'", savedValues_DB.Profile), "option"));
	end
	LibDD:UIDropDownMenu_SetText(Main_ddm_Profiles, savedValues_DB.Profile);
end

local function ActivateRaidProfile(profile)
	CompactUnitFrameProfiles_ActivateRaidProfile(profile);
end

-- Possible switch by Group_Roster, OK button, COMPACT_UNIT_FRAME_PROFILES_LOADED, PLAYER_REGEN_ENABLED, Main_cb_AutoActivate or Main_ddm_Profiles
local function SwitchRaidProfiles()
	if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
		local member = tonumber(GetNumGroupMembers());
		if ( HasLoadedCUFProfiles() == true and savedValues_DB.Profile ~= nil ) then
			if ( member <= 5 and ProfileExists(savedValues_DB.Profile) and IsInGroup()) then
				if ( GetActiveRaidProfile() ~= savedValues_DB.Profile  and savedValues_DB.AutoActivate == true ) then
					ActivateRaidProfile(savedValues_DB.Profile);
					if ( savedValues_DB.ChatMessagesOn == true ) then
						print( ColorText(L["SortGroup_RaidProfil_changed_output"]:gsub("'replacement'", savedValues_DB.Profile), "option") );
					end
				end
			end
		end
	end
end

--Top, Descending
local function SortTopDescending()
	local CRFSort_TopDownwards = function(t1, t2)
		if UnitIsUnit(t1, "player") then 
			return true;
		elseif UnitIsUnit(t2, "player") then 
			return false;
		else 
			return t1 < t2;
		end 
	end
	CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_TopDownwards);
end

--Top, Ascending
local function SortTopAscending()
	local CRFSort_TopUpwards = function(t1, t2)
		if UnitIsUnit(t1, "player") then 
			return true;
		elseif UnitIsUnit(t2, "player") then 
			return false;
		else 
			return t1 > t2;
		end 
	end
	CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_TopUpwards);
end

--Bottom, Descending
local function SortBottomDescending()
	local CRFSort_BottomUpwards = function(t1, t2)
		if UnitIsUnit(t1, "player") then 
			return false;
		elseif UnitIsUnit(t2, "player") then 
			return true; 
		else 
			return t1 > t2;
		end 
	end
	CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_BottomUpwards);
end

--Bottom, Ascending
local function SortBottomAscending()
	local CRFSort_BottomDownwards = function(t1, t2)
		if UnitIsUnit(t1, "player") then 
			return false;
		elseif UnitIsUnit(t2, "player") then 
			return true; 
		else 
			return t1 < t2;
		end 
	end
	CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_BottomDownwards);
end

--Middle, Party1 on Top
local function SortMiddleParty1Top()
	local CRFSort_MiddleParty1Top = function(t1, t2)
		if UnitIsUnit(t1, "party1") then
			return true;
		elseif UnitIsUnit(t1, "player") or UnitIsUnit(t2, "player") or UnitIsUnit(t2, "party1") then 
			return false; 			
		else 
			return t1 > t2;
		end 
	end
	CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_MiddleParty1Top);
end

--Middle, Party2 on Top
local function SortMiddleParty2Top()
	local CRFSort_MiddleParty2Top = function(t1, t2)
		if UnitIsUnit(t1, "party2") then
			return true;
		elseif UnitIsUnit(t1, "player") or UnitIsUnit(t2, "player") or UnitIsUnit(t2, "party2") then 
			return false; 			
		else 
			return t1 > t2;
		end 
	end
	CompactRaidFrameContainer_SetFlowSortFunction(manager.container, CRFSort_MiddleParty2Top);
end

--Check if KeepGroupsTogether is checked -> needs to be disabled
local function CheckProfileOptions()
	if ( CompactRaidFrameManager_GetSetting("KeepGroupsTogether") == 1 ) then
		CompactRaidFrameManager_SetSetting("KeepGroupsTogether", "0")
		if ( savedValues_DB.ChatMessagesOn == true and internValues_DB.showChatMessages == true ) then	
			print(ColorText(L["SortGroup_Keep_Group_Together_Active_output"], "option"));
			internValues_DB.showChatMessages = false;
		end
	end
end

--Decision which sort option to activate
local function ApplySort()	

	--if always active is off and the saved profile doesnt exist, load a new profile as default
	if ( savedValues_DB.AlwaysActive == false ) then
		if ( not ProfileExists(savedValues_DB.Profile) ) then
			SetDefaultProfile();
		end
	end

	--combat status check
	if ( internValues_DB.inCombat == false ) then

		--Group status check
		if ( IsInGroup() and GetNumGroupMembers() <= 5 and HasLoadedCUFProfiles() ) then
			
			--Check if current Profile matches with saved Profile, and AlwaysActive is off
			if ( GetActiveRaidProfile() ~= savedValues_DB.Profile and savedValues_DB.AlwaysActive == false ) then
				if ( internValues_DB.showChatMessages == true ) then
					if ( savedValues_DB.ChatMessagesOn == true ) then
						print(ColorText(L["SortGroup_RaidProfil_Doesnt_match_output"], "option"));
					end
				end
				
			--Everything is fine, sorting can get applied
			else
				if ( savedValues_DB.Top ) then
					if ( savedValues_DB.TopDescending == true ) then
						if ( internValues_DB.showChatMessages == true ) then
							if ( savedValues_DB.AlwaysActive == true ) then
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_descending_AlwaysActive_output"], "option"));
								end
							else
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_descending_output"]:gsub("'replacement'", savedValues_DB.Profile), "option"));
								end
							end
						end
						CheckProfileOptions();
						SortTopDescending();
					end
					if ( savedValues_DB.TopAscending == true ) then
						if ( internValues_DB.showChatMessages == true ) then
							if ( savedValues_DB.AlwaysActive == true ) then
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_ascending_AlwaysActive_output"], "option"));
								end
							else
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_ascending_output"]:gsub("'replacement'", savedValues_DB.Profile), "option"));
								end
							end
						end
						CheckProfileOptions();
						SortTopAscending();
					end
				elseif(savedValues_DB.Bottom) then 
					if ( savedValues_DB.BottomDescending == true ) then
						if ( internValues_DB.showChatMessages == true ) then
							if ( savedValues_DB.AlwaysActive == true ) then
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_bottom_descending_AlwaysActive_output"], "option"));
								end
							else
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_bottom_descending_output"]:gsub("'replacement'", savedValues_DB.Profile), "option"));
								end
							end
						end
						CheckProfileOptions();
						SortBottomAscending();
					end
					if ( savedValues_DB.BottomAscending == true ) then
						if ( internValues_DB.showChatMessages == true ) then
							if ( savedValues_DB.AlwaysActive == true ) then
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_bottom_ascending_AlwaysActive_output"], "option"));
								end
							else
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_bottom_ascending_output"]:gsub("'replacement'", savedValues_DB.Profile), "option"));
								end
							end
						end
						CheckProfileOptions();
						SortBottomDescending();
					end
				elseif(savedValues_DB.Middle) then 
					if ( savedValues_DB.MiddleParty1Top == true ) then
						if ( internValues_DB.showChatMessages == true ) then
							if ( savedValues_DB.AlwaysActive == true ) then
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_party1_AlwaysActive_output"], "option"));
								end
							else
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_party1_output"]:gsub("'replacement'", savedValues_DB.Profile), "option"));
								end
							end
						end
						CheckProfileOptions();
						SortMiddleParty1Top();
					end
					if ( savedValues_DB.MiddleParty2Top == true ) then
						if ( internValues_DB.showChatMessages == true ) then
							if ( savedValues_DB.AlwaysActive == true ) then
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_party2_AlwaysActive_output"], "option"));
								end
							else
								if ( savedValues_DB.ChatMessagesOn == true ) then
									print(ColorText(L["SortGroup_sort_top_party2_output"]:gsub("'replacement'", savedValues_DB.Profile), "option"));
								end
							end
						end
						CheckProfileOptions();
						SortMiddleParty2Top();
					end
					
				--No sorting option checked
				else
					if ( internValues_DB.showChatMessages == true ) then
						if ( savedValues_DB.ChatMessagesOn == true ) then
							print (ColorText(L["SortGroup_sort_no_output"], "option"));
						end	
					end
				end
			end	
		end
	end
	
	internValues_DB.showChatMessages = false;
end

--Update cbs - Checked/Unchecked, Text + Text Color, Enabled/Disabledj
local function UpdateComboBoxes()

	--Load Raid Profile
	if ( savedValues_DB.AutoActivate == true ) then
		Main_cb_AutoActivate:SetChecked(true);
		getglobal(Main_cb_AutoActivate:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_AutoActivate_Text"],"white"));
	else
		Main_cb_AutoActivate:SetChecked(false);
	end
	
	--Always Active
	if ( savedValues_DB.AlwaysActive == true ) then
		UIDropDownMenu_DisableDropDown(Main_ddm_Profiles);
		Main_cb_AutoActivate:Disable();
		getglobal(Main_cb_AutoActivate:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_AutoActivate_Text"],"disable"));
		Main_cb_AlwaysActive:SetChecked(true);
	else
		savedValues_DB.AlwaysActive = false;
		Main_cb_AutoActivate:Enable();
		getglobal(Main_cb_AutoActivate:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_AutoActivate_Text"], "white"));
		if ( Main_cb_AutoActivate:GetChecked() == true ) then
			UIDropDownMenu_EnableDropDown(Main_ddm_Profiles);
		end
		Main_cb_AlwaysActive:SetChecked(false);
	end
	
	--Player Top/Bottom/Middle
	if ( savedValues_DB.Top == true ) then
		Main_cb_Top:SetChecked(true);
		Main_cb_Bottom:SetChecked(false);
		Main_cb_Middle:SetChecked(false);
		
		Main_cb_TopDescending:Enable();
		Main_cb_TopAscending:Enable();
		Main_cb_BottomDescending:Disable();
		Main_cb_BottomAscending:Disable();
		Main_cb_MiddleParty1Top:Disable();
		Main_cb_MiddleParty2Top:Disable();
		
		getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"], "white"));
		getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"], "white"));
		getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],"disable"));
		getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],"disable"));
		getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],"disable"));
		getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],"disable"));
	elseif ( savedValues_DB.Bottom == true ) then
		Main_cb_Top:SetChecked(false);
		Main_cb_Bottom:SetChecked(true);
		Main_cb_Middle:SetChecked(false);
		
		Main_cb_TopDescending:Disable();
		Main_cb_TopAscending:Disable();
		Main_cb_BottomDescending:Enable();
		Main_cb_BottomAscending:Enable();
		Main_cb_MiddleParty1Top:Disable();
		Main_cb_MiddleParty2Top:Disable();
		
		getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],"disable"));
		getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],"disable"));
		getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"], "white"));
		getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"], "white"));
		getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],"disable"));
		getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],"disable"));
	elseif ( savedValues_DB.Middle == true ) then
		Main_cb_Top:SetChecked(false);
		Main_cb_Bottom:SetChecked(false);
		Main_cb_Middle:SetChecked(true);
		
		Main_cb_TopDescending:Disable();
		Main_cb_TopAscending:Disable();
		Main_cb_BottomDescending:Disable();
		Main_cb_BottomAscending:Disable();
		Main_cb_MiddleParty1Top:Enable();
		Main_cb_MiddleParty2Top:Enable();
		
		getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],"disable"));
		getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],"disable"));
		getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"], "disable"));
		getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"], "disable"));
		getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],"white"));
		getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],"white"));
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
		
		getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],"disable"));
		getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],"disable"));
		getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"],"disable"));
		getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"],"disable"));
		getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"],"disable"));
		getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"],"disable"));
	end
	
	--Top, Ascending/Descending
	if ( savedValues_DB.TopDescending == true ) then
		Main_cb_TopDescending:SetChecked(true);
		Main_cb_TopAscending:SetChecked(false);
	elseif ( savedValues_DB.TopAscending == true ) then
		Main_cb_TopAscending:SetChecked(true);
		Main_cb_TopDescending:SetChecked(false);
	else 	
		Main_cb_TopDescending:SetChecked(false);
		Main_cb_TopAscending:SetChecked(false);
	end
	
	--Bottom, Ascending/Descending
	if ( savedValues_DB.BottomDescending == true ) then
		Main_cb_BottomDescending:SetChecked(true);
		Main_cb_BottomAscending:SetChecked(false);
	elseif ( savedValues_DB.BottomAscending == true ) then
		Main_cb_BottomDescending:SetChecked(false);
		Main_cb_BottomAscending:SetChecked(true);
	else
		Main_cb_BottomDescending:SetChecked(false);
		Main_cb_BottomAscending:SetChecked(false);
	end
	
	--Middle, Party 1 Top/ Party 2 Top
	if ( savedValues_DB.MiddleParty1Top == true ) then
		Main_cb_MiddleParty1Top:SetChecked(true);
		Main_cb_MiddleParty2Top:SetChecked(false);
	elseif ( savedValues_DB.MiddleParty2Top == true ) then
		Main_cb_MiddleParty1Top:SetChecked(false);
		Main_cb_MiddleParty2Top:SetChecked(true);
	else
		Main_cb_MiddleParty1Top:SetChecked(false);
		Main_cb_MiddleParty2Top:SetChecked(false);
	end
	
	--Chat messages
	if ( savedValues_DB.ChatMessagesOn == true ) then
		Option_cb_ChatMessagesOn:SetChecked(true);
	else 
		Option_cb_ChatMessagesOn:SetChecked(false);
	end
	
	--Raid Frames in combat
	if ( savedValues_DB.RaidProfileBlockInCombat == true ) then
		Option_cb_RaidProfilesUpdateInCombat:SetChecked(true);
		Option_cb_ShowGroupMembersInCombat:Enable();
		Option_cb_VisibilityInCombat:Enable();
		getglobal(Option_cb_ShowGroupMembersInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_ShowGroupMembersInCombat_Text"], "white"));
		getglobal(Option_cb_VisibilityInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_VisibilityInCombat_Text"], "white"));
	else
		Option_cb_RaidProfilesUpdateInCombat:SetChecked(false);
		Option_cb_ShowGroupMembersInCombat:Disable();
		Option_cb_VisibilityInCombat:Disable();
		getglobal(Option_cb_ShowGroupMembersInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_ShowGroupMembersInCombat_Text"], "disable"));
		getglobal(Option_cb_VisibilityInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_VisibilityInCombat_Text"], "disable"));
	end
	
	--Message for Group Members, while in combat
	if ( savedValues_DB.ShowGroupMembersInCombat == true ) then
		Option_cb_ShowGroupMembersInCombat:SetChecked(true);
	else
		Option_cb_ShowGroupMembersInCombat:SetChecked(false);
	end
	
	--Visibility/Fading, while in combat
	if ( savedValues_DB.VisibilityInCombat == true ) then
		Option_cb_VisibilityInCombat:SetChecked(true);
	else
		Option_cb_VisibilityInCombat:SetChecked(false);
	end
end
	
--Hooks for container updates
--Isnt perfect, but prevents some taints associated by the sort implementation
local function resetRaidContainer()	
	if ( savedValues_DB.RaidProfileBlockInCombat == true ) then	
		
		--Hook CompactRaidFrameContainer_TryUpdate
		--Hold if in combat, release if not
		local origCompactRaidFrameContainer_TryUpdate = CompactRaidFrameContainer_TryUpdate;
		CompactRaidFrameContainer_TryUpdate = function(self)
			if ( internValues_DB.inCombat == true ) then
				UpdateTable[self:GetName()] = "CompactRaidFrameContainer_TryUpdate";
			else
				return origCompactRaidFrameContainer_TryUpdate(self);
			end
		end	
		
		--Hook CompactRaidGroup_UpdateUnits
		local origCompactRaidGroup_UpdateUnits = CompactRaidGroup_UpdateUnits;
		CompactRaidGroup_UpdateUnits = function(self)
			if ( internValues_DB.inCombat == true ) then
				UpdateTable[self:GetName()] = "CompactRaidGroup_UpdateUnits";
			else
				return origCompactRaidGroup_UpdateUnits(self);
			end
		end
		
		hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)

			--check if not empty
			if frame and frame.displayedUnit then
			
				--ignore nameplates. We dont wont to touch those
				if string.find(frame.displayedUnit,"nameplate") then
					return;
					
				--unit exists
				elseif UnitExists(frame.displayedUnit) then
					frame:SetScript("OnEnter", UnitFrame_OnEnter);
				
				--unit doesnt exist -> make the frame unclickable to prevent taint
				else	
					frame:SetScript("OnEnter", nil)
					frame.name:SetText("?")
				end
			end
			return;
		end)
		
		if ( savedValues_DB.VisibilityInCombat == true ) then
			--post hook CompactUnitFrame_UpdateInRange
			--if unit doesnt exist, set Alpha value for visual reference
			hooksecurefunc("CompactUnitFrame_UpdateInRange", function(self)
				if self and self.displayedUnit then
					if string.find(self.displayedUnit,"nameplate") then
						return;
					elseif not UnitExists(self.displayedUnit) then
						self:SetAlpha(0.1);
					end
				end	
				return;
			end)
		end	
		
	end
end

--Fired by player logout + cbs
local function SaveOptions()
	for key in pairs(savedValues_DB) do
		if ( savedValues_DB[key] ~= nil and savedValues_DB[key] ~= "" ) then
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
	
	--esc handle. Cancel = Reset. So sorting needs to get reapplied
	if ( EscIntepretAsOK == true ) then
		InterfaceOptionsFrameCancel:SetScript("OnClick", function()
			InterfaceOptionsFrameOkay:Click();
		end)
	else
		Main_Frame.cancel = function(Main_Frame)
			ApplySort();
		end
	end
	
	Main_Frame.okay = function(Main_Frame)
		SwitchRaidProfiles();
	end
	InterfaceOptions_AddCategory(Main_Frame);
	
	Option_Frame.name = L["SortGroup_Option_Frame_Text"];
	Option_Title:SetFont("Fonts\\FRIZQT__.TTF", 18);
	Option_Title:SetTextColor(1, 0.8, 0);
    Option_Title:SetPoint("TOPLEFT", 12, -18);
    Option_Title:SetText(L["SortGroup_Option_Frame_Text"].."|r");
	Option_Frame.parent = Main_Frame.name;
	InterfaceOptions_AddCategory(Option_Frame);
end

local function createText()
	Main_Text_Version:SetPoint("TOPLEFT", 20, -45);
	Main_Text_Version:SetFontObject(GameFontHighlightSmall);
	Main_Text_Version:SetText(intern_versionOutput);
	Main_Text_Version:SetSize(string.len(intern_versionOutput), 10);
	
	Main_Text_Author:SetPoint("TOPLEFT", 20 ,-55);
	Main_Text_Author:SetFontObject(GameFontHighlightSmall);
	Main_Text_Author:SetText(intern_authorOutput);
	Main_Text_Author:SetSize(string.len(intern_authorOutput), 10);
	
	Option_Text_General:SetPoint("TOPLEFT", 40, -80);
	Option_Text_General:SetFontObject(GameFontHighlightMedium);
	Option_Text_General:SetText(L["SortGroup_Option_Text_General_Text"]);
	Option_Text_General:SetSize(string.len(L["SortGroup_Option_Text_General_Text"]), 10);
	
	Option_Text_Combat:SetPoint("TOPLEFT", 40, -190);
	Option_Text_Combat:SetFontObject(GameFontHighlightMedium);
	Option_Text_Combat:SetText(L["SortGroup_Option_Text_Combat_Text"]);
	Option_Text_Combat:SetSize(string.len(L["SortGroup_Option_Text_Combat_Text"]), 10);
end

local function createCheckbox()	
	--the three main cbs
	Main_cb_Top:SetPoint("TOPLEFT", Main_Title, 10, -100);
	Main_cb_Bottom:SetPoint("TOPLEFT", Main_Title, 10, -200);
	Main_cb_Middle:SetPoint("TOPLEFT", Main_Title, 10, -300);
	
	--cb chidlren
	Main_cb_TopDescending:SetPoint("TOPLEFT", 30, -30);
	Main_cb_TopAscending:SetPoint("TOPLEFT", 30, -55);
	Main_cb_BottomDescending:SetPoint("TOPLEFT", 30, -30);
	Main_cb_BottomAscending:SetPoint("TOPLEFT", 30, -55);
	Main_cb_MiddleParty1Top:SetPoint("TOPLEFT", 30, -30);
	Main_cb_MiddleParty2Top:SetPoint("TOPLEFT", 30, -55);
	Main_cb_AlwaysActive:SetPoint("TOPLEFT", Main_Title, 340, -100);
	Main_cb_AutoActivate:SetPoint("TOPLEFT",30,-30);	
	
	--set Text to cbs
	--Main frame
	getglobal(Main_cb_Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Top_Text"], "white"));
	getglobal(Main_cb_Bottom:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Bottom_Text"], "white"));
	getglobal(Main_cb_Middle:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Middle_Text"], "white"))
	getglobal(Main_cb_TopDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"], "white"));
	getglobal(Main_cb_TopAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"], "white"));
	getglobal(Main_cb_BottomDescending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Descending_Text"], "white"));
	getglobal(Main_cb_BottomAscending:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Ascending_Text"], "white"));	
	getglobal(Main_cb_MiddleParty2Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party1Top_Text"], "white"));
	getglobal(Main_cb_MiddleParty1Top:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_Party2Top_Text"], "white"));	
	getglobal(Main_cb_AutoActivate:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_AutoActivate_Text"], "white"));
	getglobal(Main_cb_AlwaysActive:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Main_cb_AlwaysActive_Text"], "white"));
	
	--Option frame
	Option_cb_ChatMessagesOn:SetPoint("TOPLEFT", 15, -20);
	Option_cb_RaidProfilesUpdateInCombat:SetPoint("TOPLEFT", 15, -20);
	Option_cb_ShowGroupMembersInCombat:SetPoint("TOPLEFT", 30, -30);
	Option_cb_VisibilityInCombat:SetPoint("TOPLEFT", 30, -55);
	
	getglobal(Option_cb_ChatMessagesOn:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_ChatMessagesOn_Text"], "white"));	
	getglobal(Option_cb_RaidProfilesUpdateInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_Text"], "white"));
	getglobal(Option_cb_ShowGroupMembersInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_ShowGroupMembersInCombat_Text"], "white"));
	getglobal(Option_cb_VisibilityInCombat:GetName() .. 'Text'):SetText(ColorText(L["SortGroup_Option_cb_VisibilityInCombat_Text"], "white"));
end

--DropDownMenu creating, include items
local function createDropDownMenu()
	Main_ddm_Profiles.text = _G["L_MainDdmProfiles"];
	--Main_ddm_Profiles.text:SetText("Empty ddm");
	Main_ddm_Profiles:SetPoint("TOPLEFT", -10, -30);		
	Main_ddm_Profiles.initialize = function(self, level)
		if ( internValues_DB.inCombat == false and level == 1 ) then
			local info = LibDD:UIDropDownMenu_CreateInfo();
			ProfileExists(); --load data into ddm
			
			for i, value in pairs(internValues_DB.ddmItems) do
				if ( ProfileExists(value) == true ) then
					info.text = value;
					info.value = i;
					info.func = function(item)
						self.selectedID = item:GetID();
						self.text = item;
						self.value = i;
						savedValues_DB.Profile = value;
						LibDD:UIDropDownMenu_SetText(self, savedValues_DB.Profile);
						internValues_DB.showChatMessages = true;
						SwitchRaidProfiles();
					end
					info.checked = i == self.text;
					LibDD:UIDropDownMenu_AddButton(info, level);
					if ( savedValues_DB.Profile == info.text ) then
						LibDD:UIDropDownMenu_SetSelectedID(self, i);
					end
				end
			end
		else
			if ( savedValues_DB.ChatMessagesOn == true ) then
				print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
			end
		end
	end
	Main_ddm_Profiles:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_ddm_Profiles_Text"] .. "\n\n" .. ColorText(L["SortGroup_Main_ddm_Profiles_ToolTip"], "white"), nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_ddm_Profiles:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
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
	Main_Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	Main_Frame:RegisterEvent("PLAYER_LOGOUT");
	Main_Frame:RegisterEvent("PLAYER_REGEN_DISABLED");
	Main_Frame:RegisterEvent("PLAYER_REGEN_ENABLED");
	Main_Frame:RegisterEvent("GROUP_ROSTER_UPDATE");
	Main_Frame:SetScript("OnEvent", 
		function(self, event, ...)	
			if ( event == "PLAYER_LOGOUT" ) then 
				SaveOptions();
				Main_Frame:UnregisterEvent(event);
			elseif ( event == "PLAYER_REGEN_DISABLED" ) then
				internValues_DB.inCombat = true;
				internValues_DB.GroupMembersOoC = GetNumGroupMembers();
			elseif ( event == "PLAYER_REGEN_ENABLED" ) then
				internValues_DB.inCombat = false;
				internValues_DB.GroupMembersOoC = 0;
				
				SwitchRaidProfiles();
				ApplySort();
				
				for k, v in pairs(UpdateTable) do
					UpdateTable[k] = nil
					_G[v](_G[k])
				end
			elseif ( event == "GROUP_ROSTER_UPDATE" ) then
				SwitchRaidProfiles();
				ApplySort();
				
				if ( savedValues_DB.ShowGroupMembersInCombat == true ) then
					if ( internValues_DB.inCombat == true ) then
						local cacheText = L["SortGroup_numberOfMembers_output"];
						cacheText = cacheText:gsub("'replacement'", GetNumGroupMembers());
						if ( (GetNumGroupMembers() - internValues_DB.GroupMembersOoC) > 0 ) then
							cacheText = cacheText:gsub("'replacement2'", ColorText( (GetNumGroupMembers() - internValues_DB.GroupMembersOoC), "green" ) );
						elseif ( (GetNumGroupMembers() - internValues_DB.GroupMembersOoC) < 0 ) then
							cacheText = cacheText:gsub("'replacement2'", ColorText( (GetNumGroupMembers() - internValues_DB.GroupMembersOoC), "red" ) );
						else
							cacheText = cacheText:gsub("'replacement2'", (GetNumGroupMembers() - internValues_DB.GroupMembersOoC) );
						end
						print(ColorText(cacheText, "option"));
					else
						internValues_DB.GroupMembersOoC = 0;
					end
				end
			elseif ( event == "COMPACT_UNIT_FRAME_PROFILES_LOADED" ) then
				savedValues_DB.Profile = GetRaidProfileName(1); -- load the first profile. Gets replaced by loadData()

				loadData();				
				LibDD:UIDropDownMenu_SetText(Main_ddm_Profiles, savedValues_DB.Profile);
				UpdateComboBoxes();
				--Get informations
				
				resetRaidContainer(); -- hooks
				
				internValues_DB.showChatMessages = true;
				
				SwitchRaidProfiles();
				ApplySort();
				
				Main_Frame:UnregisterEvent(event);	
			elseif ( event == "PLAYER_ENTERING_WORLD" and HasLoadedCUFProfiles() == true and internValues_DB.inCombat == false ) then	
				ApplySort();
			end
		end);
end

--ComboBox Events
local function checkBoxEvent()
	
	--Combobox Top
	Main_cb_Top:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_Top:GetChecked() == true ) then
					savedValues_DB.Top = true;
					savedValues_DB.Bottom = false;
					savedValues_DB.Middle = false;
					if ( Main_cb_TopDescending:GetChecked() == false and Main_cb_TopAscending:GetChecked() == false ) then
						savedValues_DB.TopDescending = true;
					end
				elseif ( Main_cb_Top:GetChecked() == false ) then	
					savedValues_DB.Top = false;
				end
				SaveOptions();
				UpdateComboBoxes();
				ApplySort();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_Top:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Top_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Top_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_Top:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
		
	--Combobox Bottom
	Main_cb_Bottom:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_Bottom:GetChecked() == true ) then
					savedValues_DB.Top = false;
					savedValues_DB.Bottom = true;
					savedValues_DB.Middle = false;
					if ( Main_cb_BottomDescending:GetChecked() == false and Main_cb_BottomAscending:GetChecked() == false ) then
						savedValues_DB.BottomAscending = true;
						Main_cb_BottomAscending:SetChecked(true);
					end
				elseif ( Main_cb_Bottom:GetChecked() == false ) then	
					savedValues_DB.Bottom = false;
				end
				SaveOptions();
				UpdateComboBoxes();
				ApplySort();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);
	Main_cb_Bottom:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Bottom_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Bottom_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_Bottom:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Middle
	Main_cb_Middle:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_Middle:GetChecked() == true ) then
					savedValues_DB.Top = false;
					savedValues_DB.Bottom = false;
					savedValues_DB.Middle = true;
					if ( Main_cb_MiddleParty1Top:GetChecked() == false and Main_cb_MiddleParty2Top:GetChecked() == false ) then
						savedValues_DB.MiddleParty1Top = true;
						Main_cb_MiddleParty1Top:SetChecked(true);
					end
				elseif ( Main_cb_Middle:GetChecked() == false ) then	
					savedValues_DB.Middle = false;
				end
				SaveOptions();
				UpdateComboBoxes();
				ApplySort();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);
	Main_cb_Middle:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Middle_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Middle_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_Middle:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Main_cb_TopDescending
	Main_cb_TopDescending:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_TopDescending:GetChecked() == true ) then
					savedValues_DB.TopDescending = true;
					savedValues_DB.TopAscending = false;
				elseif ( Main_cb_TopDescending:GetChecked() == false ) then	
					savedValues_DB.TopDescending = false;
				end
				SaveOptions();
				UpdateComboBoxes();
				ApplySort();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_TopDescending:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Descending_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Descending_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_TopDescending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Main_cb_TopDescending
	Main_cb_TopAscending:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_TopAscending:GetChecked() == true ) then
					savedValues_DB.TopDescending = false;
					savedValues_DB.TopAscending = true;
				elseif ( Main_cb_TopAscending:GetChecked() == false ) then	
					savedValues_DB.TopAscending = false;
				end
				SaveOptions();
				UpdateComboBoxes();
				ApplySort();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_TopAscending:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Ascending_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Ascending_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_TopAscending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Main_cb_TopDescending
	Main_cb_BottomDescending:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_BottomDescending:GetChecked() == true ) then
					savedValues_DB.BottomDescending = true;
					savedValues_DB.BottomAscending = false;
				elseif ( Main_cb_BottomDescending:GetChecked() == false ) then	
					savedValues_DB.BottomDescending = false;
				end
				SaveOptions();
				ApplySort();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_BottomDescending:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Descending_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Descending_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_BottomDescending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Main_cb_TopDescending
	Main_cb_BottomAscending:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_BottomAscending:GetChecked() == true ) then
					savedValues_DB.BottomDescending = false;
					savedValues_DB.BottomAscending = true;
				elseif ( Main_cb_BottomAscending:GetChecked() == false ) then	
					savedValues_DB.BottomAscending = false;
				end
				SaveOptions();
				ApplySort();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_BottomAscending:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Ascending_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Ascending_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_BottomAscending:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Main_cb_MiddleParty1Top
	Main_cb_MiddleParty1Top:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_MiddleParty1Top:GetChecked() == true ) then
					savedValues_DB.MiddleParty1Top = true;
					savedValues_DB.MiddleParty2Top = false;
				elseif ( Main_cb_MiddleParty1Top:GetChecked() == false ) then	
					savedValues_DB.MiddleParty1Top = false;
				end
				SaveOptions();
				ApplySort();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_MiddleParty1Top:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Party1Top_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Party1Top_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_MiddleParty1Top:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
	
	--Combobox Main_cb_MiddleParty2Top
	Main_cb_MiddleParty2Top:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_MiddleParty2Top:GetChecked() == true ) then
					savedValues_DB.MiddleParty1Top = false;
					savedValues_DB.MiddleParty2Top = true;
				elseif ( Main_cb_MiddleParty2Top:GetChecked() == false ) then	
					savedValues_DB.MiddleParty2Top = false;
				end
				SaveOptions();
				ApplySort();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_MiddleParty2Top:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_Party2Top_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_Party2Top_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_MiddleParty2Top:SetScript("OnLeave", function(self) GameTooltip:Hide() end)	
		
	--Combobox AutoActive
	Main_cb_AutoActivate:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_AutoActivate:GetChecked() == true ) then
					savedValues_DB.AutoActivate = true;
					SwitchRaidProfiles();
					ApplySort();
				elseif ( Main_cb_AutoActivate:GetChecked() == false ) then
					savedValues_DB.AutoActivate = false;
				end
				SaveOptions();
				ApplySort();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_AutoActivate:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_AutoActivate_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_AutoActivate_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_AutoActivate:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
		
	--Combobox savedValues_DB.AlwaysActive
	Main_cb_AlwaysActive:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				internValues_DB.showChatMessages = true;
				if ( Main_cb_AlwaysActive:GetChecked() == true ) then
					savedValues_DB.AlwaysActive = true;
					UIDropDownMenu_DisableDropDown(Main_ddm_Profiles);
					ApplySort();
				elseif ( Main_cb_AlwaysActive:GetChecked() == false ) then
					savedValues_DB.AlwaysActive = false;
					Main_cb_AutoActivate:Enable();
					UIDropDownMenu_EnableDropDown(Main_ddm_Profiles);
					getglobal(Main_cb_AutoActivate:GetName() .. 'Text'):SetText(L["SortGroup_Main_cb_AutoActivate_Text"]);
				end
				SaveOptions();
				UpdateComboBoxes();
				ApplySort();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);		
	Main_cb_AlwaysActive:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Main_cb_AlwaysActive_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_AlwaysActive_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Main_cb_AlwaysActive:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
			
	--Combobox savedValues_DB.ChatMessagesOn
	Option_cb_ChatMessagesOn:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				if ( Option_cb_ChatMessagesOn:GetChecked() == true ) then
					savedValues_DB.ChatMessagesOn = true;
					print(ColorText(L["SortGroup_sort_chat_Messages_On_output"], "option"));
				elseif ( Option_cb_ChatMessagesOn:GetChecked() == false ) then
					savedValues_DB.ChatMessagesOn = false;
				end
				SaveOptions();
				UpdateComboBoxes();
			else
				UpdateComboBoxes(true);
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);
	Option_cb_ChatMessagesOn:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Option_cb_ChatMessagesOn_Text"] .."\n\n" .. ColorText(L["SortGroup_Main_cb_ChatMessagesOn_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Option_cb_ChatMessagesOn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	
	--Combobox savedValues_DB.RaidProfileBlockInCombat
	Option_cb_RaidProfilesUpdateInCombat:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				if ( Option_cb_RaidProfilesUpdateInCombat:GetChecked() == true ) then
					savedValues_DB.RaidProfileBlockInCombat = true;
				elseif ( Option_cb_RaidProfilesUpdateInCombat:GetChecked() == false ) then
					savedValues_DB.RaidProfileBlockInCombat = false;
				end
				SaveOptions();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);
	Option_cb_RaidProfilesUpdateInCombat:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_Text"] .."\n\n" .. ColorText(L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Option_cb_RaidProfilesUpdateInCombat:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	
	--ComboBox Option_cb_ShowGroupMembersInCombat
	Option_cb_ShowGroupMembersInCombat:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or changeableValues_DB.ChangesInCombat == true ) then
				if ( Option_cb_ShowGroupMembersInCombat:GetChecked() == true ) then
					savedValues_DB.ShowGroupMembersInCombat = true;
				elseif ( Option_cb_ShowGroupMembersInCombat:GetChecked() == false ) then
					savedValues_DB.ShowGroupMembersInCombat = false;
				end
				SaveOptions();
				UpdateComboBoxes();
			else
				UpdateComboBoxes();
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
		end);
	Option_cb_ShowGroupMembersInCombat:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Option_cb_ShowGroupMembersInCombat_Text"] .."\n\n" .. ColorText(L["SortGroup_Option_cb_ShowGroupMembersInCombat_ToolTip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Option_cb_ShowGroupMembersInCombat:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	
	--ComboBox Option_cb_VisibilityInCombat
	Option_cb_VisibilityInCombat:SetScript("OnClick",
		function()
			if ( internValues_DB.inCombat == false or dchangeableValues_DB.ChangesInCombat == true ) then
				if ( Option_cb_VisibilityInCombat:GetChecked() == true ) then
					savedValues_DB.VisibilityInCombat = true;
				elseif ( Option_cb_VisibilityInCombat:GetChecked() == false ) then
					savedValues_DB.VisibilityInCombat = false;
				end
				SaveOptions();
			else
				if ( savedValues_DB.ChatMessagesOn == true ) then
					print(ColorText(L["SortGroup_in_combat_options_output"], "option"));
				end
			end
			UpdateComboBoxes();
		end);
	Option_cb_VisibilityInCombat:SetScript("OnEnter", 
		function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:AddLine(L["SortGroup_Option_cb_VisibilityInCombat_Text"] .."\n\n" .. ColorText(L["SortGroup_Option_cb_VisibilityInCombat_Tooltip"], "white") , nil, nil, nil, 1);
			GameTooltip:Show();
		end);
	Option_cb_VisibilityInCombat:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end
---End Events



local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");
loader:SetScript("OnEvent", function(self, event, arg1)
	if ( event == "ADDON_LOADED" and arg1 == "SortGroup" ) then
		createFrame();
		createText();
		createCheckbox();
		createDropDownMenu();
		frameEvent();	
		checkBoxEvent();
		self:UnregisterEvent("ADDON_LOADED");
	end
end);