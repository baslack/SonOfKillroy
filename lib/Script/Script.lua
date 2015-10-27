--[[
Script. A library of functions that I use between my various addons.
]]--

local MAJOR, MINOR = "Script-1.0", 1
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

--ModuleDefn
local Script = APkg and APkg.tPackage or {}

--Constructor
function Script:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

--Script Functions

--Register Package
Apollo.RegisterPackage(Script:new(), MAJOR, MINOR, {})