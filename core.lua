MaxHit = LibStub("AceAddon-3.0"):NewAddon("MaxHit", "AceEvent-3.0", "AceConsole-3.0")

--   	Fired when an npc or player participates in combat and takes damage
-- arg1
--    the UnitID of the entity
--arg2
--    Action,Damage,etc (e.g. HEAL, DODGE, BLOCK, WOUND, MISS, PARRY, RESIST, ...)
-- arg3
--     Critical/Glancing indicator (e.g. CRITICAL, CRUSHING, GLANCING)
-- arg4
--     The numeric damage
-- arg5
--     Damage type in numeric value (1 - physical; 2 - holy; 4 - fire; 8 - nature; 16 - frost; 32 - shadow; 64 - arcane)


local defaults = {
	profile = {
		MaxHit = 0,
		spell = "",
        creature = ""
	},
}

function MaxHit:OnInitialize()
    self:Print("Hello World!")
    self.db = LibStub("AceDB-3.0"):New("MaxHitDB", defaults, true)
end

function MaxHit:OnEnable()
	self:RegisterEvent("UNIT_COMBAT")
    self:RegisterChatCommand("maxhit", "SlashCommand")
end

function MaxHit:UNIT_COMBAT(UNIT_COMBAT, arg1, arg2, arg3, arg4)
    if arg2 ~= "WOUND" then
        return
end

    if arg4 < self.db.profile.MaxHit then
        return
end

    self.db.profile.MaxHit = arg4
    self.db.profile.creature = UnitName(arg1)


    -- if current hit is greater than stored hit
    -- then store this hit's damage value, spell used, and enemy hit
    -- and display message to user
end

-- prints users max hit
function MaxHit:SlashCommand()
	self:Print('Max hit is'..self.db.profile.MaxHit)
end

