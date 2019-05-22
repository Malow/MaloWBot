# MaloWBot

This is a complete suite for multi-boxing on a World of Warcraft 1.12 server. It has been specifically designed for playing on https://multiboxwow.com/, but it may work well on other servers as well. 

Classes and specs not yet supported: Shamans, Feral or Balance Druids, Protection or Retribution Paladins, Shadow Priests. 

Supported instances and bosses via specific boss-modules where needed: Full AQ-20, ZG and Onyxia support. Full MC support except for Ragnaros. Full support for Kazzak and Azuregos world-bosses. Experimental Razorgore support.

Installation & Running instructions: 
* Download and install the MobHealth3 addon found here: https://wow.curseforge.com/projects/project-2615/files
* Install the MaloWBot addon (the other addons are optional, though I do recommend at least the MaloWBotCommander addon as well).
* Modify the MaloWBot/Config.lua and MaloWBot/PersonalizedConfig.lua to match your raid.
* Start 1 instance of WoW that you want to be the "Commander" and make sure that character's name is set at line 6 of MaloWBot/Config.lua instead of the "targetThatCantBeFound"-string. 
* Open CSharpPresser/Release/config.txt and modify it to match your raid. Run CSharpPresser.exe and type "start X" where X corresponds to the name of one of the setups created in the config.txt file.
* Once all WoWs are started and logged in press F9 to begin sending simulated key-presses for buttons 7 and 9 to all WoW clients. 
* All characters should now be following your "Commander", and they should automatically keep the raid healed and they will automatically DPS whatever target you have. 
* For further instructions on what you can do see the menu displayed in the CSharpPresser program and see the MaloWBotCommander-GUI and MaloWBot/SlashCommands.lua for further options for the in-game addon. 
