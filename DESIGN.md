MaxHit is implemented in Lua because it is the only language supported by World of Warcraft (WoW) addons.
I chose to use the Ace3 framework, a framework specifically for WoW addons. 
I did so, first, because Ace3 is something of an "industry" standard among WoW addon developers.
If I continue developing WoW addons, I would be doing so with Ace3. 
Second, I used Ace3 because it simplifies using parts of the WoW API such as the GUI.
The documentation for Ace3 is available here: https://www.wowace.com/projects/ace3
Additionally, Ace3 has two dependencies: CallbackHandler-1.0 https://www.wowace.com/projects/callbackhandler and LibStub https://www.wowace.com/projects/libstub

In Lua, the only data structure is called a table. 
I used Lua tables to mimmick dictionaries. I did so because I wanted to store a user's max hit, the enemy they hit, and the spell they used.
A mimmicked dictionary allows me to keep all this information together in one place. 
Using Ace3's database library allows me to store this player information across play sessions. 

MaxHit supports the use of in-game slash commands ("/maxhit") because this is standard practice for WoW addons.
An experienced WoW addon user would expect to be able to access an addon by a slash command. 

Variables are declared locally so as to avoid MaxHit clashing with other addons a user might have installed.
There is a risk of some other addon having declared variables that share a name with my variables.
Variables I need to use globally within my code are instead defined as part of the user profile. 
I have tested MaxHit with other popular addons enabled to confirm that it does not effect any other addons.

self:Print() is used in favor of print(), so that information displayed to the user in-game appears explciitly as coming from MaxHit

