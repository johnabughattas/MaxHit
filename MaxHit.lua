MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")


local defaults = {
	profile = {
		maxHit = {},
        character_name = nil,
        character_id = nil;
	},
}

-- helper function for printing our max hit values
function reformatInt(i)
    return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

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

                if i == 1 then
                    self:Print("New max hit of "..reformatInt(amount).." against "..destName.." using "..self.db.profile.maxHit[i]["spell"].."!")
                    return
                else if i == 2 then
                    self:Print("New 2nd best hit of "..reformatInt(amount).." against "..destName.." using "..self.db.profile.maxHit[i]["spell"].."!")
                    return
                else if i == 3 then
                    self:Print("New 3rd best hit of "..reformatInt(amount).." against "..destName.." using "..self.db.profile.maxHit[i]["spell"].."!")
                    return
                end
                end
                end
        end
    end

    -- if this attack is greater than the current max, store it and alert the player
    for i = 1, 3, 1
    do
        if amount > self.db.profile.maxHit[i]["hitAmount"] then
            self.db.profile.maxHit[i]["hitAmount"] = amount
            self.db.profile.maxHit[i]["creature"] = destName
    
            if subevent == "SPELL_DAMAGE" then
                self.db.profile.maxHit[i]["spell"] = spellName
            else
                self.db.profile.maxHit[i]["spell"] = "auto-attack"
            end

            if i == 1 then
                self:Print("New max hit of "..reformatInt(amount).." against "..destName.."!")
                return
            else if i ==2 then
                self:Print("New 2nd best hit of "..reformatInt(amount).." against "..destName.."!")
                return
            else if i == 3 then
                self:Print("New 3rd best hit of "..reformatInt(amount).." against "..destName.."!")
                return
            end
            end
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
            self:Print("No max hit on record! Go slay some villains!")
            return
        end
    end

    for i = 1, 3, 1
    do 
        if self.db.profile.maxHit[i] then
            if i == 1 then
                self:Print('Max hit is '..reformatInt(self.db.profile.maxHit[i]["hitAmount"]).." against "..self.db.profile.maxHit[i]["creature"].." using "..self.db.profile.maxHit[i]["spell"])
            else if i == 2 then
                self:Print('2nd best hit is '..reformatInt(self.db.profile.maxHit[i]["hitAmount"]).." against "..self.db.profile.maxHit[i]["creature"].." using "..self.db.profile.maxHit[i]["spell"])
            else if i == 3 then
                self:Print('3rd best hit is '..reformatInt(self.db.profile.maxHit[i]["hitAmount"]).." against "..self.db.profile.maxHit[i]["creature"].." using "..self.db.profile.maxHit[i]["spell"])
            end
            end
            end
        end
    end
end


