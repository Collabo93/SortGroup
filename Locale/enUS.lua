local L = LibStub("AceLocale-3.0"):NewLocale("SortGroup", "enUS", true)
if not L then
    return
end

L["SortGroup_Main_cb_Top_Text"] = "Player on Top"
L["SortGroup_Main_cb_Bottom_Text"] = "Player on Bottom"
L["SortGroup_Main_cb_Middle_Text"] = "Player in the Middle"
L["SortGroup_Main_cb_Descending_Text"] = "Descending"
L["SortGroup_Main_cb_Ascending_Text"] = "Ascending"
L["SortGroup_Main_cb_UnevenTop_Text"] = "Uneven on Top"
L["SortGroup_Main_cb_UnevenBottom_Text"] = "Uneven on Bottom"
L["SortGroup_SortBy_Text"] = "Sort By"
L["SortGroup_Option_Text"] = "Options"
L["SortGroup_Option_cb_ChatMessagesOn_Text"] = "Chat messages"
L["SortGroup_Option_cb_HideInactiveSlots_Text"] = "Hide inactive members"
L["SortGroup_Main_cb_Top_ToolTip"] = "You are on top of your Group"
L["SortGroup_Main_cb_Bottom_ToolTip"] = "You are on bottom of your Group"
L["SortGroup_Main_cb_Middle_ToolTip"] = "You are in the middle of your Group"
L["SortGroup_Main_cb_Descending_ToolTip"] = "Party 1-4 are sorted descending"
L["SortGroup_Main_cb_Ascending_ToolTip"] = "Party 1-4 are sorted ascending"
L["SortGroup_Main_cb_UnevenTop_ToolTip"] = "Uneven party members are above you"
L["SortGroup_Main_cb_UnivenBottom_ToolTip"] = "Uneven party members are below you"
L["SortGroup_Main_cb_ChatMessagesOn_ToolTip"] = "Chat Messages on/off"
L["SortGroup_Option_cb_HideInactiveSlots_Tooltip"] =
    "If active, none existing party members won't take an empty slot in your group"
L["SortGroup_sort_top_descending_output"] = "SortGroup: Active with - Top, Descending"
L["SortGroup_sort_top_ascending_output"] = "SortGroup: Active with - Top, Ascending"
L["SortGroup_sort_bottom_descending_output"] = "SortGroup: Active with - Bottom, Descending"
L["SortGroup_sort_bottom_ascending_output"] = "SortGroup: Active with - Bottom, Ascending"
L["SortGroup_sort_uneven_top_output"] = "SortGroup: Active with - Middle, Uneven on Top"
L["SortGroup_sort_uneven_bottom_output"] = "SortGroup: Active sorted with - Middle, Uneven on Bottom"
L["SortGroup_sort_chat_Messages_On_output"] = "SortGroup: Chat Messages are on"
L["SortGroup_sort_no_output"] = "SortGroup: Sort function isn't active"
L["SortGroup_in_combat_options_output"] = "SortGroup: Leave combat to change options"
L["SortGroup_enter_editMode"] = "SortGroup: Please reload your UI"
L['SortGroup_no_raid_style_frames'] =
    "SortGroup: Please enable \"Use Raid-Style Party Frames\" in the Edit Mode and reload your UI"
