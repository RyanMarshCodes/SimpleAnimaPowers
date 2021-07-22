local _G = _G
local SAP = _G.SAP
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleAnimaPowers")

SAP.DefaultConfig = {
	Tarragrue = true,
	Torghast = true,
	MPlus = true,
	PinnedSpells = "",
	WindowIsLocked = false,
}

SAP.AceConfig = {
	type = "group",
	args = {
		tarragrue = {
			name = L["Enable for Sanctum of Dominion: Tarragrue"],
			type = "toggle",
			width = "full",
			order = 2,
			set = function(_, val)
				SAP.Settings.Tarragrue = val
				SAP:UpdateConfig()
			end,
			get = function(_)
				return SAP.Settings.Tarragrue
			end,
		},
		torghast = {
			name = L["Enable for Torghast"],
			type = "toggle",
			width = "full",
			order = 3,
			set = function(_, val)
				SAP.Settings.Torghast = val
			end,
			get = function(_)
				return SAP.Settings.Torghast
			end,
		},
		mPlus = {
			name = L["Enable for Mythic Dungeons"],
			type = "toggle",
			width = "full",
			order = 4,
			set = function(_, val)
				SAP.Settings.MPlus = val
			end,
			get = function(_)
				return SAP.Settings.MPlus
			end,
		},
		pinnedSpells = {
			name = L["Pinned spell IDs"],
			desc = L["Separate spell IDs by comma"] .. "\r\n(e.g 337620,338733,337613)",
			type = "input",
			width = "full",
			order = 5,
			set = function(_, val)
				SAP.Settings.PinnedSpells = val
			end,
			get = function(_)
				return SAP.Settings.PinnedSpells
			end,
		},
		lockWindow = {
			name = L["Lock Frame"],
			desc = L["Lock frame position and size"],
			type = "toggle",
			width = "full",
			order = 1,
			set = function(_, val)
				SAP.Settings.WindowIsLocked = val

				if SAP.Settings.WindowIsLocked then
					_G.SimpleAnimaPowersFrame.frame:SetMovable(false)
					_G.SimpleAnimaPowersFrame.frame:SetResizable(false)
				else
					_G.SimpleAnimaPowersFrame.frame:SetMovable(true)
					_G.SimpleAnimaPowersFrame.frame:SetResizable(true)
				end
			end,
			get = function(_)
				return SAP.Settings.WindowIsLocked
			end,
		},
	},
}
