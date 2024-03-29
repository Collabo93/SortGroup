local L = LibStub("AceLocale-3.0"):NewLocale("SortGroup", "enUS", true)
if not L then
    return
end

L["SortGroup_Main_cb_Top_Text"] = "Player on Top"
L["SortGroup_Main_cb_Bottom_Text"] = "Player on Bottom"
L["SortGroup_Main_cb_Descending_Text"] = "Descending"
L["SortGroup_Main_cb_Ascending_Text"] = "Ascending"
L["SortGroup_Main_cb_AutoActivate_Text"] = "Load Raid Profile"
L["SortGroup_Main_cb_AlwaysActive_Text"] = "Always active"
L["SortGroup_Option_cb_ChatMessagesOn_Text"] = "Chat messages"
L["SortGroup_Option_btn_ResetTemplate_Text"] = "Reset Template"
L["SortGroup_Main_cb_Top_ToolTip"] = "You are on top of your Group"
L["SortGroup_Main_cb_Bottom_ToolTip"] = "You are on bottom of your Group"
L["SortGroup_Main_cb_Descending_ToolTip"] = "Party 1-4 are sorted descending"
L["SortGroup_Main_cb_Ascending_ToolTip"] = "Party 1-4 are sorted ascending"
L["SortGroup_Main_cb_AutoActivate_ToolTip"] =
    "Your selected Raid Profile will always get loaded with your selected options in <= 5-man groups"
L["SortGroup_Main_cb_AlwaysActive_ToolTip"] =
    "Your current Raid Profile doesn't matter. SortGroup is always active with your selected options"
L["SortGroup_Main_ddm_Profiles_Text"] = "Sort Raid Profile"
L["SortGroup_Main_ddm_Profiles_ToolTip"] =
    "Raid Profile that is going to get sorted.\n\nNote:\nIf 'Load Raid Profile' isn't checked you have to activate your chosen Raid Profile on your own"
L["SortGroup_Main_cb_ChatMessagesOn_ToolTip"] = "Chat Messages on/off"
L["SortGroup_sort_top_descending_output"] = "SortGroup: \"'replacement'\" sorted with - Top, Descending"
L["SortGroup_sort_top_ascending_output"] = "SortGroup: \"'replacement'\" sorted with - Top, Ascending"
L["SortGroup_sort_bottom_descending_output"] = "SortGroup: \"'replacement'\" sorted with - Bottom, Descending"
L["SortGroup_sort_bottom_ascending_output"] = "SortGroup: \"'replacement'\" sorted with - Bottom, Ascending"
L["SortGroup_sort_top_descending_AlwaysActive_output"] = "SortGroup: All Raid Profiles sorted with - Top, Descending"
L["SortGroup_sort_top_ascending_AlwaysActive_output"] = "SortGroup: All Raid Profiles sorted with - Top, Ascending"
L["SortGroup_sort_bottom_descending_AlwaysActive_output"] =
    "SortGroup: All Raid Profiles sorted with - Bottom, Descending"
L["SortGroup_sort_bottom_ascending_AlwaysActive_output"] =
    "SortGroup: All Raid Profiles sorted with - Bottom, Ascending"
L["SortGroup_sort_chat_Messages_On_output"] = "SortGroup: Chat Messages are on"
L["SortGroup_sort_no_output"] = "SortGroup: Sort function isn't active"
L["SortGroup_in_combat_options_output"] = "SortGroup: Leave combat to change options"
L["SortGroup_RaidProfil_dont_exists_output"] =
    "SortGroup: Raid Profile \"'replacement'\" doesn't exist anymore. New by default is \"'replacement2'\""
L["SortGroup_RaidProfil_changed_output"] = "SortGroup: Raid Profile was changed to \"'replacement'\""
L["SortGroup_RaidProfil_Doesnt_match_output"] =
    "SortGroup: Your current Raid Profile doesn't match with your chosen one"
L["SortGroup_Option_Frame_Text"] = "Options"
L["SortGroup_Option_Text_General_Text"] = "General"
L["SortGroup_Option_Text_Combat_Text"] = "Combat"
L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_Text"] = "Block in combat"
L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_ToolTip"] =
    "If enabled: Blizzard frames will get blocked in combat.\n\nNote:\nYou have to reload your UI to apply any change"
L["SortGroup_Keep_Group_Together_Active_output"] =
    "SortGroup: Deactivate 'Keep Groups Together' in your Raid Profiles, otherwise your Group can't get sorted"
L["SortGroup_numberOfMembers_output"] = "SortGroup: Number of group members: 'replacement'('replacement2')"
L["SortGroup_Option_cb_ShowGroupMembersInCombat_Text"] = "Number of group members"
L["SortGroup_Option_cb_ShowGroupMembersInCombat_ToolTip"] =
    "Displays the actuall number of group members if you are in combat.\n\nNote:\nThis option is independent from 'Chat messages'"
