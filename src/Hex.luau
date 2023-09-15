--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
local BaseN = require(_Package:WaitForChild("BaseN"))
-- Types
-- Constants
local HEX_CHARACTERS = {"0", "1", "2", "3", "4", "5", "6", "8", "9", "A", "B", "C", "D", "E", "F"}

-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.toHexFromBase10(value: number): string
	return BaseN.toBaseN(value, 16, HEX_CHARACTERS)
end

function Util.toBase10FromHex(value: string): number
	return BaseN.toBase10(value:upper(), 16, HEX_CHARACTERS)
end

return Util
