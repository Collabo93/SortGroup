5.1.05
	
	Attempts to reduce taint
	Reloading the UI while in a group should reapply the sort function now
	Removed an unused lib reference
	Settings should only load once in a session again

5.1.02

	Fixed a small bug
	Removed an old lib reference
	Reloading the UI while in a group should reapply the sort function now
	Attempts to reduce taint
	(Added a message when entering the Edit Mode) - deleted

5.1.0

	Updated for 10.0
	Remove the Player in the middle sort option for now
	Removed the options tab
	

5.0.4 Beta

	Added LibStub library
	Adjustments to prevent taint
	Small bug fixes

5.0.31 Beta

	Fixed a bug which caused to load raid profiles unintentionally
	
5.0.3 Beta

	Removed Templates
	Removed Debug
	Removed redundant code
	Added a new sort Option: Player in the Middle
	While in combat, interacting with a non existing UnitFrame shouldn't result in taint anymore.
	Code optimizations
	Members leaving the party, while player is combat, are now faded out by default.
		Fading shouldn't effect nameplate anymore
		Checkbox added to activate/deactivate this option
	CVar Check/Set for KeepGroupTogether
	Small bug fixes
	AceAddon lib update
	Flagged for 9.1.5

v4.2

	Added a button to set new default values
	Added a button to reset the addon
	Adjusted buttons in option panel
	Small code improvements
	
v4.1.2

	Fixed the addon for 8.x
	Fixed an issue which potentially could cause lua errors
	Fixed a misspelling in the german language
	Added a checkbox to display actual group members in chat, if the raid frames are blocked - by default disabled

v4.1
	
	Release tag
	Fixed an issue which caused sometimes the popup to get spam displayed
	Clean database reset

v4.04 Beta

	Changed checkbox 'Update in Combat' into 'Block in Combat'
	You get a textbox now if loading the new version the first time
	You shouldn't get chat spammed anymore, if 'Keep group together' is activated
	Fixed a taint issue

v4.0 Alpha

	Main focus lies on splitting the sort function and the additionally raidprofile switch into two different addons
	To do so every relation between those two functions are gone
	Necessary moduls for the additionally raidprofile switch are gone
	Most options that were available are gone. These are still accessable in the lua file, if needed.
	Major changes in terms of code improvements - like, a lot
	Updated libs

v3.5.02

	Visibility button is now deactivated by default
	Added a Note to this button

v3.5.01

	Mentioned raid profiles are in quotes now
	Fixed german language
	Deleted old code snippets that weren't neccessary anymore

v3.5

	Added a visibility button for units which leave group in combat
	Pressing cancel doesn't switch your raid profiles automatically anymore - to prevent taint  
	Auto-Activate Raid Profiles on should now be in the correct range from 1-40
	Text labels should be on their correct place again.
	Changed some text

v3.4.4

	Added new Chat messages options
	Sortgroup should be way more reliable in regards of activating Raid Profiles now
	Some chat messages appeared even if they were deactivated - fixed
	DebugeMode activated sort options for reasons - fixed
	Optimized a few functions for a slightly better performence
	Some other small changes

v3.3.2

    New option: Auto-Activate in combat
        If deactivcated your Raid Profiles won't get auto-activated in combat
    Changed auto-activate area from 2-40 to 1-40
    If you save a new Raid Profile in auto-activate, SortGroup immediately checks the saved Raid Profiles now
    Changed all non local method names to more unique ones
    Some code improvements and changes
	
v3.3.02

    Flagged for 7.3.0
    If you click on reset you get a final pop-up dialog box now
        Additionally you get a text message by reset now
    Reset button is disabled now if you haven't any Raid Profiles in your saved list
    All elements should react better on a deleted Raid Profile in blizzard options now
    Auto-Activate doesn't need a gap between 'from' and 'to' anymore - so your Raid Profile can get selected by exactly one group number
    Some events didn't get displayed in the DebugMode - fixed
    Small code and perfomence improvements


v3.2.22

    Main focus lies on visual display
        Changed option fonts to white
        Tooltips have titles now 
        Changed tooltip fonts to white, except for titles
        Renamed some buttons and descriptions - for a better understanding what they actually do
    Moved 'Raid Profile in combat' to normal options
    Fixed a small display bug with the DebugMode options
    Buttons don't have a tooltip anymore
    Some intern changes to place elements more efficently
	
v3.1.5 (3.x Release)

    Flagged for 7.2
    New tab:Options
    Moved 'Chat Messages' button to tab options
    Moved button 'Reset' to tab options
    New buttons: DebugMode
        The options are combinable
        DebugMode is not supported !
    New button: 'Options in combat'
    New button: 'Raid Profile in combat'
    Fixed taint when switching Raid Profiles
    Changed load order for the resetRaidContainer - slightly better performence
    Sometimes it happens that your RaidProfile was unintentional adjusted - fixed
    Elements in tab 'Additional Raid Profile switches' adjusted for a better overview
    Changed some text messages for both languages
    A lot of changes in terms of code improvements
    If manual switch is active, pressing cancle/esc shouldn't change your selected profile anymore
    'Always active' should disable 'Switch Raid Profiles automatically' properly now
    Renamed most global variables
    Changed some global varables to local
    Got rid of unnecessary Ace libs

v3.1.1 Beta

    Adjustment on changed RaidProfile caused way too much problems.  Not worth it - deleted function
    As a consequence of that:
        Deleted Button 'Manually Raid Profile switch'
        Deleted messages specific for this case
        Changed code snippets to old ones
        'Always Active' adjusted - works properly now, even without adjustments
    Renamed most global variables
    Changed some global varables to local
    Buttons ' Player on Top' - 'Downwards' and 'Upwards' shouldn't be possible to be selected at the same time anymore

-- Probably last build before Release

v3.0.42 Beta

    Flagged for 7.2
    'Manual Raid Profile switch' shouldn't cause taint anymore
    'Reload UI' button does work now
    Got rid of unnecessary Ace libs
	
v3.0.4 Beta

    If manual switch is active, pressing cancle/esc shouldn't change your selected profile anymore
    Blocked raid profile switch should work properly now
    'Always active' should disable 'Switch Raid Profiles automatically' properly now

v3.0.31 Alpha

    Fixed an issue with blocked Raid Profile switch
    Deleted unesessary code
    Fixed an unintentionall deleted code snippet - some messages didn't appear because of that
    Fixed wrong german language code
    If a Raid Profile switch gets blocked a new message appears now (ofc only with messages on)

v3.0.2 Alpha

    New tab:Options
    Moved 'Chat Messages' button to tab options
    Moved button 'Reset' to tab options
    New buttons: DebugMode
        The options are combinable
        DebugMode is not supported !
    New button: 'Options in combat'
    New button: 'Manually Raid Profile switch'
    New button: 'Raid Profile in combat'
    Changed load order for the resetRaidContainer - slightly better performence
    If you change your RaidProfiles on your own, Sortgroup will now adjust the options on the new selected RaidProfile
    Sometimes it happens that your RaidProfile was unintentionall adjusted - fixed
    Elements in tab 'Additional Raid Profile switches' adjusted for a better overview
    Changed some text messages for both languages
    A lot of changes in terms of code improvements

v2.4.2

    Save Button gets disabeld if you go back to the current saved options now
    Small code improvements

v2.4.15

    Fixed 'SetTargetClampingInsets' taint
    A full additional Raid Profile on load list that gets deactivated is now really deactivated
    Fixed a small compatibility issue with loading Raid Profiles on first and second page

v2.4.11

    Focus on performence and preventing taint
    SortGroup doesn't need to be deactivated in BG's anymore - deleted
    Rebuilt debug mode completly, to build and fix stuff faster
    Fixed an issue with deleted Raid Profiles
    Fixed a minor issue with sliders - maximum slider should now be displayed as green, if range is still useable
    German language: umlauts should now displayed correctly
    German language: fixed grammar
    general code improvement

v.2.3.2.1

    Fixed a message
    Small addition to Raid Profile load order 

v2.3.2

    Updated and fixed for 7.1
    Further measures to prevent namepletes get faded
    Fixed an issue with sliders
    Fixed an issue with deleted Raid Profiles - they should now be deleted in SortGroup options as well
    Added visual effects to sliders. You are able to see which area is in use or still available
    Some new messages if an error appears
    Some small changes in general 

v2.2a

    Fixed an issue with nameplates 

v2.2

    '<unnamed>' taint shouldn't be a thing anymore
    Improved 'CompactRaidFrame' reset method. 'TryUpdate' will now be executed if you leave combat. Result: No more Lua errors *hopefully* ;) 

v2.1

    If your client crashes or you get disconnected SortGroup shouldn''t delete your options anymore.
    The reset button doesn't load your UI anymore
    Bugs from previous build fixed
    A lot minor changes, respective disabling sliders etc. 

v2.0.1

    Added new sort options
    Added option to load your Raid Profiles by group size
    A LOT of major changes 

v1.5.2.2

    Messages adapted
    Polished code a bit
    Small changes in general 

v1.5.2

    Updated for Legion
    You don't need to reload your UI if you change any SortGroup options
    Inactive in BGs didn't work as intended - rebuilt
    Reloading the UI in a five man group shouldn't reset your sort options anymore
    Changing your spec doesn't lead to reset your sort options since 7.x. Therefore the protective measures aren't necessary anymore - deleted
    If your Group gets tainted (by summonig a pet in combat for example) SortGroup will try to reset CompactRaidFrame
    Some changes to prevent taint - still not completly possible 

v1.5

    New Button: Chat messages On/Off
    No group reset by pressing cancel/escape anymore
    SortGroup doesn't switch your Raid Profile after leaving combat anymore
    Some small changes 

v1.4.3

    Debug Mode available
    DropDownMenu checks your Raid Profile by your first login now.
    Raid Profile switch by SortGroup is displayed now 

v1.4.2

    Pressing cancel shouldn't reset your Raid Profil anymore unless you are in a Group
    Some changes specific messages 

v1.4.1

    Unless you don't change any options, SortGroup shouldn't spam you anymore that you are in a group.
    Button :'Switch Raid Profiles automatically' includes changing spec now
    Added text colors 

v1.4b

    Garrison was unfortunately for test purposes still in the blocked BG list 

v1.4

    Added Button 'Always active'
    SortGroup is now inactive if you enter a battelground, until you leave. That caused some problems before.
    Wrong message "SortGroup isn't active" shouldn't be displayed anymore
    Added more useful messages
    Some major changes 

v1.3

    If you are in combat now you won't be able to change options until you leave combat.
    Button to change profiles automatically is now really enabled by default
    Rebuilt Drop Down Menu and further measures to prevent taint
    Small changes in general 

v1.2.2

    fixed an issue which caused the group not to get sorted sometimes
    some small changes 

v1.2

    Added Tooltips
    Button to change profiles automatically is now enabled by default
    Possibility to add other laguages now
    Added localisation: german 

v1.1.2

    Fixed an issue where options didn't get saved after you enter any other area 

v1.1

    Added a button to change profiles automatically
    Small changes in general 

v1.0

    Release