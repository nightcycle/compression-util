--!strict
local _Package = script.Parent
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
local Util = {}

function Util.toBaseN(value: number, base: number, characters: {[number]: string}): string
	assert(value == math.round(value), `non-integers not supported ({value})`)
	assert(value >= 0, `negative numbers not supported ({value})`)
	assert(#characters == base, `base {base} doesn't match number of characters ({#characters})`)
	local out = ""
	local function reduce(current: number)
		local remainder = value % base
		local quotient = (value-remainder)/base
		local char = characters[quotient]
		out ..= char
		if remainder > 0 then
			reduce(quotient)
		end
	end
	reduce(value)
	return out
end

function Util.toBase10(value: string, base: number, characters: {[number]: string}): number
	assert(#characters == base, `base {base} doesn't match number of characters ({#characters})`)
	local out = 0
	local function expand(current: string)
		local exp = value:len()-1
		local weight = table.find(characters, current:sub(1,1))
		assert(weight)
		out += weight * (base ^ exp)
		if exp > 0 then
			expand(current:sub(2, current:len()))
		end
	end
	expand(value)
	return out
end

return Util