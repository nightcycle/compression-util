--!strict
local _Package = script.Parent.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
local BaseN = require(_Package:WaitForChild("Encoding"):WaitForChild("BaseN"))
-- Types
-- Constants
local CHARACTERS = "0123456789ABCDEF"

-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.toByte(value: number): string
	return BaseN.toBaseN(value, 16, CHARACTERS)
end

function Util.fromByte(value: string): number
	return BaseN.fromBaseN(value:upper(), 16, CHARACTERS)
end

return Util
