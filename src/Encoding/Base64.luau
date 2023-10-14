--!strict
local _Package = script.Parent.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
local BaseN = require(_Package:WaitForChild("Encoding"):WaitForChild("BaseN"))
-- Types
-- Constants
local CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.toBase64(value: number): string
	return BaseN.toBaseN(value, 64, CHARACTERS)
end

function Util.fromBase64(value: string): number
	return BaseN.fromBaseN(value:upper(), 64, CHARACTERS)
end

return Util
