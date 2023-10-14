--!strict
local _Package = script.Parent.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
local BaseN = require(_Package:WaitForChild("Encoding"):WaitForChild("BaseN"))
-- Types
-- Constants
local CHARACTERS = ""
for i=0, 127 do
	CHARACTERS ..= utf8.char(i)
end

-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.toASCII(value: number): string
	return BaseN.toBaseN(value, 128, CHARACTERS)
end

function Util.fromASCII(char: string): number
	return BaseN.fromBaseN(char, 128, CHARACTERS)
end

function Util.toASCIIArray(str: string): {[number]: number}
	local out: {[number]: number} = {}
	for i=1, str:len() do
		out[i] = Util.fromASCII(str:sub(i,i))
	end
	return out
end

function Util.fromASCIIArray(array: {[number]: number}): string
	local out = ""
	for i, v in ipairs(array) do
		out ..= Util.toASCII(v)
	end
	return out
end

return Util