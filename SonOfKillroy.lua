-----------------------------------------------------------------------------------------------
-- Client Lua Script for SonOfKillroy
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- SonOfKillroy Module Definition
-----------------------------------------------------------------------------------------------
local SonOfKillroy = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function SonOfKillroy:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function SonOfKillroy:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- SonOfKillroy OnLoad
-----------------------------------------------------------------------------------------------
function SonOfKillroy:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("SonOfKillroy.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy OnDocLoaded
-----------------------------------------------------------------------------------------------
function SonOfKillroy:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "SonOfKillroyForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("sok", "OnSonOfKillroyOn", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/sok"
function SonOfKillroy:OnSonOfKillroyOn()
	self.wndMain:Invoke() -- show the window
end


-----------------------------------------------------------------------------------------------
-- SonOfKillroyForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function SonOfKillroy:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function SonOfKillroy:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- SonOfKillroy Instance
-----------------------------------------------------------------------------------------------
local SonOfKillroyInst = SonOfKillroy:new()
SonOfKillroyInst:Init()
