--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local UNSIGNED_SHORT_LIMIT = 65535

-- Variables
-- References
-- Private Functions


-- Class
local Util = {}

function Util.encode<V>(source: {[number]: V}, format: string): string
	if #source == 0 then
		return ""
	else
		assert(UNSIGNED_SHORT_LIMIT >= #source, `Array encoding limited to a length of {UNSIGNED_SHORT_LIMIT}, currently {#source}`)
		local array: {[number]: V | number} = table.clone(source)
		table.insert(array, 1, #array)
		local encoding = string.pack("H"..format:rep(#array-1), unpack(array))
		return encoding
	end
end

function Util.decode<V>(encodedValue: string, format: string): {[number]: V}
	if encodedValue ~= "" then
		local charCount = string.unpack("H", encodedValue)
		local array = {string.unpack("H"..format:rep(charCount), encodedValue)}
		table.remove(array, 1)
		table.remove(array, #array)
		return array
	else
		return {}
	end
end

Util.Long = {
	encode = function(array: {[number]: number}, isUnsigned: boolean): string
		return Util.encode(array, if isUnsigned then "L" else "l")
	end,
	decode = function(encodedValue: string, isUnsigned: boolean): {[number]: number}
		return Util.decode(encodedValue, if isUnsigned then "L" else "l")
	end
}

Util.Short = {
	encode = function(array: {[number]: number}, isUnsigned: boolean): string
		return Util.encode(array, if isUnsigned then "H" else "h")
	end,
	decode = function(encodedValue: string, isUnsigned: boolean): {[number]: number}
		return Util.decode(encodedValue, if isUnsigned then "H" else "h")
	end,	
}

Util.Number = {
	encode = function(array: {[number]: number}, isUnsigned: boolean): string
		return Util.encode(array, "n")
	end,
	decode = function(encodedValue: string, isUnsigned: boolean): {[number]: number}
		return Util.decode(encodedValue, "n")
	end,	
}

Util.String = {
	encode = function(array: {[number]: string}): string
		return Util.encode(array, "s")
	end,
	decode = function(encodedValue: string): {[number]: string}
		return Util.decode(encodedValue, "s")
	end,
}

return Util