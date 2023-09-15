--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
local TableUtil = require(_Packages:WaitForChild("TableUtil"))

-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.encode<K,V>(
	dict: {[K]: V}, 
	keyArrayEncoder: (array: {[number]: K}) -> string, 
	valueArrayEncoder: (array: {[number]: V}) -> string
): string
	local keys: {[number]: K} = TableUtil.keys(dict)
	table.sort(keys)
	local values: {[number]: V} = {}
	for i, k in ipairs(keys) do
		values[i] = dict[k]
	end

	local encodedKeys = keyArrayEncoder(keys)
	local encodedValues = valueArrayEncoder(values)

	return string.pack("ss", encodedKeys, encodedValues)	
end

function Util.decode<K,V>(
	encodedDictionary: string, 
	keyArrayDecoder: (encodedArray: string) -> {[number]: K}, 
	valueArrayDecoder: (encodedArray: string) -> {[number]: V}
): {[K]: V}
	local encodedKeys, encodedValues = string.unpack("ss", encodedDictionary)	

	local keys: {[number]: K} = keyArrayDecoder(encodedKeys)
	local values: {[number]: V} = valueArrayDecoder(encodedValues)

	local out: {[K]: V} = {}
	for i, k in ipairs(keys) do
		out[k] = values[i]
	end

	return out
end


return Util