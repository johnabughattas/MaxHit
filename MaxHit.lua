MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")


local defaults = {
	profile = {
		maxHit = {},
        character_name = nil,
        character_id = nil;
	},
}

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


function createMessage(maxHit)
    for i = 1, 3, 1 
    do
        if maxHit[i] == nil then
            options.args.msg.name = "No hits on record!"
            return
        end
    end

	options.args.msg.name = "Max hit of "..maxHit[1]["hitAmount"].." against "..maxHit[1]["creature"].." using "..maxHit[1]["spell"].."!\n".."2nd best hit of "..maxHit[2]["hitAmount"].." against "..maxHit[2]["creature"].." using "..maxHit[2]["spell"].."!\n".."3rd best hit of "..maxHit[3]["hitAmount"].." against "..maxHit[3]["creature"].." using "..maxHit[3]["spell"].."!\n"
end


-- helper function for printing our max hit values
-- i owe this cryptic bit of code to the good people of stackoverflow
function reformatInt(i)
    return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end


function MaxHit:OnInitialize()
    -- load database from previous play sessions
    self.db = LibStub("AceDB-3.0"):New("MaxHitDB", defaults)

    -- load GUI 
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MaxHit", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MaxHit", "MaxHit")
    createMessage(self.db.profile.maxHit)

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

    for i = 1, 3, 1
    do 
        if self.db.profile.maxHit[i] ~= nil and amount > self.db.profile.maxHit[i]["hitAmount"] then
                if i == 1 then
                    self:Print("New max hit of "..reformatInt(amount).." against "..destName.." using "..spellName.."!")

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
                    self:Print("New 2nd best hit of "..reformatInt(amount).." against "..destName.." using "..spellName.."!")

                    self.db.profile.maxHit[3] = {
                        hitAmount = self.db.profile.maxHit[2]["hitAmount"],
                        creature = self.db.profile.maxHit[2]["creature"],
                        spell = self.db.profile.maxHit[2]["spell"]
                    }
                else
                    self:Print("New 3rd best hit of "..reformatInt(amount).." against "..destName.." using "..spellName.."!")
                end

                -- update DB values

                if subevent == "SPELL_DAMAGE" then
                    self.db.profile.maxHit[i]["spell"] = spellName
                else
                    self.db.profile.maxHit[i]["spell"] = "auto-attack"
                end

                self.db.profile.maxHit[i]["hitAmount"] = amount
                self.db.profile.maxHit[i]["creature"] = destName

                createMessage(self.db.profile.maxHit)
                return
        elseif self.db.profile.maxHit[i] == nil then
            self.db.profile.maxHit[i] = {
                hitAmount = amount,
                creature = destName,
                spell = subevent == "SPELL_DAMACE" and spellName or "auto-attack"
            }
            createMessage(self.db.profile.maxHit)
            return
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
            elseif i == 2 then
                self:Print('2nd best hit is '..reformatInt(self.db.profile.maxHit[i]["hitAmount"]).." against "..self.db.profile.maxHit[i]["creature"].." using "..self.db.profile.maxHit[i]["spell"])
            else
                self:Print('3rd best hit is '..reformatInt(self.db.profile.maxHit[i]["hitAmount"]).." against "..self.db.profile.maxHit[i]["creature"].." using "..self.db.profile.maxHit[i]["spell"])
            end
        end
    end
end


