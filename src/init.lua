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
	"number",
	"string",
	"boolean",
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
	PhysicalProperties | 
	Ray | 
	Rect | 
	Region3 | 
	Region3int16 | 
	TweenInfo | 
	UDim | 
	UDim2 | 
	Vector2 | 
	Vector2int16 | 
	Vector3 | 
	Vector3int16 | 
	number | 
	string | 
	boolean
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
function encodeVector3Int16(value: Vector3int16): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local x, y, z = value.X, value.Y, value.Z
	return string.pack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(3), index, x,y,z)
end

function decodeVector3Int16(encodedValue: string): Vector3int16
	local _index, x, y, z = string.unpack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(3), encodedValue)
	return Vector3int16.new(x,y,z)
end

function encodeVector2(value: Vector2): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local x, y = value.X, value.Y
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), index, x,y)
end

function decodeVector2(encodedValue: string): Vector2
	local _index, x, y = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), encodedValue)
	return Vector2.new(x,y)
end

function encodeVector2Int16(value: Vector2int16): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local x, y = value.X, value.Y
	return string.pack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(2), index, x,y)
end

function decodeVector2Int16(encodedValue: string): Vector2int16
	local _index, x, y = string.unpack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(2), encodedValue)
	return Vector2int16.new(x,y)
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

function encodeRay(value: Ray): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local encodedOrigin = encodeVector3(value.Origin)
	local encodedDirection = encodeVector3(value.Direction)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(2), index, encodedOrigin, encodedDirection)
end

function decodeRay(encodedValue: string): Ray

	local _index, encodedOrigin, encodedDirection = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(2), encodedValue)

	local origin = decodeVector3(encodedOrigin)
	local direction = decodeVector3(encodedDirection)

	return Ray.new(
		origin,
		direction
	)
end

function encodeRect(value: Rect): string
	local index = table.find(KEYS, typeof(value))
	assert(index)


	local encodedMin = encodeVector2(value.Min)
	local encodedMax = encodeVector2(value.Max)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(2), index, encodedMin, encodedMax)
end

function decodeRect(encodedValue: string): Rect
	local _index, encodedMin, encodedMax = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR:rep(2), encodedValue)

	local min = decodeVector2(encodedMin)
	local max = decodeVector2(encodedMax)

	return Rect.new(min, max)
end

function encodeRegion3(value: Region3): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local origin = value.CFrame * CFrame.new(-value.Size/2)
	local dest = value.CFrame * CFrame.new(value.Size/2)
	-- local lQ1 = value.CFrame * CFrame.new(value.Size.X/2, -value.Size.Y/2, value.Size.Z/2)
	-- local uQ1 = value.CFrame * CFrame.new(value.Size.X/2, value.Size.Y/2, value.Size.Z/2)
	-- local lQ2 = value.CFrame * CFrame.new(value.Size.X/2, -value.Size.Y/2, -value.Size.Z/2)
	-- local uQ2 = value.CFrame * CFrame.new(value.Size.X/2, value.Size.Y/2, -value.Size.Z/2)
	-- local lQ3 = value.CFrame * CFrame.new(-value.Size.X/2, -value.Size.Y/2, -value.Size.Z/2)
	-- local uQ3 = value.CFrame * CFrame.new(-value.Size.X/2, value.Size.Y/2, -value.Size.Z/2)
	-- local lQ4 = value.CFrame * CFrame.new(-value.Size.X/2, -value.Size.Y/2, value.Size.Z/2)
	-- local uQ4 = value.CFrame * CFrame.new(-value.Size.X/2, value.Size.Y/2, value.Size.Z/2)

	local maxX = dest.X-- math.min(lQ1.X, uQ1.X, lQ2.X,uQ2.X, lQ3.X, uQ3.X, lQ4.X, uQ4.X)
	local minX = origin.X-- math.max(lQ1.X, uQ1.X, lQ2.X,uQ2.X, lQ3.X, uQ3.X, lQ4.X, uQ4.X)
	local maxY = dest.Y--math.min(lQ1.Y, uQ1.Y, lQ2.Y,uQ2.Y, lQ3.Y, uQ3.Y, lQ4.Y, uQ4.Y)
	local minY = origin.Y-- math.max(lQ1.Y, uQ1.Y, lQ2.Y,uQ2.Y, lQ3.Y, uQ3.Y, lQ4.Y, uQ4.Y)
	local maxZ = dest.Z--math.min(lQ1.Z, uQ1.Z, lQ2.Z,uQ2.Z, lQ3.Z, uQ3.Z, lQ4.Z, uQ4.Z)
	local minZ = origin.Z--math.max(lQ1.Z, uQ1.Z, lQ2.Z,uQ2.Z, lQ3.Z, uQ3.Z, lQ4.Z, uQ4.Z)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, minX, minY, minZ, maxX, maxY, maxZ)
end

function decodeRegion3(encodedValue: string): Region3
	local _index, minX, minY, minZ, maxX, maxY, maxZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)

	local min = Vector3.new(minX, minY, minZ)
	local max = Vector3.new(maxX, maxY, maxZ)

	return Region3.new(min, max)
end

function encodeRegion3Int16(value: Region3int16): string
	local index = table.find(KEYS, typeof(value))
	assert(index)

	local minX = value.Min.X
	local maxX = value.Max.X
	local minY = value.Min.Y
	local maxY = value.Max.Y
	local minZ = value.Min.Z
	local maxZ = value.Max.Z

	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, minX, minY, minZ, maxX, maxY, maxZ)
end

function decodeRegion3Int16(encodedValue: string): Region3int16
	local _index, minX, minY, minZ, maxX, maxY, maxZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)

	local min = Vector3int16.new(minX, minY, minZ)
	local max = Vector3int16.new(maxX, maxY, maxZ)

	return Region3int16.new(min, max)
end

function encodeTweenInfo(value: TweenInfo): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local reverses = value.Reverses
	local repeatCount = value.RepeatCount
	local t = value.Time
	local delayTime = value.DelayTime
	local encodedEasingDirection = encodeEnumItem(value.EasingDirection)
	local encodedEasingStyle = encodeEnumItem(value.EasingStyle)

	return string.pack(POS_INT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2)..STRING_PACK_ENCODING_CHAR:rep(2), 
		index, 
		if reverses then 1 else 0,
		repeatCount, 
		t,
		delayTime, 
		encodedEasingDirection, 
		encodedEasingStyle
	)
end

function decodeTweenInfo(encodedValue: string): TweenInfo
	local _index, reverseInt, repeatCount, t, delayTime, encodedEasingDirection, encodedEasingStyle = string.unpack(
		POS_INT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2)..STRING_PACK_ENCODING_CHAR:rep(2),
		encodedValue
	)

	return TweenInfo.new(
		t,
		decodeEnumItem(encodedEasingStyle) :: Enum.EasingStyle,
		decodeEnumItem(encodedEasingDirection) :: Enum.EasingDirection,
		repeatCount, 
		reverseInt == 1,
		delayTime
	)

end

function encodeUDim(value: UDim): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local scale, offset = value.Scale, value.Offset
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), index, scale, offset)
end

function decodeUDim(encodedValue: string): UDim
	local _index, scale, offset = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), encodedValue)
	return UDim.new(scale, offset)
end

function encodeUDim2(value: UDim2): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	local xScale, xOffset, yScale, yOffset = value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(4), index, xScale, xOffset, yScale, yOffset)
end

function decodeUDim2(encodedValue: string): UDim2
	local _index, xScale, xOffset, yScale, yOffset = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(4), encodedValue)

	return UDim2.new(xScale, xOffset, yScale, yOffset)
end

function encodeString(value: string): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, index, value)
end

function decodeString(encodedValue: string): string
	local _index, value = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, encodedValue)
	return value
end

function encodeNumber(value: number): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR, index, value)
end

function decodeNumber(encodedValue: string): number
	local _index, value = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR, encodedValue)
	return value
end

function encodeBoolean(value: boolean): string
	local index = table.find(KEYS, typeof(value))
	assert(index)
	return string.pack(POS_INT_PACK_ENCODING_CHAR:rep(2), index, if value then 0 else 1)
end

function decodeBoolean(encodedValue: string): boolean
	local _index, value = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(2), encodedValue)
	return value == 1
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
	elseif key == "Vector3int16" then
		return decodeVector3Int16(encodedValue)
	elseif key == "Vector2" then
		return decodeVector2(encodedValue)
	elseif key == "Vector2int16" then
		return decodeVector2Int16(encodedValue)
	elseif key == "PathWaypoint" then
		return decodePathWaypoint(encodedValue)
	elseif key == "PhysicalProperties" then
		return decodePhysicalProperties(encodedValue)
	elseif key == "Ray" then
		return decodeRay(encodedValue)
	elseif key == "Rect" then
		return decodeRect(encodedValue)
	elseif key == "Region3" then
		return decodeRegion3(encodedValue)		
	elseif key == "Region3int16" then
		return decodeRegion3Int16(encodedValue)	
	elseif key == "TweenInfo" then
		return decodeTweenInfo(encodedValue)	
	elseif key == "UDim" then
		return decodeUDim(encodedValue)	
	elseif key == "UDim2" then
		return decodeUDim2(encodedValue)	
	elseif key == "string" then
		return decodeString(encodedValue)
	elseif key == "number" then
		return decodeNumber(encodedValue)
	elseif key == "boolean" then
		return decodeBoolean(encodedValue)
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
	elseif key == "Vector3int16" then
		return encodeVector3Int16(value :: Vector3int16)
	elseif key == "Vector2" then
		return encodeVector2(value :: Vector2)
	elseif key == "Vector2int16" then
		return encodeVector2Int16(value :: Vector2int16)
	elseif key == "PathWaypoint" then
		return encodePathWaypoint(value :: PathWaypoint)
	elseif key == "PhysicalProperties" then
		return encodePhysicalProperties(value :: PhysicalProperties)
	elseif key == "Ray" then
		return encodeRay(value :: Ray)
	elseif key == "Rect" then
		return encodeRect(value :: Rect)
	elseif key == "Region3" then
		return encodeRegion3(value :: Region3)
	elseif key == "Region3int16" then
		return encodeRegion3Int16(value :: Region3int16)
	elseif key == "TweenInfo" then
		return encodeTweenInfo(value :: TweenInfo)
	elseif key == "UDim" then
		return encodeUDim(value :: UDim)
	elseif key == "UDim2" then
		return encodeUDim2(value :: UDim2)
	elseif key == "string" then
		return encodeString(value :: string)
	elseif key == "number" then
		return encodeNumber(value :: number)
	elseif key == "boolean" then
		return encodeBoolean(value :: boolean)
	end
	error(`bad key: {key}`)
end

return Util