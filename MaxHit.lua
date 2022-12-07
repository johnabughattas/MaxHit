MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")

-- default values for a character's DB
local defaults = {
	profile = {
		maxHit = {},
        character_name = nil,
        character_id = nil;
	},
}

-- default values for options menu
local options = {
	name = "MaxHit",
	handler = MaxHit,
	type = "group",
	args = {
		msg = {
			type = "description",
			name = "Your top hits!",
            fontSize = "large"
		},
	},
}

-- function to update otpions menu
function CreateMessage(maxHit)
    if maxHit[1] == nil then
        options.args.msg.name = "No hits on record!"
        return
    end

    local message = "Your top hits!\n"

    for i = 1, 3, 1 
    do
        if maxHit[i] ~= nil then
            message = message..MaxHitMessage(i, maxHit[i]).."!\n"
        end
       
    end
    options.args.msg.name = message
end

-- function to print users max hits
function MaxHitMessage(index, maxHit)
    local hitAmount = ReformatInt(maxHit["hitAmount"])
    local creature = maxHit["creature"]
    local spell = maxHit["spell"]
    if index == 1 then
        return 'Max hit is '..hitAmount.." against "..creature.." using "..spell
    elseif index == 2 then
        return '2nd best hit is '..hitAmount.." against "..creature.." using "..spell
    else
        return '3rd best hit is '..hitAmount.." against "..creature.." using "..spell
    end
end

-- helper function for formatting max hit values
-- i owe this cryptic bit of code to the good people of stackoverflow
function ReformatInt(i)
    return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function MaxHit:OnInitialize()
    -- load database
    self.db = LibStub("AceDB-3.0"):New("MaxHitDB", defaults)

    -- load GUI 
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MaxHit", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MaxHit", "MaxHit")
    CreateMessage(self.db.profile.maxHit)

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
end

function MaxHit:COMBAT_LOG_EVENT_UNFILTERED()
    -- store all relevant info of the current combat instance
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, amount = CombatLogGetCurrentEventInfo()

    -- ignore combat log events that are not damage, where the source is not the player, or the attack missed
    if (subevent ~= "SWING_DAMAGE" and subevent ~= "SPELL_DAMAGE") or sourceGUID ~= self.db.profile.character_id or amount == nil then
        return
    end

    for i = 1, 3, 1
    do 
        -- handles cases where current attack is greater than one of the maxes and 3 values are already stored
        if self.db.profile.maxHit[i] ~= nil and amount > self.db.profile.maxHit[i]["hitAmount"] then
                if i == 1 then
                    self:Print("New max hit of "..ReformatInt(amount).." against "..destName.." using "..spellName.."!")

                    if self.db.profile.maxHit[2] ~= nil then
                        self.db.profile.maxHit[3] = {
                            hitAmount = self.db.profile.maxHit[2]["hitAmount"],
                            creature = self.db.profile.maxHit[2]["creature"],
                            spell = self.db.profile.maxHit[2]["spell"]
                        }
                    end

                    self.db.profile.maxHit[2] = {
                        hitAmount = self.db.profile.maxHit[1]["hitAmount"],
                        creature = self.db.profile.maxHit[1]["creature"],
                        spell = self.db.profile.maxHit[1]["spell"]
                    }
                elseif i == 2 then
                    self:Print("New 2nd best hit of "..ReformatInt(amount).." against "..destName.." using "..spellName.."!")

                    self.db.profile.maxHit[3] = {
                        hitAmount = self.db.profile.maxHit[2]["hitAmount"],
                        creature = self.db.profile.maxHit[2]["creature"],
                        spell = self.db.profile.maxHit[2]["spell"]
                    }
                else
                    self:Print("New 3rd best hit of "..ReformatInt(amount).." against "..destName.." using "..spellName.."!")
                end

                -- update DB values
                self.db.profile.maxHit[i]["spell"] = subevent == "SPELL_DAMAGE" and spellName or "auto-attack"
                self.db.profile.maxHit[i]["hitAmount"] = amount
                self.db.profile.maxHit[i]["creature"] = destName

                CreateMessage(self.db.profile.maxHit)
                return
        -- handles cases where one of the 3 max hits is not yet stored
        elseif self.db.profile.maxHit[i] == nil then
            self.db.profile.maxHit[i] = {
                hitAmount = amount,
                creature = destName,
                spell = subevent == "SPELL_DAMAGE" and spellName or "auto-attack"
            }
            self:Print(MaxHitMessage(i, self.db.profile.maxHit[i]))
            CreateMessage(self.db.profile.maxHit)
            return
        end
    end
end

-- prints users max hits when they use the slash command /maxhit
function MaxHit:SlashCommand()
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
            self:Print(MaxHitMessage(i, self.db.profile.maxHit[i]))
        end
    end
end


