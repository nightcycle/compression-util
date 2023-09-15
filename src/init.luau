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
	Array = require(_Package:WaitForChild("Array")),
	BaseN = require(_Package:WaitForChild("BaseN")),
	Binary = require(_Package:WaitForChild("Binary")),
	Dictionary = require(_Package:WaitForChild("Dictionary")),
	Hex = require(_Package:WaitForChild("Hex")),
	Types = require(_Package:WaitForChild("Types")),
}

return Util