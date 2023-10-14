--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.toUTF8(val: string): string
	local array = {}
	for i = 1, #val do
		local b = string.byte(val, i)
		array[i] = b
	end
	return utf8.char(unpack(array))
end
function Util.fromUTF8(val: string): string
	local out = ""
	for i, code in utf8.codes(val) do
		out ..= string.char(code)
	end
	return out
end

return Util