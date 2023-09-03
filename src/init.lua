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
local POS_INT_PACK_ENCODING_CHAR = "L"
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
	-- "Ray",
	-- "Rect",
	-- "Region3",
	-- "Region3int16",
	-- "TweenInfo",
	-- "UDim",
	-- "UDim2",
	-- "Vector2",
	-- "Vector2int16",
	-- "Vector3",
	-- "Vector3int16",
	-- "number",
	-- "string",
	-- "boolean",
}
export type ValidTypes = (
	BrickColor | 
	CFrame | 
	Color3 | 
	ColorSequence | 
	ColorSequenceKeypoint | 
	DateTime | 
	Enum | 
	EnumItem | 
	NumberRange | 
	NumberSequence | 
	NumberSequenceKeypoint | 
	PathWaypoint | 
	PhysicalProperties --| 
	-- Ray | 
	-- Rect | 
	-- Region3 | 
	-- Region3int16 | 
	-- TweenInfo | 
	-- UDim | 
	-- UDim2 | 
	-- Vector2 | 
	-- Vector2int16 | 
	-- Vector3 | 
	-- Vector3int16 | 
	-- number | 
	-- string | 
	-- boolean
)

-- Variables
-- References
-- Private Functions
function encodeArray<V>(source: {[number]: V}, format: string): string
	if #source == 0 then
		return ""
	else
		local array: {[number]: V | number} = table.clone(source)
		table.insert(array, 1, #array)
		local encoding = string.pack(INTEGER_PACK_ENCODING_CHAR..format:rep(#array-1), unpack(array))
		return encoding
	end
end
function decodeArray<V>(encodedValue: string, format: string): {[number]: V}
	if encodedValue ~= "" then
		local charCount = string.unpack(INTEGER_PACK_ENCODING_CHAR, encodedValue)
		local array = {string.unpack(INTEGER_PACK_ENCODING_CHAR..format:rep(charCount), encodedValue)}
		table.remove(array, 1)
		table.remove(array, #array)
		return array
	else
		return {}
	end
end

function encodeBrickColor(value: BrickColor): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local encoding = string.pack(POS_INT_PACK_ENCODING_CHAR:rep(2), index, value.Number)
	return encoding
end

function decodeBrickColor(encodedValue: string): BrickColor
	local _index, num = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(2), encodedValue)
	return BrickColor.new(num)
end

function encodeCFrame(value: CFrame): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local rX, rY, rZ = value:ToEulerAnglesXYZ()
	local x, y, z = value.X, value.Y, value.Z

	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, x, y, z, rX, rY, rZ)
end

function decodeCFrame(encodedValue: string): CFrame
	local _index, x, y, z, rX, rY, rZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)
	return CFrame.new(x,y,z) * CFrame.fromEulerAnglesXYZ(rX, rY, rZ)
end

function encodeColor3(value: Color3): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local r,g,b = math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255)
	return string.pack(POS_INT_PACK_ENCODING_CHAR:rep(4), index, r,g,b)
end

function decodeColor3(encodedValue: string): Color3

	local _index, r,g,b =  string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(4), encodedValue)
	return Color3.fromRGB(r,g,b)
end

function encodeColorSequenceKeypoint(value: ColorSequenceKeypoint): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local r,g,b = math.round(value.Value.R * 255), math.round(value.Value.G * 255), math.round(value.Value.B * 255)
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR:rep(3), index, value.Time, r, g, b)
end

function decodeColorSequenceKeypoint(encodedValue: string): ColorSequenceKeypoint
	local _index, t, r,g,b = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR:rep(3), encodedValue)
	return ColorSequenceKeypoint.new(t, Color3.fromRGB(r,g,b))
end

function encodeColorSequence(value: ColorSequence): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local tArray: {[number]: number} = {}
	local rArray: {[number]: number} = {}
	local gArray: {[number]: number} = {}
	local bArray: {[number]: number} = {}

	for i, v in ipairs(value.Keypoints) do
		tArray[i] = v.Time
		rArray[i] = math.round(v.Value.R * 255)
		gArray[i] = math.round(v.Value.G * 255)
		bArray[i] = math.round(v.Value.B * 255)
	end

	local tEncoded = encodeArray(tArray, FLOAT_PACK_ENCODING_CHAR)
	local rEncoded = encodeArray(rArray, POS_INT_PACK_ENCODING_CHAR)
	local gEncoded = encodeArray(gArray, POS_INT_PACK_ENCODING_CHAR)
	local bEncoded = encodeArray(bArray, POS_INT_PACK_ENCODING_CHAR)
	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(4), index, tEncoded, rEncoded, gEncoded, bEncoded)
end

function decodeColorSequence(encodedValue: string): ColorSequence

	local _index, tEncoded, rEncoded, gEncoded, bEncoded = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(4), encodedValue)

	local tArray: {[number]: number} = decodeArray(tEncoded, FLOAT_PACK_ENCODING_CHAR)
	local rArray: {[number]: number} = decodeArray(rEncoded, POS_INT_PACK_ENCODING_CHAR)
	local gArray: {[number]: number} = decodeArray(gEncoded, POS_INT_PACK_ENCODING_CHAR)
	local bArray: {[number]: number} = decodeArray(bEncoded, POS_INT_PACK_ENCODING_CHAR)

	local keypoints: {[number]: ColorSequenceKeypoint} = {}
	for i, t in ipairs(tArray) do
		local r,g,b = rArray[i], gArray[i], bArray[i]
		keypoints[i] = ColorSequenceKeypoint.new(t, Color3.fromRGB(r,g,b))
	end

	return ColorSequence.new(keypoints)
end

function encodeDateTime(value: DateTime): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local data: {
		Year: number,
		Month: number, 
		Day: number,
		Hour: number, 
		Minute: number, 
		Second: number,
		Millisecond: number,
	} = value:ToUniversalTime() :: any

	local year, month, day, hour, minute, second, millisecond = data.Year, data.Month, data.Day, data.Hour, data.Minute, data.Second, data.Millisecond
	-- warn(year, month, day, hour, minute, second, millisecond)
	return string.pack(POS_INT_PACK_ENCODING_CHAR:rep(8), index, year, month, day, hour, minute, second, millisecond)
end

function decodeDateTime(encodedValue: string): DateTime
	local _index, year, month, day, hour, minute, second, millisecond = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(8), encodedValue)
	return DateTime.fromUniversalTime(year, month, day, hour, minute, second, millisecond)
end

function encodeEnum(value: Enum): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, index, tostring(value))
end

function decodeEnum(encodedValue: string): Enum

	local _index, name = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, encodedValue)

	return (Enum :: any)[name]
end
function encodeEnumItem(value: EnumItem): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR, index, tostring(value.EnumType), value.Value)
end

function decodeEnumItem(encodedValue: string): EnumItem

	local _index, enumName, enumValue = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR, encodedValue)
	local enum: Enum = (Enum :: any)[enumName]
	
	for i, v in ipairs(enum:GetEnumItems()) do
		if v.Value == enumValue then
			return v
		end
	end
	error(`bad enumItem {_index}, {enumName}, {enumValue}`)
end
function encodeNumberSequenceKeypoint(value: NumberSequenceKeypoint): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), index, value.Time, value.Value, value.Envelope)
end

function decodeNumberSequenceKeypoint(encodedValue: string): NumberSequenceKeypoint

	local _index, t, v, e = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), encodedValue)
	return NumberSequenceKeypoint.new(t, v, e)
end

function encodeNumberSequence(value: NumberSequence): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local tArray: {[number]: number} = {}
	local vArray: {[number]: number} = {}
	local eArray: {[number]: number} = {}

	for i, v in ipairs(value.Keypoints) do
		tArray[i] = v.Time
		vArray[i] = v.Value
		eArray[i] = v.Envelope
	end

	local tEncoded = encodeArray(tArray, FLOAT_PACK_ENCODING_CHAR)
	local vEncoded = encodeArray(vArray, FLOAT_PACK_ENCODING_CHAR)
	local eEncoded = encodeArray(eArray, FLOAT_PACK_ENCODING_CHAR)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(3), index, tEncoded, vEncoded, eEncoded)
end

function decodeNumberSequence(encodedValue: string): NumberSequence

	local _index, tEncoded, vEncoded, eEncoded = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(3), encodedValue)

	local tArray: {[number]: number} = decodeArray(tEncoded, FLOAT_PACK_ENCODING_CHAR)
	local vArray: {[number]: number} = decodeArray(vEncoded, FLOAT_PACK_ENCODING_CHAR)
	local eArray: {[number]: number} = decodeArray(eEncoded, FLOAT_PACK_ENCODING_CHAR)

	local keypoints: {[number]: NumberSequenceKeypoint} = {}
	for i, t in ipairs(tArray) do
		local v, e = vArray[i], eArray[i]
		keypoints[i] = NumberSequenceKeypoint.new(t, v, e)
	end

	return NumberSequence.new(keypoints)
end
function encodeVector3(value: Vector3): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local x, y, z = value.X, value.Y, value.Z
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), index, x,y,z)
end

function decodeVector3(encodedValue: string): Vector3
	local _index, x, y, z = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), encodedValue)
	return Vector3.new(x,y,z)
end

function encodePathWaypoint(value: PathWaypoint): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local action = value.Action
	local pos = value.Position

	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(2), index, encodeEnumItem(action), encodeVector3(pos))
end

function decodePathWaypoint(encodedValue: string): PathWaypoint
	local _index, encodedAction, encodedPosition = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(2), encodedValue)

	return PathWaypoint.new(
		decodeVector3(encodedPosition),
		decodeEnumItem(encodedAction) :: Enum.PathWaypointAction
	)
end

function encodePhysicalProperties(value: PhysicalProperties): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local density, elasticity, elasticWeight, friction, frictionWeight = value.Density, value.Elasticity, value.ElasticityWeight, value.Friction, value.FrictionWeight
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(5), index, density, elasticity, elasticWeight, friction, frictionWeight)
end

function decodePhysicalProperties(encodedValue: string): PhysicalProperties
	local _index, density, elasticity, elasticWeight, friction, frictionWeight = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(5), encodedValue)
	return PhysicalProperties.new(
		density,
		friction,
		elasticity,
		frictionWeight,
		elasticWeight
	)
end

-- Class
local Util = {}

function Util.encodeIntegerArray(array: {[number]: number}): string
	for i, v in ipairs(array) do
		if v == v then
			array[i] = math.clamp(v, -INF_INTEGER, INF_INTEGER)
		else
			array[i] = nil
		end
	end
	return encodeArray(array, INTEGER_PACK_ENCODING_CHAR)
end

function Util.decodeIntegerArray(encodedValue: string): {[number]: number}
	local array = decodeArray(encodedValue, INTEGER_PACK_ENCODING_CHAR)
	return array
end

function Util.encodeFloatArray(array: {[number]: number}): string
	return encodeArray(array, FLOAT_PACK_ENCODING_CHAR)
end

function Util.decodeFloatArray(encodedValue: string): {[number]: number}
	return decodeArray(encodedValue, FLOAT_PACK_ENCODING_CHAR)
end

function Util.encodeDoubleArray(array: {[number]: number}): string
	return encodeArray(array, DOUBLE_PACK_ENCODING_CHAR)
end

function Util.decodeDoubleArray(encodedValue: string): {[number]: number}
	return decodeArray(encodedValue, DOUBLE_PACK_ENCODING_CHAR)
end

function Util.encodeStringArray(array: {[number]: string}): string
	return encodeArray(array, STRING_PACK_ENCODING_CHAR)
end

function Util.decodeStringArray(encodedValue: string): {[number]: string}
	return decodeArray(encodedValue, STRING_PACK_ENCODING_CHAR)
end

function Util.encodeDictionary<K,V>(
	dict: {[K]: V}, 
	keyArrayEncoder: (array: {[number]: K}) -> string, 
	valueArrayEncoder: (array: {[number]: V}) -> string
)
	local keys: {[number]: K} = TableUtil.keys(dict)
	table.sort(keys)
	local values: {[number]: V} = {}
	for i, k in ipairs(keys) do
		values[i] = dict[k]
	end

	local encodedKeys = keyArrayEncoder(keys)
	local encodedValues = valueArrayEncoder(values)

	return Util.encodeStringArray({encodedKeys, encodedValues})	
end

function Util.decodeType(encodedValue: string): any
	local index = string.unpack(POS_INT_PACK_ENCODING_CHAR, encodedValue)
	local key = KEYS[index]

	if key == "BrickColor" then
		return decodeBrickColor(encodedValue)
	elseif key == "CFrame" then
		return decodeCFrame(encodedValue)	
	elseif key == "Color3" then
		return decodeColor3(encodedValue)
	elseif key == "ColorSequenceKeypoint" then
		return decodeColorSequenceKeypoint(encodedValue)
	elseif key == "ColorSequence" then
		return decodeColorSequence(encodedValue)
	elseif key == "DateTime" then
		return decodeDateTime(encodedValue)
	elseif key == "Enum" then
		return decodeEnum(encodedValue)
	elseif key == "EnumItem" then
		return decodeEnumItem(encodedValue)
	elseif key == "NumberSequenceKeypoint" then
		return decodeNumberSequenceKeypoint(encodedValue)
	elseif key == "NumberSequence" then
		return decodeNumberSequence(encodedValue)
	elseif key == "Vector3" then
		return decodeVector3(encodedValue)
	elseif key == "PathWaypoint" then
		return decodePathWaypoint(encodedValue)
	elseif key == "PhysicalProperties" then
		return decodePhysicalProperties(encodedValue)
	end
	error(`bad key: {key}`)
end

function Util.encodeType(value: ValidTypes): string
	local index = table.find(KEYS, typeof(value))
	assert(index, `unsupported type: {typeof(value)}`)
	local key = KEYS[index]

	if key == "BrickColor" then
		return encodeBrickColor(value :: BrickColor)
	elseif key == "CFrame" then
		return encodeCFrame(value :: CFrame)		
	elseif key == "Color3" then
		return encodeColor3(value :: Color3)
	elseif key == "ColorSequenceKeypoint" then
		return encodeColorSequenceKeypoint(value :: ColorSequenceKeypoint)
	elseif key == "ColorSequence" then
		return encodeColorSequence(value :: ColorSequence)
	elseif key == "DateTime" then
		return encodeDateTime(value :: DateTime)
	elseif key == "Enum" then
		return encodeEnum(value :: Enum)
	elseif key == "EnumItem" then
		return encodeEnumItem(value :: EnumItem)
	elseif key == "NumberSequenceKeypoint" then
		return encodeNumberSequenceKeypoint(value :: NumberSequenceKeypoint)
	elseif key == "NumberSequence" then
		return encodeNumberSequence(value :: NumberSequence)
	elseif key == "Vector3" then
		return encodeVector3(value :: Vector3)
	elseif key == "PathWaypoint" then
		return encodePathWaypoint(value :: PathWaypoint)
	elseif key == "PhysicalProperties" then
		return encodePhysicalProperties(value :: PhysicalProperties)
	end
	error(`bad key: {key}`)
end

return Util