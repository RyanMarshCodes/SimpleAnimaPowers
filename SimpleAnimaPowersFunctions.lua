local _G = _G
local SAP = _G.SAP
local GUI = _G.LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleAnimaPowers")
local BR = LibStub("LibBabble-Race-3.0"):GetReverseLookupTable()
local ST = LibStub("ScrollingTable")
local QTIP = LibStub("LibQTip-1.0")
local DUMP = LibStub("LibTextDump-1.0")

local tableHasValue = function(t, v)
	for key, val in pairs(t) do
		if val == tostring(v) then
			return true
		end
	end

	return false
end

local split = function(pString, pPattern)
	local Table = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)

	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table, cap)
		end
		last_end = e + 1
		s, e, cap = pString:find(fpat, last_end)
	end

	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(Table, cap)
	end
	return Table
end

local pinnedPowers = function()
	return split(SAP.Settings.PinnedSpells, ",")
end

function spairs(t, order)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	if order then
		table.sort(keys, function(a, b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

local GetGroupMembers = function(reversed, forceParty)
	local unit = (not forceParty and _G.IsInRaid()) and "raid" or "party"
	local numGroupMembers = (forceParty and _G.GetNumSubgroupMembers() or _G.GetNumGroupMembers())
		- (unit == "party" and 1 or 0)
	local i = reversed and numGroupMembers or (unit == "party" and 0 or 1)
	return function()
		local ret
		if i == 0 and unit == "party" then
			ret = "player"
		elseif i <= numGroupMembers and i > 0 then
			ret = unit .. i
		end
		i = i + (reversed and -1 or 1)
		return ret
	end
end

local GetUnitNameWithColor = function(unit)
	local _, class = _G.UnitClass(unit)
	if not class then
		return
	end
	return _G.RAID_CLASS_COLORS[class]:WrapTextInColorCode(UnitName(unit))
end

function SAP:OnShow(self)
	if not _G.SimpleAnimaPowersFrame_MainContainer:IsShown() then
		_G.SimpleAnimaPowersFrame_MainContainer:Show()
	end
end

function SAP:UpdateGUI(t)
	local frame = _G.SimpleAnimaPowersFrame
	local container = _G.SimpleAnimaPowersFrame_MainContainer

	container:ReleaseChildren()
	-- loop through and add labels for each power + group member with power
	local pinned = pinnedPowers()
	local sortedKeys = {}
	for k, v in pairs(t) do
		table.insert(sortedKeys, k)
	end

	table.sort(sortedKeys, function(a, b)
		local a_pinned = tableHasValue(pinned, a)
		local b_pinned = tableHasValue(pinned, b)

		if a_pinned and not b_pinned then
			return true
		elseif b_pinned and not a_pinned then
			return false
		else
			return tonumber(a) > tonumber(b)
		end
	end)

	for _, k in ipairs(sortedKeys) do
		local spellId = k
		local spellLabel = GUI:Create("InteractiveLabel")
		spellLabel:SetFullWidth(true)
		spellLabel:SetFont(_G.GameFontNormalHuge2:GetFont())
		spellLabel:SetCallback("OnEnter", function(widget)
			local tooltip = GameTooltip
			tooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			tooltip:SetHyperlink(GetSpellLink(spellId))
			tooltip:Show()
		end)
		spellLabel:SetCallback("OnLeave", function(widget)
			GameTooltip:FadeOut()
		end)

		local _, _, icon = GetSpellInfo(spellId)
		local ret = "|T"
			.. icon
			.. ":0|t "
			.. GetSpellLink(spellId)
			.. "  ["
			.. table.getn(t[k])
			.. "]"
			.. (pinned[spellId] ~= nil and "**" or "")
		spellLabel:SetText(ret)

		container:AddChild(spellLabel)

		-- loop through members

		table.sort(t[k], function(a, b)
			return a:upper() < b:upper()
		end)
		local unitsLabel = GUI:Create("Label")
		unitsLabel:SetFullWidth(true)
		unitsLabel:SetFont(_G.GameFontNormalLarge2:GetFont())

		local allNames = "        "
		for unitIndex, unitName in pairs(t[k]) do
			local name = GetUnitNameWithColor(unitName)
			local last = (unitIndex == table.getn(t[k]))

			allNames = allNames .. name .. (last and "" or ", ")
		end

		unitsLabel:SetText(allNames)

		container:AddChild(unitsLabel)

		-- add spacer after every group (makes it look a bit nicer)
		local spacer = GUI:Create("Label")
		spacer:SetFullWidth(true)
		spacer:SetHeight(10)
		spacer:SetText(" ")
		container:AddChild(spacer)
	end

	container:DoLayout()
end

function SAP:UpdateGroupPowers()
	-- reset powers list
	SAP.GroupPowers = {}
	SAP.DataTree = {}

	local pinned = pinnedPowers()

	-- pinned powers always show
	if table.getn(pinned) > 0 then
		for _, spellId in pairs(pinned) do
			SAP.GroupPowers[spellId] = {}
		end
	end

	-- loop group members and populate table
	for unit in GetGroupMembers() do
		local unitName = _G.UnitName(unit)
		local unitNameWithColor = GetUnitNameWithColor(unit)
		local MAW_BUFF_MAX_DISPLAY = 44
		for i = 1, MAW_BUFF_MAX_DISPLAY do
			local spellName, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId =
				_G.UnitAura(
					unit,
					i,
					"MAW"
				)
			if spellName ~= nil and spellId ~= nil then
				local spellLink, _ = _G.GetSpellLink(spellId)

				if SAP.GroupPowers[spellId] == nil then
					SAP.GroupPowers[spellId] = {}
				end

				_G.tinsert(SAP.GroupPowers[spellId], unitName)
			end
		end
	end

	SAP:UpdateGUI(SAP.GroupPowers)
end
