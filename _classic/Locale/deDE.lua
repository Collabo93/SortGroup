local L = LibStub("AceLocale-3.0"):NewLocale("SortGroup", "deDE")
if not L then
    return
end

L["SortGroup_Main_cb_Top_Text"] = "Spieler oben"
L["SortGroup_Main_cb_Bottom_Text"] = "Spieler unten"
L["SortGroup_Main_cb_Descending_Text"] = "Absteigend"
L["SortGroup_Main_cb_Ascending_Text"] = "Aufsteigend"
L["SortGroup_Main_cb_AutoActivate_Text"] = "Lade Schlachtzugsprofil"
L["SortGroup_Main_cb_AlwaysActive_Text"] = "Immer aktiv"
L["SortGroup_Option_cb_ChatMessagesOn_Text"] = "Chat Nachrichten"
L["SortGroup_Option_btn_ResetTemplate_Text"] = "Lade UI"
L["SortGroup_Main_cb_Top_ToolTip"] = "Du bist an erster Stelle deiner Gruppe"
L["SortGroup_Main_cb_Bottom_ToolTip"] = "Du bist an letzter Stelle deiner Gruppe"
L["SortGroup_Main_cb_Descending_ToolTip"] = "Party 1-4 werden nach unten sortiert"
L["SortGroup_Main_cb_Ascending_ToolTip"] = "Party 1-4 werden nach oben sortiert"
L["SortGroup_Main_cb_AutoActivate_ToolTip"] =
    "Dein gewähltes Schlachtzugsprofil wird immer, mit deinen gewählten Optionen, in <= 5 Mann-Gruppen geladen"
L["SortGroup_Main_cb_AlwaysActive_ToolTip"] =
    "Dein aktuelles Schlachtzugsprofil ist unwichtig. SortGroup ist immer aktiv"
L["SortGroup_Main_ddm_Profiles_Text"] = "Sortiere Schlachtzugsprofil"
L["SortGroup_Main_ddm_Profiles_ToolTip"] =
    "Schlachtzugsprofil, dass sortiert werden soll.\n\nHinweis:\nWenn 'Lade Schlachtzugsprofil' nicht aktiviert ist, musst du eigenständig dein Schlachtzugsprofile aktivieren"
L["SortGroup_Main_cb_ChatMessagesOn_ToolTip"] = "Chat Nachrichten an/aus";
L["SortGroup_sort_top_descending_output"] = "SortGroup: \"'replacement'\" sortiert mit - Oben, Absteigend"
L["SortGroup_sort_top_ascending_output"] = "SortGroup: \"'replacement'\" sortiert mit - Oben, Aufsteigend"
L["SortGroup_sort_bottom_descending_output"] = "ortGroup: \"'replacement'\" sortiert mit - Unten, Absteigend"
L["SortGroup_sort_bottom_ascending_output"] = "SortGroup: \"'replacement'\" sortiert mit - Unten, Aufsteigend"
L["SortGroup_sort_top_descending_AlwaysActive_output"] =
    "SortGroup: Alle Schlachtzugsprofile sortiert mit - Oben, Absteigend"
L["SortGroup_sort_top_ascending_AlwaysActive_output"] =
    "SortGroup: Alle Schlachtzugsprofile sortiert mit - Oben, Aufsteigend"
L["SortGroup_sort_bottom_descending_AlwaysActive_output"] =
    "SortGroup: Alle Schlachtzugsprofile ortiert mit - Unten, Absteigend"
L["SortGroup_sort_bottom_ascending_AlwaysActive_output"] =
    "SortGroup: Alle Schlachtzugsprofile sortiert mit - Unten, Aufsteigend"
L["SortGroup_sort_chat_Messages_On_output"] = "SortGroup: Chat Nachrichten sind an"
L["SortGroup_sort_no_output"] = "SortGroup: Sortierfunktion ist nicht aktiv"
L["SortGroup_in_combat_options_output"] = "SortGroup: Verlasse den Kampf, um Optionen ändern zu können"
L["SortGroup_RaidProfil_dont_exists_output"] =
    "SortGroup: Raid Profil \"'replacement'\" existiert nicht mehr. Neues als Standard ist \"'replacement2'\""
L["SortGroup_RaidProfil_changed_output"] = "SortGroup: Schlachtzugsprofil wurde auf \"'replacement'\" gewechselt"
L["SortGroup_RaidProfil_Doesnt_match_output"] =
    "SortGroup: Dein aktuelles Schlachtzugsprofile stimmt nicht mit deinem gewählten überein"
L["SortGroup_Option_Frame_Text"] = "Optionen"
L["SortGroup_Option_Text_General_Text"] = "Allgemein"
L["SortGroup_Option_Text_Combat_Text"] = "Kampf"
L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_Text"] = "Aktualisierung im Kampf"
L["SortGroup_Option_cb_RaidProfilesUpdateInCombat_ToolTip"] =
    "Wenn aktiviert: Schlachtzugsprofile werden im Kampf aktualisiert.\n\nHinweis:\nDu musst du dein Interface neu laden, um diese Änderung wirksam zu machen"
L["SortGroup_Keep_Group_Together_Active_output"] =
    "SortGroup: Deaktiviere 'Gruppen zusammenhalten' in deinen Schlachtzugsprofile, ansonsten kann deine Gruppe nicht sortiert werden"
L["SortGroup_numberOfMembers_output"] = "SortGroup: Anzahl Gruppenmitglieder 'replacement'('replacement2')"
L["SortGroup_Option_cb_ShowGroupMembersInCombat_Text"] = "Anzahl Gruppenmitglieder"
L["SortGroup_Option_cb_ShowGroupMembersInCombat_ToolTip"] =
    "Zeigt die tatsächliche Anzahl an Gruppenmitgliedern in Kampf.\n\nBemerkung:\nDiese Option ist unanhängig von 'Chat Nachrichten'"
