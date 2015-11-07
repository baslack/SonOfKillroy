-----------------------------------------------------------------------------------------------
-- Client Lua Script for SonOfKillroy
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- SonOfKillroy Module Definition
-----------------------------------------------------------------------------------------------

local bHasConfigure = true
local tDependencies = {"Gemini:Hook-1.0", "Gemini:Logging-1.2", "GeminiColor"}
					
local SonOfKillroy = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("SonOfKillroy", 
	bHasConfigure, tDependencies, "Gemini:Hook-1.0")

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999

local kclrQuote, kclrEmote, kclrOOC, kclrMention

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
local ChatLog, GeminiHook, GeminiLogging, GeminiColor


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

	--logging
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
	self.glog = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
	    pattern = "%d %n %c %l - %m",
	    appender = "GeminiConsole"
	})
	GeminiColor = Apollo.GetPackage("GeminiColor").tPackage
	
	--init default colors
	kclrQuote = "FF"..GeminiColor:GetColorStringByName("White")
	kclrEmote = "FF"..GeminiColor:GetColorStringByName("Orange")
	kclrOOC = "FF"..GeminiColor:GetColorStringByName("Cyan")
	kclrMention = "FF"..GeminiColor:GetColorStringByName("Pink")
end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy OnDocLoaded
-----------------------------------------------------------------------------------------------
function SonOfKillroy:OnDocLoaded()
	self.glog:info("OnDocLoaded")
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "SonOfKillroyForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil		
	end
end

-----------------------------------------------------------------------------------------------
-- SonOfKillroy OnEnable
-----------------------------------------------------------------------------------------------
function SonOfKillroy:OnEnable()
	self.glog:info("OnEnable")
	
	--slash
	Apollo.RegisterSlashCommand("sok", "OnSonOfKillroyOn", self)
	
	--eventhandlers
	Apollo.RegisterEventHandler("ChatLogIsReady", "OnChatLogIsReady", self)
	
	--timers
	self.ChatLogTimer = ApolloTimer.Create(1, true, "OnChatLogTimer", self)
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
	self.tXml = {}
	self.glog:info("Hook: HelperGenerateChatMessage")
	self.glog:info(tostring(tQueuedMessage))
	for i,v in ipairs(tQueuedMessage) do
		self.glog:info(i,v)
	end
	self.hooks[Apollo.GetAddon("ChatLog")].HelperGenerateChatMessage(luaCaller, tQueuedMessage)
	if tQueuedMessage.strMessage then
		self.glog:info(tQueuedMessage.strMessage)
	end
	if tQueuedMessage.xml then
		--self.glog:info(tQueuedMessage.xml:ToString())
		table.insert(self.tXml, tQueuedMessage.xml:ToTable())
		tQueuedMessage.xml = self:FormatForRP(tQueuedMessage.xml)
		Event_FireGenericEvent("SendVarToRover", "SonOfKillroy", Apollo.GetAddon("SonOfKillroy"),0)
	end
end

function SonOfKillroy:FormatForRP(xml)
	self.glog:info("FormatForRP")
	local bBeginParse = false
	local bStateEmote, bStateOOC, bStateQuote = false, false, false
	local tXml = xml:ToTable()
	local tNewXml = {}
	local strCollect = ""
	
	-- this isn't technically necessary, but it allows me to view
	-- the original and generated tables for XML creation
	function transcribeTable(t, target)
		for i,v in pairs(t) do
			if type(v) == "table" then
				target[i] = {}
				transcribeTable(v, target[i])
			else
				target[i] = v
			end
		end
	end
	
	function parseTable(t)
		--assuming we get a properly formated table
		if t.__XmlNode == "Root" and t[1].__XmlNode =="P" then
			self.glog:info("parseTable")
			--renamed for convenience and clairity
			tParagraph = t[1]
			--this table will collect the addtions that parsing
			--makes to the XML
			tCollect = {}
			--because we're going to be adding elements, we can't
			--rely on the index from the for loop
			index = 0
			for i, this in pairs(tParagraph) do
				self.glog:info(i)
				if type(i) == "number" then
					--increment for each numbered sub node of P
					index = index + 1
					table.insert(tCollect, index, this)
				else
					--tag fields simply transcribe
					tCollect[i] = this
				end
				--parsing only considers "nodes"
				if this.__XmlNode then
					self.glog:info("__XmlNode exists")
					self.glog:info(this.__XmlNode)
					--more specifically, "Text" nodes
					if this.__XmlNode == "Text" then
						-- bBeginParse is a boolean that gets set
						-- true after the ": " separator is found
						-- this prevents parsing from doing anything
						-- to the time stamp and channel name
						if bBeginParse then
							-- for this test, we're simply copying a
							-- another text node in. In the final parse
							-- this will break out the string for
							-- emotes, mentions, etc.
							
							--dummy code for testing insertion of nodes
							--[[
							self.glog:info("add Text Node")
							local tNewTextNode = {}
							for j, w in pairs(this) do
								tNewTextNode[j] = w
								tNewTextNode.TextColor = kclrEmote
							end
							--because we're adding nodes, we increment
							index = index + 1
							table.insert(tCollect, index, tNewTextNode)
							]]--
							
							--assuming we have a text node that actually 
							--has text, we can start breaking it up
							if this[1] then
								local strSegment = this[1].__XmlText
								local charEmote = '*'
								local charQuote = '"'
								local charOOC_Start = '(('
								local charOOC_End = '))'
								local tMentions = {'Mention', 'Mention2'}
								local tParse = {}
								
								local tMentionCharacters = {}
								--marks out mentions
								for i, this_mention in ipairs(tMentions) do
									local start, finish = string.find(strSegment, this_mention)
									while start and finish do --a match was found
										-- tag the found characters
										for j = start, finish do
											tMentionCharacters[j] = true
										end
										--look again
										start, finish = string.find(strSegment, this_mention, finish+1)
									end
								end

								local tEmoteCharacters = {}
								--marks out emotes
								for i=1, string.len(strSegment) do
									--currently in an emote
									if bStateEmote then
										--record the index
										tEmoteCharacters[i] = true
									end
									if string.sub(strSegment, i) == charEmote then
										--toggle the Emote State
										bStateEmote = not(bStateEmote)
										--the marker always is part of the emote
										tEmoteCharacters[i] = true
									end
								end
								
								local tQuoteCharacters = {}
								--marks out Quotes
								for i=1, string.len(strSegment) do
									--currently in an emote
									if bStateQuote then
										--record the index
										tQuoteCharacters[i] = true
									end
									if string.sub(strSegment, i) == charQuote then
										--toggle the Emote State
										bStateEmote = not(bStateQuote)
										--the marker always is part of the emote
										tQuoteCharacters[i] = true
									end
								end
								
								local tOOCCharacters = {}
								--marks out OOCs
								--there are three cases for an OOC block
								--case1 "<ooctext>))<ictext>"
								--case2 "<ictext>((<ooctext>"
								--case3 "<ictext>((<ooctext>))<ictext>"
								--with one edge case
								--edgecase "<ooctext>))<ictext>((<ooctext>"
								
								--case1
								--the only way this works if if there was previously
								--a case2 or case4 to begin the ooc block
								--therefore those cases will have to set the
								--OOC state boolean. If that state is set, and case1
								--occurs, then we format
								
								--case2
								--if this case occurs, the ooc branch has not been
								--closed we can't know if a branch WILL close however
								--if it doesn't, do we assume the rest is OOC?
								--if we don't, how would be know?
								--don't want to have to backtrack again through the 
								--xml twice
								
								--case3
								--easiest case. Every edition of this gets formatted.
								--iterate through them with gmatch and then use find
								--to get indexes
								
								--edgecase
								--this combines 1 and 2. For the closer to trigger,
								--the OOC state would need to have been activated previous
								--for the opener to trigger, we still have to decide
								--about what we want to happen in it never get's closed
								
									
									
									
									

									
							
						end
						-- this is the code that checks for the separator							
						if this[1] then
							if this[1].__XmlText == ": " then
								self.glog:info("Separator Found")
								bBeginParse = true
							end
						end
					end
				end
			end
			-- have to set the paragraph node directly to get it to pass back
			t[1] = tCollect
		end
	end
			
	-- makes a copy for us to work with
	transcribeTable(tXml, tNewXml)
	-- makes our modifications
	parseTable(tNewXml)
	-- adds the table to the globals for checking purposes
	table.insert(self.tXml, tNewXml)
	-- returns the XML our new table generates
	return XmlDoc.CreateFromTable(tNewXml)
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
