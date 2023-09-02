--!strict
local _Package = script
local _Packages = _Package.Parent

-- Services
local HttpService = game:GetService("HttpService")
-- Packages
local HashUtil = require(_Packages:WaitForChild("HashUtil"))
local TableUtil = require(_Packages:WaitForChild("TableUtil"))
-- Modules
-- Types

type Data = {[any]: any}
type ConverterTable<T> = {
	Encode: (T) -> Data,
	Decode: (Data) -> T,
}

-- Constants
local INF_INTEGER = 922337203685477600
local INTEGER_PACK_ENCODING_CHAR = "l"
local FLOAT_PACK_ENCODING_CHAR = "n"
local DOUBLE_PACK_ENCODING_CHAR = "d"

local STRING_PACK_ENCODING_CHAR = "s"
local KEYS = {
	"BrickColor",
	"CFrame",
	"Color3",
	"ColorSequence",
	"ColorSequenceKeypoint",
	"DateTime",
	"Enum",
	"EnumItem",
	"NumberRange",
	"NumberSequence",
	"NumberSequenceKeypoint",
	"PathWaypoint",
	"PhysicalProperties",
	"Ray",
	"Rect",
	"Region3",
	"Region3int16",
	"TweenInfo",
	"UDim",
	"UDim2",
	"Vector2",
	"Vector2int16",
	"Vector3",
	"Vector3int16",
	"nil",
	"number",
	"string",
	"boolean",
	"table"
}
-- Variables
-- References
-- Private Functions
function encodeNumberArray(source: {[number]: number}, format: string): string?
	if #source == 0 then
		return nil
	else
		local array = table.clone(source)
		table.insert(array, 1, #array)
		local encoding = string.pack(format:rep(#array), unpack(array))
		return encoding
	end
end
function decodeNumberArray(value: string?, format: string): {[number]: number}
	if value then
		local charCount = string.unpack(format, value)+1
		local array = {string.unpack(format:rep(charCount), value)}
		table.remove(array, 1)
		table.remove(array, #array)
		return array
	else
		return {}
	end
end
-- Class
local Util = {}

function Util.encodeIntegerArray(array: {[number]: number}): string?
	for i, v in ipairs(array) do
		if v == v then
			array[i] = math.clamp(v, -INF_INTEGER, INF_INTEGER)
		else
			array[i] = nil
		end
	end
	return encodeNumberArray(array, INTEGER_PACK_ENCODING_CHAR)
end

function Util.decodeIntegerArray(value: string?): {[number]: number}
	local array = decodeNumberArray(value, INTEGER_PACK_ENCODING_CHAR)
	return array
end

function Util.encodeFloatArray(array: {[number]: number}): string?
	return encodeNumberArray(array, FLOAT_PACK_ENCODING_CHAR)
end

function Util.decodeFloatArray(value: string?): {[number]: number}
	return decodeNumberArray(value, FLOAT_PACK_ENCODING_CHAR)
end

function Util.encodeDoubleArray(array: {[number]: number}): string?
	return encodeNumberArray(array, DOUBLE_PACK_ENCODING_CHAR)
end

function Util.decodeDoubleArray(value: string?): {[number]: number}
	return decodeNumberArray(value, DOUBLE_PACK_ENCODING_CHAR)
end

function Util.decode<T>(encodedData: string): T

end

function Util.encode(data: Data): string

end

return Util