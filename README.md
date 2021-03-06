# [CS:S/CS:GO] SM Hosties v2 #
by: databomb, dataviruset and DorCoMaNdO

##### Description:

This is a re-write of SM_Hosties v1.x from dataviruset. This allows support for multiple LRs occuring simultaneously as well as a plethora of additional last request games and new cvars for the most customizable Hosties yet.
It opens up a new API for plugin developers to ask questions like if a player is a rebel as well as the ability to add third party last request games for each server independent of the Hosties plugin.

##### Translators needed!
To extend Hosties we need (new) translators.

[You can translate this plugin here](http://translator.mitchdempsey.com/sourcemod_plugins/148)

##### Features:

1. 35 Last Request Games
 + Shotgun Wars (optional, needs lastrequest_shotgunwars plugin)
 + Fruit Ninja (optional, needs lastrequest_fruitninja plugin)
 + Drunken Boxing
 + Most Jumps
 + Farthest Jump
 + Brink of Death
 + Race
 + Russian Roulette
 + Rebel
 + Low-Grav Knife Fight
 + Hi-Speed Knife Fight
 + Third Person Knife Fight
 + Drugged Knife Fight
 + Vintage (Normal) Knife Fight
 + Rock Paper Scissors
 + NoScope with any scoped weapon (4 choices)
 + Dodgeball
 + Hot Potato
 + Chicken Fight
 + Shot4Shot with any pistol (6 choices for CS:S, 7 for CS:GO)
 + Mag4Mag with any pistol (6 choices for CS:S, 7 for CS:GO)
 + Gun Toss
2. Check Players Command
3. Freekill Detection & Prevention
4. Game Description Override
5. Mute System with BaseComm Integration
6. No Block
7. Rules Command
8. Starting Weapons Payloads for CT & T
9. Round End Team Overlays

##### Hosties API (For developers):

For integration there are two natives provided: IsClientRebel and IsClientInLastRequest.
For adding custom LRs there are three natives provided: AddLastRequestToList, RemoveLastRequestFromList, and ProcessAllLastRequests.
Feel free to have a look at lastrequest_shotgunwars.sp and lastrequest_fruitninja.sp as they can be used as a reference to last request scripting.
ChangeRebelStatus is new in v2.1.0.

DorCoMaNdO developed an autostart feature which enables developers to add custom menus (on knife fight or Shot4Shot). Learn how by checking this example code:
http://pastebin.com/1Ka9nRVS

##### General Chat Commands:
+ !rules
+ !lastrequest (also: !lr)
+ !checkplayers

##### Admin Commands:
+ !stoplr (also: !abortlr and !cancellr): Requires slay admin flag and will abort any and all active last requests.

##### Requirements:
[**SourceMod 1.6.0+**](http://www.sourcemod.net/snapshots.php)

##### Automatic Install Instructions:
The easiest way to install SM_Hosties v2 is this:

    Be sure that your server meets the requirements for SM_Hosties v2 (see above)
    Scroll down a bit on this page and download the ZIP file attached to this post (or from the mirror)
    Extract all files from the ZIP file into the cstrike folder of your server (all directories should match up with the folders in the ZIP file)
    Restart your server or let it change map
    Done!

##### Manual Install Instructions:
NOTE: Do not compile any individual file such as lastrequest.sp in the hosties/ directory, compiling sm_hosties.sp will include these files.
If you'd like only lastrequest.sp then that is a separate discussion.

    Copy all files in the scripting/hosties/ directory to addons/sourcemod/scripting/hosties/
    Copy all files in the translation/ directory to addons/sourcemod/translations/
    Copy the hosties.inc and lastrequest.inc files to addons/sourcemod/scripting/include/
    Copy lastrequest_shotgunwars.sp, lastrequest_fruitninja.sp and sm_hosties.sp to addons/sourcemod/scripting/
    If you are going to compile lastrequest_fruitninja, check that you have SMLIB in the include folder (all versions of SM_Hosties don't have it bundled), otherwise download it and put the include files in the addons/sourcemod/scripting/include/ folder.
    Compile sm_hosties, lastrequest_shotgunwars and lastrequest_fruitninja and move SMX files to addons/sourcemod/plugins/
    Run plugin for the first time and configure all settings in cfg/sourcemod/sm_hosties2.cfg


##### Upgrade Instructions:

1. Rename your original sm_hosties2.cfg in cfg/sourcemod/ to sm_hosties2.backup.cfg
2. Let the new version of the plugin start for the first time and create the new cfg file.
3. Look at the sm_hosties2.backup.cfg and merge your original settings with the new one.

##### Changes to Existing Cvars:

A few of the existing cvar settings in SM_Hosties v1.x have changed slighlty in v2. The v2 config file has been given a new name intentionally.
Really, you should consider to redo all configuration if you're upgrading from 1.x.

+ sm_hosties_lr_ts_max: This now controls the number of Ts allowed to have LRs going at the same time.
+ sm_hosties_mute_immune: This now uses flag CHARACTERS instead of names. (E.g. use "z" instead of "root".)
+ sm_hosties_lr_hp_teleport: Added new option (2)- teleport and freeze players.
+ sm_hosties_ct_start and sm_hosties_t_start should now include "weapon_knife" in the list.
+ sm_hosties_lr_s4s_shot_taken now applies to Mag4Mag as well as Shot4Shot.
+ sm_hosties_roundend_overlay_ct & sm_hosties_roundend_overlay_t now must specify the VTF file only
+ sm_hosties_lr_ns_delay is now an integer instead of a float.
+ sm_hosties_lr_s4s_dblsht_action now determines if sm_lr_rebel_action is followed or not (0 - no punishment, 1 - follow rebel_action)
+ sm_hosties_lr_s4s_shot_taken now includes Mag4Mag announcement when magazines are emptied

##### Special Thanks for Version 2:

+ psychonic - Answering any question I've had with SourceMod plugin coding
+ johan123jo - The blocking LR damage code and various bug fixes
+ MomemtumMori - Hosting the SVN for SM_Hosties v2 while under development
+ Berni - For helping with hull traces
+ dvander - Pointing out some architectural flaws with the Hosties API
+ Crosshair - Inspiration

##### Thanks to the servers willing to run beta versions of this (for all the problems you never had to deal with, thank them):
+ Groger, OnlyFriends
+ Silence, XenoGamers

##### Help The Cause:

SM_Hosties v2 is over 5,500 lines of code and growing. There are a variety of ways you could help the project.
Firstly, we have a healthy list of new features that could be added if you have any experience with SourceMod and plugin development and would like to lend a hand. Also, with the addition of the Hosties API, we could make a custom LR game for your server in exchange for a small fee. AlliedMods is gracious enough to host all of this so, if you haven't already, make them a donation to support the hosting costs. Lastly, consider making a donation to us to help offset the cost of development and hosting. The barrage of DDoS attacks drives up the cost of hosting and without active servers, our interest in development would wither. Donations to Vintage Jailbreak or '][' E H \/\/ARRiORS will be split amongst databomb and dataviruset, just be sure to reference this is for the Hosties project.

[**Donate**](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VintageJailbreak%40gmail%2ecom&lc=US&item_name=Hosties%20Development%20Fund&item_number=hosties&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest)

##### Translations:

The translations file has been heavily updated and we are in need of translators! If you have a language to add, reply to this topic or get in touch with one of us.
