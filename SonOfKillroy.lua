-----------------------------------------------------------------------------------------------
-- Client Lua Script for SonOfKillroy2
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- SonOfKillroy2 Module Definition
-----------------------------------------------------------------------------------------------
local SonOfKillroy2 = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function SonOfKillroy2:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function SonOfKillroy2:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- SonOfKillroy2 OnLoad
-----------------------------------------------------------------------------------------------
function SonOfKillroy2:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("SonOfKillroy2.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy2 OnDocLoaded
-----------------------------------------------------------------------------------------------
function SonOfKillroy2:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "SonOfKillroy2Form", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("sok", "OnSonOfKillroy2On", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy2 Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/sok"
function SonOfKillroy2:OnSonOfKillroy2On()
	self.wndMain:Invoke() -- show the window
end


-----------------------------------------------------------------------------------------------
-- SonOfKillroy2Form Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function SonOfKillroy2:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function SonOfKillroy2:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- SonOfKillroy2 Instance
-----------------------------------------------------------------------------------------------
local SonOfKillroy2Inst = SonOfKillroy2:new()
SonOfKillroy2Inst:Init()
