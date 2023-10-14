--!strict
local _Package = script
local _Packages = _Package.Parent

-- Services
-- Packages
-- Modules

-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Util = {
	Encoding = {
		ASCII = require(_Package:WaitForChild("Encoding"):WaitForChild("ASCII")),
		BaseN = require(_Package:WaitForChild("Encoding"):WaitForChild("BaseN")),
		Base64 = require(_Package:WaitForChild("Encoding"):WaitForChild("Base64")),
		Bit = require(_Package:WaitForChild("Encoding"):WaitForChild("Bit")),
		Byte = require(_Package:WaitForChild("Encoding"):WaitForChild("Byte")),
		UTF8 = require(_Package:WaitForChild("Encoding"):WaitForChild("UTF8")),
	},
	Array = require(_Package:WaitForChild("Array")),
	Dictionary = require(_Package:WaitForChild("Dictionary")),
	Types = require(_Package:WaitForChild("Types")),
}

return Util