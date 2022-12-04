MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")


local defaults = {
	profile = {
		maxHit = {},
        hitCounter = 1
	},
}

function MaxHit:OnInitialize()
    -- load database from previous play sessions
    self.db = LibStub("AceDB-3.0"):New("MaxHitDB", defaults, true)

    -- get the player's name and id, and greets them upon login
    player_name = UnitName('player')
    player_id = UnitGUID('player')
    self:Print("Hello, ".. player_name)
end

function MaxHit:OnEnable()
    -- enable listener for combat isntances
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- enable slash commands (function defined below)
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
        
        if self.db.profile.maxHit[1] == nil then
            self.db.profile.maxHit[1] = {
                hitAmount = amount,
                spell = spellName,
                creature = destName
            } 

            self:Print("New max hit of "..amount.." against "..destName.."!")
            return
        end

        if amount > self.db.profile.maxHit[1]["hitAmount"] then
            self.db.profile.maxHit[1]["hitAmount"] = amount
            self.db.profile.maxHit[1]["creature"] = destName
            self.db.profile.maxHit[1]["spell"] = spellName
            self.db.profile.hitCounter = self.db.profile.hitCounter + 1

            self:Print("New max hit of "..amount.." against "..destName.."!")
            return
    end
end

    if subevent == "SWING_DAMAGE" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = CombatLogGetCurrentEventInfo()
        
        if self.db.profile.maxHit[1] == nil then
            self.db.profile.maxHit[1] = {
                hitAmount = amount,
                spell = "auto-attack",
                creature = destName
            } 

            self:Print("New max hit of "..amount.." against "..destName.."!")
            return
        end

        if amount > self.db.profile.maxHit[1]["hitAmount"] then
            self.db.profile.maxHit[1]["hitAmount"] = amount
            self.db.profile.maxHit[1]["creature"] = destName
            self.db.profile.maxHit[1]["spell"] = "auto-attack"
            self.db.profile.hitCounter = self.db.profile.hitCounter + 1

            self:Print("New max hit of "..amount.." against "..destName.."!")
            return
    end
end

end 

-- prints users max hit when they use the slash command /maxhit
function MaxHit:SlashCommand()
    if self.db.profile.maxHit[1] == nil then
        self:Print("No max hit on record! Go slay some villains!")
        return
    end

	self:Print('Max hit is '..self.db.profile.maxHit[1]["hitAmount"].." against "..self.db.profile.maxHit[1]["creature"].." using "..self.db.profile.maxHit[1]["spell"])
end

