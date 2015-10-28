-----------------------------------------------------------------------------------------------
-- Client Lua Script for SonOfKillroy
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- SonOfKillroy Module Definition
-----------------------------------------------------------------------------------------------

local bHasConfigure = true
local tDependencies = {}
					
local SonOfKillroy = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("SonOfKillroy", 
	bHasConfigure, tDependencies, "Gemini:Hook-1.0")

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local ChatLog, GeminiTimer, GeminiHook, GeminiLogging

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

-----------------------------------------------------------------------------------------------
-- SonOfKillroy OnInitalize
-----------------------------------------------------------------------------------------------
function SonOfKillroy:OnInitialize()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("SonOfKillroy.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	--[[
	GeminiHook = Apollo.GetPackage("Gemini:Hook-1.0")
	GeminiHook:Embed(SonOfKillroy)
	GeminiTimer = Apollo.GetPackage("Gemini:Timer-1.0")
	GeminiTimer:Embed(SonOfKillroy)
	]]--

end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy OnDocLoaded
-----------------------------------------------------------------------------------------------
function SonOfKillroy:OnDocLoaded()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
	self.glog = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
	    pattern = "%d %n %c %l - %m",
	    appender = "GeminiConsole"
	})
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "SonOfKillroyForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		--self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("sok", "OnSonOfKillroyOn", self)
		-- Do additional Addon initialization here
	end
end

function SonOfKillroy:OnEnable()
		Apollo.RegisterEventHandler("ChatLogIsReady", "OnChatLogIsReady", self)
		self.ChatLogTimer = ApolloTimer.Create(1, true, "OnChatLogTimer", self)
		self.glog:info("Test")
end
-----------------------------------------------------------------------------------------------
-- SonOfKillroy Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here
function SonOfKillroy:OnChatLogTimer()
	ChatLog = Apollo.GetAddon("ChatLog")
	if ChatLog then
		self.ChatLogTimer:Stop()
		Event_FireGenericEvent("ChatLogIsReady")
		self.glog:info("EventFired")
	else
		self.glog:info("EventNotFired")
		return nil
	end
end

function SonOfKillroy:OnChatLogIsReady()
	self:RawHook(Apollo.GetAddon("ChatLog"), "HelperGenerateChatMessage")
end

function SonOfKillroy:HelperGenerateChatMessage(luaCaller, tQueuedMessage)
	self.glog:info("Into Hook")
	self.glog:info(tostring(tQueuedMessage))
	for i,v in ipairs(tQueuedMessage) do
		self.glog:info("fired")
		self.glog:info(i,v)
	end
	self.hooks[Apollo.GetAddon("ChatLog")].HelperGenerateChatMessage(luaCaller, tQueuedMessage)
	if tQueuedMessage.strMessage then
		self.glog:info(tQueuedMessage.strMessage)
	end
	if tQueuedMessage.xml then
		self.glog:info(tQueuedMessage.xml:ToString())
	end
end
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
--SonOfKillroyInst:Initialize()
