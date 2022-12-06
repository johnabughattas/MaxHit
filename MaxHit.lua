MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")


local defaults = {
	profile = {
		maxHit = {},
        character_name = nil,
        character_id = nil;
	},
}



function MaxHit:OnInitialize()
    -- load database from previous play sessions
    self.db = LibStub("AceDB-3.0"):New("MaxHitDB", defaults)


    -- get the player's name and id, and greets them upon login
    self.db.profile.character_name = UnitName('player')
    self.db.profile.character_id = UnitGUID('player')
    self:Print("Hello, ".. self.db.profile.character_name)
end


function MaxHit:OnEnable()
    -- enable listener for combat isntances
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- enable slash commands (function defined below)
    self:RegisterChatCommand("maxhit", "SlashCommand")
    self:RegisterChatCommand("maxhitoptions", "ChatCommand")
end

function MaxHit:OnDisable()
    -- Called when the addon is disabled
end

function MaxHit:COMBAT_LOG_EVENT_UNFILTERED()
    -- store all relevant info of the current combat instance
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount = CombatLogGetCurrentEventInfo()

    -- ignore combat log events that are not damage, where the source is not the player, or the attack missed
    if (subevent ~= "SWING_DAMAGE" and subevent ~= "SPELL_DAMAGE") or sourceGUID ~= self.db.profile.character_id or amount == nil then
        return
    end

    -- if there is no attack currently stored, store this one as the max and alert the player
    for i = 1, 3, 1 
    do
        if self.db.profile.maxHit[i] == nil then
            self.db.profile.maxHit[i] = {
                hitAmount = amount,
                creature = destName,
                spell = subevent == "SPELL_DAMACE" and spellName or "auto-attack"
            } 
            self:Print("New max hit of "..amount.." against "..destName.." using "..self.db.profile.maxHit[i]["spell"].."!")
            return
    end
end

    -- if this attack is greater than the current max, store it and alert the player
    if amount > self.db.profile.maxHit[1]["hitAmount"] then
        self.db.profile.maxHit[1]["hitAmount"] = amount
        self.db.profile.maxHit[1]["creature"] = destName
 
        if subevent == "SPELL_DAMAGE" then
            self.db.profile.maxHit[1]["spell"] = spellName
        else
            self.db.profile.maxHit[1]["spell"] = "auto-attack"
        end

        self:Print("New max hit of "..amount.." against "..destName.."!")
        return

    else if amount > self.db.profile.maxHit[2]["hitAmount"] then
        self.db.profile.maxHit[2]["hitAmount"] = amount
        self.db.profile.maxHit[2]["creature"] = destName
    
        if subevent == "SPELL_DAMAGE" then
            self.db.profile.maxHit[2]["spell"] = spellName
        else
            self.db.profile.maxHit[2]["spell"] = "auto-attack"
        end

        self:Print("New max hit of "..amount.." against "..destName.."!")
        return
    
    else if amount > self.db.profile.maxHit[3]["hitAmount"] then
        self.db.profile.maxHit[3]["hitAmount"] = amount
        self.db.profile.maxHit[3]["creature"] = destName
    
        if subevent == "SPELL_DAMAGE" then
            self.db.profile.maxHit[3]["spell"] = spellName
        else
            self.db.profile.maxHit[3]["spell"] = "auto-attack"
        end

        self:Print("New max hit of "..amount.." against "..destName.."!")
        return
    end 
    end
end
end


-- prints users max hits when they use the slash command /maxhit
function MaxHit:SlashCommand()
   --self.db.profile.maxHit = nil
   for i = 1, 3, 1 
   do
        if self.db.profile.maxHit[i] == nil then
            self:Print(i)
            self:Print("No max hit on record! Go slay some villains!")
            return
        end
    end

	self:Print('Max hit is '..self.db.profile.maxHit[1]["hitAmount"].." against "..self.db.profile.maxHit[1]["creature"].." using "..self.db.profile.maxHit[1]["spell"])
    self:Print('Second best hit is '..self.db.profile.maxHit[2]["hitAmount"].." against "..self.db.profile.maxHit[2]["creature"].." using "..self.db.profile.maxHit[2]["spell"])
    self:Print('Third best hit is '..self.db.profile.maxHit[3]["hitAmount"].." against "..self.db.profile.maxHit[3]["creature"].." using "..self.db.profile.maxHit[3]["spell"])
end


