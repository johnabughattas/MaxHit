MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")


local defaults = {
	profile = {
		MaxHit = {0},
		spell = "",
        creature = ""
	},
}

function MaxHit:OnInitialize()
    -- load database from previous play sessions
    self.db = LibStub("AceDB-3.0"):New("MaxHitDB", defaults, true)

  

    -- gets the player's name and id, and greets them upon login
    player_name = UnitName('player')
    player_id = UnitGUID('player')
    self:Print("Hello, ".. player_name)

end

function MaxHit:OnEnable()
    -- enables listener for combat isntances
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --self.db.profile.MaxHit[0] = 0
    -- enables slash commands (function defined below)
    self:RegisterChatCommand("maxhit", "SlashCommand")
end

function MaxHit:OnDisable()
    -- Called when the addon is disabled
end

function MaxHit:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    -- ignore combat log events that are not damage or where the source is not the player
    if (subevent ~= "SWING_DAMAGE" and subevent ~= "SPELL_DAMAGE") or sourceGUID ~= player_id then
        return
    end

    if subevent == "SPELL_DAMAGE" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()
    
        if amount > self.db.profile.MaxHit[1] then
            self.db.profile.MaxHit[1] = amount
            self.db.profile.creature = destName
            self.db.profile.spell = spellName
            self:Print("New max hit of "..amount.." against "..destName.."!")
    end
end

    if subevent == "SWING_DAMAGE" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()

        if amount > self.db.profile.MaxHit[1] then
            self.db.profile.MaxHit[1] = amount
            self.db.profile.creature = destName
            self.db.profile.spell = "auto-attack"
            self:Print("New max hit of "..amount.." against "..destName.."!")
    end
end

end 

-- prints users max hit when they use the slash command /maxhit
function MaxHit:SlashCommand()
	self:Print('Max hit is '..self.db.profile.MaxHit[1].." against "..self.db.profile.creature.." using "..self.db.profile.spell)
end

