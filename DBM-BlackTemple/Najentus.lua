local mod	= DBM:NewMod("Najentus", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("2023".."11".."22".."10".."00".."00") --fxpw check
mod:SetCreatureID(22887)

mod:SetModelID(21174)
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 321595 321598",
	"SPELL_CAST_SUCCESS 321599 321596",
	"SPELL_AURA_APPLIED 321599",
	"SPELL_AURA_REMOVED 321599"
)

-- ПЕРЕДАЮ ПРИВЕТ РАЗРАБАМ И СПАСИБО ЗА СДВИГИ КАСТОВ КАЖДЫЕ 15%. 5 звезд водителю :)


-- local warnShield		= mod:NewSpellAnnounce(39872, 4)
-- local warnShieldSoon	= mod:NewSoonAnnounce(39872, 10, 3)
-- local warnSpine			= mod:NewTargetNoFilterAnnounce(39837, 3)

-- local specWarnSpineTank	= mod:NewSpecialWarningTaunt(39837, nil, nil, nil, 1, 2)
-- local yellSpine			= mod:NewYell(39837)

-- local timerShield		= mod:NewCDTimer(56, 39872, nil, nil, nil, 5)

local warnCurse				= mod:NewTargetAnnounce(321599, 5)
local specWarnCurse			= mod:NewSpecialWarningDispel(321599, "RemoveCurse", nil, nil, 1, 5)

local berserkTimer			= mod:NewBerserkTimer(480)

local kolossalnyi_udar		= mod:NewCDTimer(9, 321598) --SPELL_CAST_START
local grohot_priliva		= mod:NewCDTimer(25, 321595) --SPELL_CAST_START
local vodyanoe_proklyatie	= mod:NewCDTimer(30, 321599) --SPELL_CAST_SUCCESS
local pronzayous_ship		= mod:NewCDTimer(19, 321596) --SPELL_CAST_SUCCESS

-- mod:AddSetIconOption("SpineIcon", 39837)
mod:AddInfoFrameOption(39878, true)
local CurseTargets = {}
mod.vb.CurseIcon = 8
mod:AddRangeFrameOption("8")

local function CurseIcons(self)
	warnCurse:Show(table.concat(CurseTargets, "<, >"))
	table.wipe(CurseTargets)
	self.vb.CurseIcon = 8
end

function mod:OnCombatStart(delay)
	berserkTimer:Start(-delay)
	kolossalnyi_udar:Start(5.5)
	grohot_priliva:Start(21)
	vodyanoe_proklyatie:Start(30)
	pronzayous_ship:Start(19)

	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(8)
	end
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(kolossalnyi_udar.spellId) then
		kolossalnyi_udar:Start()
	elseif args:IsSpellID(grohot_priliva.spellId) then
		grohot_priliva:Start()
	end
end
function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(vodyanoe_proklyatie.spellId) then
		vodyanoe_proklyatie:Start()
		specWarnCurse:Show(args.SpellName)
	elseif args:IsSpellID(pronzayous_ship.spellId) then
		pronzayous_ship:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(321599) then
		CurseTargets[#CurseTargets + 1] = args.destName
		if self.Options.SetIconCurseTargets and self.vb.CurseIcon > 0 then
			self:SetIcon(args.destName, self.vb.CurseIcon)
		end
		self.vb.CurseIcon = self.vb.CurseIcon - 1
		self:Unschedule(CurseIcons)
		self:Schedule(0.1, CurseIcons, self)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(321599) then
		if self.Options.SetIconCurseTargets then
			self:RemoveIcon(args.destName)
		end
	end
end