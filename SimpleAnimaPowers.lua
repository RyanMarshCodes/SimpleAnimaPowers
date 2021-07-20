local _G = _G
local C = _G.LibStub("AceConsole-3.0")
local CR = _G.LibStub("AceConfigRegistry-3.0")
local CD = _G.LibStub("AceConfigDialog-3.0")
local GUI = _G.LibStub("AceGUI-3.0")
local SAP = _G.LibStub("AceAddon-3.0"):NewAddon("SimpleAnimaPowers", "AceEvent-3.0")
_G.SAP = SAP

local tableHasValue = function(t, v)
    for key, val in pairs(t) do
        if val == v then
            return true
        end
    end

    return false
end

local torghastZones = {2162, 10472, 13400, 13403, 13404, 13411}
local inInstance, instanceType = _G.IsInInstance()

local IsInTorghast = function()
    local currentMapID = select(8, _G.GetInstanceInfo())

    return (inInstance and (tableHasValue(torghastZones, currentMapID)))
end

local IsInMPlus = function()
    local _, _, difficulty, _, _, _, _, _ = GetInstanceInfo()
    local _, elapsed_time = GetWorldElapsedTime(1)

    return C_ChallengeMode.IsChallengeModeActive() and difficulty == 8 and elapsed_time >= 0
end

local IsInSanctum = function()
    return (inInstance and currentMapID == 13561)
end

SAP.GroupPowers = {}

SAP.BackdropA = {
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {left = 5, right = 5, top = 5, bottom = 5}
}

SAP.DataTree = {}

_G.SLASH_SAP1 = "/sap"
_G.SLASH_SAP2 = "/simpleanimapowers"

_G.SlashCmdList["SAP"] = function()
    SAP:UpdateGroupPowers()

    if not _G.SimpleAnimaPowersFrame:IsVisible() then
        _G.SimpleAnimaPowersFrame:Show()
    else
        _G.SimpleAnimaPowersFrame:Hide()
    end
end

function SAP:OnInitialize()
    SAP:RegisterEvent("ADDON_LOADED", "OnLoad")
end

function SAP:OnLoad(self, addon, ...)
    if (addon == "SimpleAnimaPowers") then
        print("this got called?")
        SAP:RegisterEvent("CHAT_MSG_LOOT", "OnLoot")

        if not _G.SAPSettings then
            _G.SAPSettings = SAP.DefaultConfig
        end

        SAP.Settings = _G.SAPSettings

        CR:RegisterOptionsTable("SimpleAnimaPowers", SAP.AceConfig, nil)
        SAP.OptionsMenu = _G.LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SimpleAnimaPowers", "SimpleAnimaPowers")

        _G.SimpleAnimaPowersFrame = GUI:Create("Frame")
        local frame = _G.SimpleAnimaPowersFrame
        frame:SetWidth(400)
        frame:SetHeight(300)
        frame:SetPoint("LEFT", 50, 0, _G.UIParent)
        frame:SetTitle("SimpleAnimaPowers")
        frame:SetLayout("Fill")
        -- frame:SetMovable(true)
        -- frame:EnableMouse(true)
        -- frame:RegisterForDrag("LeftButton")
        -- frame:SetScript("OnDragStart", frame.StartMoving)
        -- frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetCallback(
            "OnShow",
            function()
                SAP:OnShow(SAP)
            end
        )

        _G.SimpleAnimaPowersFrame_MainContainer = GUI:Create("ScrollFrame")
        local container = _G.SimpleAnimaPowersFrame_MainContainer
        container:SetLayout("List")
        container:SetFullHeight(true)
        container:SetFullWidth(true)
        frame:AddChild(container)

        _G.tinsert(_G.UISpecialFrames, "SimpleAnimaPowersFrame")
    end
end

function SAP:OnLoot(self, event, ...)
    if (event == "CHAT_MSG_LOOT") then
        local message = select(1, ...)

        if _G.strfind(message, MAW_POWER_DESCRIPTION) ~= nil then
            if ((SAP.Settings.Tarragrue and IsInSanctum()) or (SAP.Settings.Torghast and IsInTorghast()) or IsInMPlus()) then
                SAP:UpdateGroupPowers()
            end
        end
    end
end
