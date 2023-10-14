--!strict
local _Package = script.Parent.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
local BaseN = require(_Package:WaitForChild("Encoding"):WaitForChild("BaseN"))
-- Types
-- Constants
local CHARACTERS = "01"

-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.fromArray(value: {[number]: boolean}): string
	local out = ""
	for i, v in ipairs(value) do
		out ..= if v then "1" else "0"
	end
	return out
end

function Util.toArray(value: string): {[number]: boolean}
	local out: {[number]: boolean} = {}
	for i=1, value:len() do
		out[i] = value:sub(i,i) == "1"
	end
	return out
end

function Util.toBits(value: number): string
	return BaseN.toBaseN(value, 2, CHARACTERS)
end

function Util.fromBits(value: string): number
	return BaseN.fromBaseN(value, 2, CHARACTERS)
end

return Util
