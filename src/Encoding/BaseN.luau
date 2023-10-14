--!strict
local _Package = script.Parent.Parent
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

function Util.toBaseN(value: number, base: number, characters: string): string
	assert(value == math.floor(value), "non-integers not supported (" .. value .. ")")
	assert(base > 0, "base needs to be above 0, currently " .. base)
	assert(base == math.floor(base), "base needs to be integer, currently " .. base)
	assert(value >= 0, "negative numbers not supported (" .. value .. ")")
	assert(#characters == base, "base " .. base .. " doesn't match number of characters (" .. #characters .. ")")

	local out = ""

	while value > 0 do
		local remainder = value % base
		local index = remainder + 1
		local char = characters:sub(index,index)
		assert(char ~= nil and char ~= "", `bad character {char} at index {index}`)
		out = char .. out
		value = math.floor(value / base)
	end

	return out == "" and characters:sub(1,1) or out
end

function Util.fromBaseN(value: string, base: number, characters: string): number
	assert(characters:len() == base, "base " .. base .. " doesn't match number of characters (" .. characters:len() .. ")")
	local out = 0

	local function expand(current: string)
		local exp = current:len() - 1
		local weight = string.find(characters, current:sub(1, 1))

		assert(weight, "couldn't find character " .. current:sub(1, 1) .. " of len " .. value:len() .. " in string " .. current .. " in character set")
		out += (weight - 1) * (base ^ exp) -- Decrement weight by 1

		if exp > 0 then
			expand(current:sub(2))
		end
	end

	expand(value)
	return out
end

return Util