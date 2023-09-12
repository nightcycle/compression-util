--!strict
local _Package = script
local _Packages = _Package.Parent

-- Services
-- Packages
local TableUtil = require(_Packages:WaitForChild("TableUtil"))
-- Modules
-- Types

type CompressionPair<T> = {
	encode: (T) -> string,
	decode: (string) -> T,
}

-- Constants
local INF_INTEGER = 922337203685477600
local INTEGER_PACK_ENCODING_CHAR = "l"
local POS_INT_PACK_ENCODING_CHAR = "L"
local FLOAT_PACK_ENCODING_CHAR = "n"
local DOUBLE_PACK_ENCODING_CHAR = "d"
local STRING_PACK_ENCODING_CHAR = "s"
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
	boolean |
	Axes |
	CatalogSearchParams |
	Faces |
	FloatCurveKey |
	Font |
	PhysicalProperties
)

-- Variables
-- References
-- Private Functions
function getEnumItemByValue(enum: Enum, value: number): EnumItem
	for i, enumItem in ipairs(enum:GetEnumItems()) do
		if enumItem.Value == value then
			return enumItem
		end
	end
	
	error(`bad value {value} for enum {enum}`)
end

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

local SupportedTypeNames: {[number]: string} = {
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
	"Axes",
	"CatalogSearchParams",
	"Faces",
	"FloatCurveKey",
	"Font",
}

local Types = {
	["BrickColor"] = {
		encode = function(value: BrickColor): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local encoding = string.pack(POS_INT_PACK_ENCODING_CHAR:rep(2), index, value.Number)
			return encoding
		end,
		
		decode = function(encodedValue: string): BrickColor
			local _index, num = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(2), encodedValue)
			return BrickColor.new(num)
		end,
	} :: CompressionPair<BrickColor>,
	["CFrame"] = {
		encode = function(value: CFrame): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			local rX, rY, rZ = value:ToEulerAnglesXYZ()
			local x, y, z = value.X, value.Y, value.Z
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, x, y, z, rX, rY, rZ)
		end,
		decode = function(encodedValue: string): CFrame
			local _index, x, y, z, rX, rY, rZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)
			return CFrame.new(x,y,z) * CFrame.fromEulerAnglesXYZ(rX, rY, rZ)
		end
	} :: CompressionPair<CFrame>,
	["Color3"] = {			
		encode = function(value: Color3): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)

			local r,g,b = math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255)
			return string.pack(POS_INT_PACK_ENCODING_CHAR:rep(4), index, r,g,b)
		end,
		decode = function(encodedValue: string): Color3

			local _index, r,g,b =  string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(4), encodedValue)
			return Color3.fromRGB(r,g,b)
		end,
	} :: CompressionPair<Color3>,
	["ColorSequenceKeypoint"] = {			
		encode = function(value: ColorSequenceKeypoint): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local r,g,b = math.round(value.Value.R * 255), math.round(value.Value.G * 255), math.round(value.Value.B * 255)
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR:rep(3), index, value.Time, r, g, b)
		end,
		
		decode = function(encodedValue: string): ColorSequenceKeypoint
			local _index, t, r,g,b = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR:rep(3), encodedValue)
			return ColorSequenceKeypoint.new(t, Color3.fromRGB(r,g,b))
		end
	} :: CompressionPair<ColorSequenceKeypoint>,
	["ColorSequence"] = {			
		encode = function(value: ColorSequence): string
			local index = table.find(SupportedTypeNames, typeof(value))
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
		end,
		decode = function(encodedValue: string): ColorSequence

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
	} :: CompressionPair<ColorSequence>,
	["DateTime"] = {			
		encode = function(value: DateTime): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			return string.pack(POS_INT_PACK_ENCODING_CHAR:rep(2), index, value.UnixTimestampMillis)
		end,
		decode = function(encodedValue: string): DateTime
			local _index, tsMillis = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(2), encodedValue)
			return DateTime.fromUnixTimestampMillis(tsMillis)
		end,
	} :: CompressionPair<DateTime>,
	["Enum"] = {			
		encode = function(value: Enum): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, index, tostring(value))
		end,
		decode = function(encodedValue: string): Enum

			local _index, name = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, encodedValue)
		
			return (Enum :: any)[name]
		end
	} :: CompressionPair<Enum>,
	["EnumItem"] = {			
		encode = function(value: EnumItem): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR, index, tostring(value.EnumType), value.Value)
		end
		,
		decode = function(encodedValue: string): EnumItem

			local _index, enumName, enumValue = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR, encodedValue)
			local enum: Enum = (Enum :: any)[enumName]
			
			for i, v in ipairs(enum:GetEnumItems()) do
				if v.Value == enumValue then
					return v
				end
			end
			error(`bad enumItem {_index}, {enumName}, {enumValue}`)
		end
	} :: CompressionPair<EnumItem>,
	["NumberRange"] = {			
		encode = function(value: NumberRange): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), index, value.Min, value.Max)
		end,
		decode = function(encodedValue: string): NumberRange

			local _index, min, max = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), encodedValue)
		
			return NumberRange.new(min, max)
		end
	} :: CompressionPair<NumberRange>,	
	["NumberSequence"] = {			
		encode = function(value: NumberSequence): string
			local index = table.find(SupportedTypeNames, typeof(value))
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
		end,
		decode = function(encodedValue: string): NumberSequence

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
	} :: CompressionPair<NumberSequence>,
	["NumberSequenceKeypoint"] = {			
		encode = function(value: NumberSequenceKeypoint): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), index, value.Time, value.Value, value.Envelope)
		end
		,
		decode = function(encodedValue: string): NumberSequenceKeypoint

			local _index, t, v, e = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), encodedValue)
			return NumberSequenceKeypoint.new(t, v, e)
		end
		
	} :: CompressionPair<NumberSequenceKeypoint>,	
	["PathWaypoint"] = {			
		encode = function(value: PathWaypoint): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			local action = value.Action
			local pos = value.Position
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), index, action.Value, pos.X, pos.Y, pos.Z)
		end,
		decode = function(encodedValue: string): PathWaypoint
			local _index, actionValue, x, y, z = string.unpack(POS_INT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), encodedValue)
		
			return PathWaypoint.new(
				Vector3.new(x,y,z),
				getEnumItemByValue(Enum.PathWaypointAction, actionValue) :: Enum.PathWaypointAction
			)
		end
	} :: CompressionPair<PathWaypoint>,		
	["PhysicalProperties"] = {			
		encode = function(value: PhysicalProperties): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			local density, elasticity, elasticWeight, friction, frictionWeight = value.Density, value.Elasticity, value.ElasticityWeight, value.Friction, value.FrictionWeight
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(5), index, density, elasticity, elasticWeight, friction, frictionWeight)
		end,
		decode = function(encodedValue: string): PhysicalProperties
			local _index, density, elasticity, elasticWeight, friction, frictionWeight = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(5), encodedValue)
			return PhysicalProperties.new(
				density,
				friction,
				elasticity,
				frictionWeight,
				elasticWeight
			)
		end
	} :: CompressionPair<PhysicalProperties>,		
	["Ray"] = {			
		encode = function(value: Ray): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z)
		end,
		decode = function(encodedValue: string): Ray

			local _index, oX, oY, oZ, dX, dY, dZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)
	
			return Ray.new(
				Vector3.new(oX, oY, oZ),
				Vector3.new(dX, dY, dZ)
			)
		end,
	} :: CompressionPair<Ray>,	
	["Rect"] = {			
		encode = function(value: Rect): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(4), index, value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
		end,
		decode = function(encodedValue: string): Rect
			local _index, minX, minY, maxX, maxY = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(4), encodedValue)

			return Rect.new(
				Vector2.new(minX, minY), 
				Vector2.new(maxX, maxY)
			)
		end
	} :: CompressionPair<Rect>,	
	["Region3"] = {			
		encode = function(value: Region3): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			local origin = value.CFrame * CFrame.new(-value.Size/2)
			local dest = value.CFrame * CFrame.new(value.Size/2)
			local maxX = dest.X
			local minX = origin.X
			local maxY = dest.Y
			local minY = origin.Y
			local maxZ = dest.Z
			local minZ = origin.Z
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, minX, minY, minZ, maxX, maxY, maxZ)
		end,
		decode = function(encodedValue: string): Region3
			local _index, minX, minY, minZ, maxX, maxY, maxZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)
		
			local min = Vector3.new(minX, minY, minZ)
			local max = Vector3.new(maxX, maxY, maxZ)
		
			return Region3.new(min, max)
		end
	} :: CompressionPair<Region3>,	
	["Region3int16"] = {			
		encode = function(value: Region3int16): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			local minX = value.Min.X
			local maxX = value.Max.X
			local minY = value.Min.Y
			local maxY = value.Max.Y
			local minZ = value.Min.Z
			local maxZ = value.Max.Z
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), index, minX, minY, minZ, maxX, maxY, maxZ)
		end,
		decode = function(encodedValue: string): Region3int16
			local _index, minX, minY, minZ, maxX, maxY, maxZ = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(6), encodedValue)
		
			local min = Vector3int16.new(minX, minY, minZ)
			local max = Vector3int16.new(maxX, maxY, maxZ)
		
			return Region3int16.new(min, max)
		end
	} :: CompressionPair<Region3int16>,	
	["TweenInfo"] = {			
		encode = function(value: TweenInfo): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local reverses = value.Reverses
			local repeatCount = value.RepeatCount
			local t = value.Time
			local delayTime = value.DelayTime
		
			return string.pack(POS_INT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2)..POS_INT_PACK_ENCODING_CHAR:rep(2), 
				index, 
				if reverses then 1 else 0,
				repeatCount, 
				t,
				delayTime, 
				value.EasingDirection.Value, 
				value.EasingStyle.Value
			)
		end,
		decode = function(encodedValue: string): TweenInfo
			local _index, reverseInt, repeatCount, t, delayTime, easingDirectionValue, easingStyleValue = string.unpack(
				POS_INT_PACK_ENCODING_CHAR..POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2)..POS_INT_PACK_ENCODING_CHAR:rep(2),
				encodedValue
			)
		
			return TweenInfo.new(
				t,
				getEnumItemByValue(Enum.EasingStyle, easingStyleValue) :: Enum.EasingStyle,
				getEnumItemByValue(Enum.EasingDirection, easingDirectionValue) :: Enum.EasingDirection,
				repeatCount, 
				reverseInt == 1,
				delayTime
			)
		
		end
	} :: CompressionPair<TweenInfo>,	
	["UDim"] = {			
		encode = function(value: UDim): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local scale, offset = value.Scale, value.Offset
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), index, scale, offset)
		end,
		decode = function(encodedValue: string): UDim
			local _index, scale, offset = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), encodedValue)
			return UDim.new(scale, offset)
		end
	} :: CompressionPair<UDim>,	
	["UDim2"] = {			
		encode = function(value: UDim2): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local xScale, xOffset, yScale, yOffset = value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(4), index, xScale, xOffset, yScale, yOffset)
		end
		,
		decode = function(encodedValue: string): UDim2
			local _index, xScale, xOffset, yScale, yOffset = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(4), encodedValue)
		
			return UDim2.new(xScale, xOffset, yScale, yOffset)
		end
	} :: CompressionPair<UDim2>,	
	["Vector2"] = {			
		encode = function(value: Vector2): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local x, y = value.X, value.Y
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), index, x,y)
		end,
		decode = function(encodedValue: string): Vector2
			local _index, x, y = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(2), encodedValue)
			return Vector2.new(x,y)
		end
	} :: CompressionPair<Vector2>,	
	["Vector2int16"] = {			
		encode = function(value: Vector2int16): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local x, y = value.X, value.Y
			return string.pack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(2), index, x,y)
		end,
		decode = function(encodedValue: string): Vector2int16
			local _index, x, y = string.unpack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(2), encodedValue)
			return Vector2int16.new(x,y)
		end
	} :: CompressionPair<Vector2int16>,	
	["Vector3"] = {			
		encode = function (value: Vector3): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local x, y, z = value.X, value.Y, value.Z
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), index, x,y,z)
		end,
		decode = function(encodedValue: string): Vector3
			local _index, x, y, z = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR:rep(3), encodedValue)
			return Vector3.new(x,y,z)
		end
	} :: CompressionPair<Vector3>,	
	["Vector3int16"] = {			
		encode = function(value: Vector3int16): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			local x, y, z = value.X, value.Y, value.Z
			return string.pack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(3), index, x,y,z)
		end
		
		,
		decode = function(encodedValue: string): Vector3int16
			local _index, x, y, z = string.unpack(POS_INT_PACK_ENCODING_CHAR..INTEGER_PACK_ENCODING_CHAR:rep(3), encodedValue)
			return Vector3int16.new(x,y,z)
		end
	} :: CompressionPair<Vector3int16>,	
	["number"] = {		
		encode = function(value: number): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			return string.pack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR, index, value)
		end,
		decode = function(encodedValue: string): number
			local _index, value = string.unpack(POS_INT_PACK_ENCODING_CHAR..FLOAT_PACK_ENCODING_CHAR, encodedValue)
			return value
		end	
	} :: CompressionPair<number>,	
	["string"] = {			
		encode = function(value: string): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			return string.pack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, index, value)
		end,
		decode = function(encodedValue: string): string
			local _index, value = string.unpack(POS_INT_PACK_ENCODING_CHAR..STRING_PACK_ENCODING_CHAR, encodedValue)
			return value
		end
	} :: CompressionPair<string>,	
	["boolean"] = {			
		encode = function(value: boolean): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			return string.pack(POS_INT_PACK_ENCODING_CHAR:rep(2), index, if value then 1 else 0)
		end,
		decode = function(encodedValue: string): boolean
			local _index, value = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(2), encodedValue)
			return value == 1
		end,
	} :: CompressionPair<boolean>,	
	["Axes"] = {
		encode = function(value: Axes): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(
				POS_INT_PACK_ENCODING_CHAR:rep(7), 
				index, 
				if value.Top then 1 else 0,
				if value.Bottom then 1 else 0,
				if value.Left then 1 else 0,
				if value.Right then 1 else 0,
				if value.Front then 1 else 0,
				if value.Back then 1 else 0,
				if value.X then 1 else 0,
				if value.Y then 1 else 0,
				if value.Z then 1 else 0
			)
		end,
		decode = function(encodedValue: string): Axes
			local _index, topValue, bottomValue, leftValue, rightValue, frontValue, backValue, xValue, yValue, zValue = string.unpack(
				POS_INT_PACK_ENCODING_CHAR:rep(7),
				encodedValue
			)

			local faces: {[number]: any} = {}
			if topValue == 1 then 
				table.insert(faces, Enum.NormalId.Top)
			end
			if bottomValue == 1 then 
				table.insert(faces, Enum.NormalId.Bottom)
			end	
			if leftValue == 1 then 
				table.insert(faces, Enum.NormalId.Left)
			end	
			if rightValue == 1 then 
				table.insert(faces, Enum.NormalId.Right)
			end	
			if frontValue == 1 then 
				table.insert(faces, Enum.NormalId.Front)
			end	
			if backValue == 1 then 
				table.insert(faces, Enum.NormalId.Back)
			end			
			if xValue == 1 then 
				table.insert(faces, Enum.Axis.X)
			end	
			if yValue == 1 then 
				table.insert(faces, Enum.Axis.Y)
			end	
			if zValue == 1 then 
				table.insert(faces, Enum.Axis.Z)
			end	

			local value = Axes.new(table.unpack(faces))	
			return value
		end,
	} :: CompressionPair<Axes>,	
	["CatalogSearchParams"] = {
		encode = function(value: any): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)

			local function encodeEnumItemList(enumItemList: {[number]: EnumItem}): string
				local values = {}
				for i, v in ipairs(enumItemList) do
					-- warn(tostring(v.EnumType).." encode ["..tostring(i).."] = "..tostring(v.Value))
					values[i] = v.Value
				end

				return encodeArray(values, POS_INT_PACK_ENCODING_CHAR)
			end
		
			return string.pack(
				POS_INT_PACK_ENCODING_CHAR:rep(8)..STRING_PACK_ENCODING_CHAR:rep(4), 
				index, 
				value.CategoryFilter.Value,
				value.SortType.Value,
				value.SalesTypeFilter.Value,
				value.SortAggregation.Value,
				if value.IncludeOffSale then 1 else 0,
				value.MinPrice,
				value.MaxPrice,
				value.SearchKeyword,
				value.CreatorName,
				encodeEnumItemList(value.AssetTypes :: {[number]: any}),
				encodeEnumItemList(value.BundleTypes :: {[number]: any})
			)
		end,
		decode = function(encodedValue: string): CatalogSearchParams
			local _index, filterValue, sortTypeValue, saleTypeValue, sortAggValue, offSaleValue, minPrice, maxPrice, keyword, creatorName, encodedAssetTypes, encodedBundleTypes = string.unpack(
				POS_INT_PACK_ENCODING_CHAR:rep(8)..STRING_PACK_ENCODING_CHAR:rep(4), 
				encodedValue
			)

			local function decodeEnumArray(enum: Enum, encodedArray: string): {[number]: EnumItem}
				local enumItems: {[number]: EnumItem} = {}
				local array = decodeArray(encodedArray, POS_INT_PACK_ENCODING_CHAR)

				for i, v in ipairs(array) do
					-- warn(tostring(enum).." decode ["..tostring(i).."] = "..tostring(v).." aka "..tostring(getEnumItemByValue(enum, v)))
					enumItems[i] = getEnumItemByValue(enum, v)
					-- warn("it became "..tostring(enumItems[i]))
				end
				return enumItems
			end
			
			local params = CatalogSearchParams.new() :: any
			params.SearchKeyword = keyword
			params.SortType = getEnumItemByValue(Enum.CatalogSortType, sortTypeValue) :: Enum.CatalogSortType
			params.CategoryFilter = getEnumItemByValue(Enum.CatalogCategoryFilter, filterValue) :: Enum.CatalogCategoryFilter
			params.MaxPrice = maxPrice
			params.MinPrice = minPrice
			params.AssetTypes = decodeEnumArray(Enum.AvatarAssetType, encodedAssetTypes) :: {[number]: any}
			params.BundleTypes = decodeEnumArray(Enum.BundleType, encodedBundleTypes) :: {[number]: any}
			params.IncludeOffSale = offSaleValue == 1
			params.CreatorName = creatorName
			params.SalesTypeFilter = getEnumItemByValue(Enum.SalesTypeFilter, saleTypeValue) :: Enum.SalesTypeFilter
			params.SortAggregation = getEnumItemByValue(Enum.CatalogSortAggregation, sortAggValue) :: Enum.CatalogSortAggregation

			return params
		end,
	} :: CompressionPair<CatalogSearchParams>,	
	["Faces"] = {
		encode = function(value: Faces): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(
				POS_INT_PACK_ENCODING_CHAR:rep(7), 
				index, 
				if value.Top then 1 else 0,
				if value.Bottom then 1 else 0,
				if value.Left then 1 else 0,
				if value.Right then 1 else 0,
				if value.Front then 1 else 0,
				if value.Back then 1 else 0
			)
		end,
		decode = function(encodedValue: string): Faces
			local _index, topValue, bottomValue, leftValue, rightValue, frontValue, backValue = string.unpack(
				POS_INT_PACK_ENCODING_CHAR:rep(7),
				encodedValue
			)

			local faces: {[number]: Enum.NormalId} = {}
			if topValue == 1 then 
				table.insert(faces, Enum.NormalId.Top)
			end
			if bottomValue == 1 then 
				table.insert(faces, Enum.NormalId.Bottom)
			end	
			if leftValue == 1 then 
				table.insert(faces, Enum.NormalId.Left)
			end	
			if rightValue == 1 then 
				table.insert(faces, Enum.NormalId.Right)
			end	
			if frontValue == 1 then 
				table.insert(faces, Enum.NormalId.Front)
			end	
			if backValue == 1 then 
				table.insert(faces, Enum.NormalId.Back)
			end						
			local value = Faces.new(table.unpack(faces))	
			return value
		end,
	} :: CompressionPair<Faces>,		
	["FloatCurveKey"] = {
		encode = function(value: FloatCurveKey): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
		
			return string.pack(
				POS_INT_PACK_ENCODING_CHAR:rep(2)..FLOAT_PACK_ENCODING_CHAR:rep(4), 
				index, 
				value.Interpolation.Value,
				value.LeftTangent or 0,
				value.RightTangent or 0,
				value.Time,
				value.Value
			)
		end,
		decode = function(encodedValue: string): FloatCurveKey
			local _index, interpolationValue, leftTangent, rightTangent, t, v = string.unpack(
				POS_INT_PACK_ENCODING_CHAR:rep(2)..FLOAT_PACK_ENCODING_CHAR:rep(4), 
				encodedValue
			)
			
			local value = FloatCurveKey.new(
				t,
				v,
				getEnumItemByValue(Enum.KeyInterpolationMode, interpolationValue) :: Enum.KeyInterpolationMode
			)
			
			if value.Interpolation == Enum.KeyInterpolationMode.Cubic then
				if leftTangent ~= 0 then
					value.LeftTangent = leftTangent
				end
				if rightTangent ~= 0 then
					value.RightTangent = rightTangent
				end
			end

			return value
		end,
	} :: CompressionPair<FloatCurveKey>,	
	["Font"] = {
		encode = function(value: Font): string
			local index = table.find(SupportedTypeNames, typeof(value))
			assert(index)
			return string.pack(
				POS_INT_PACK_ENCODING_CHAR:rep(4)..STRING_PACK_ENCODING_CHAR, index, 
				if value.Bold then 1 else 0, 
				value.Style.Value, 
				value.Weight.Value, 
				value.Family
			)
		end,
		decode = function(encodedValue: string): Font
			local _index, boldValue, styleValue, weightValue, fontFamilyName = string.unpack(POS_INT_PACK_ENCODING_CHAR:rep(4)..STRING_PACK_ENCODING_CHAR, encodedValue)
			
			local value = Font.new(
				fontFamilyName,
				getEnumItemByValue(Enum.FontWeight, weightValue) :: Enum.FontWeight,
				getEnumItemByValue(Enum.FontStyle, styleValue) :: Enum.FontStyle
			)
			value.Bold = boldValue == 1

			return value
		end,
	} :: CompressionPair<Font>,
}

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
	local key = SupportedTypeNames[index]

	local compressionPair = Types[key]
	assert(compressionPair, `missing valid type indicator`)
	
	return compressionPair.decode(encodedValue)
end

function Util.encodeType(value: ValidTypes): string
	assert(typeof(value) ~= "table", `unstructured tables aren't supported, if it's a dictionary or array use the relevant functions`)
	
	local index = table.find(SupportedTypeNames, typeof(value))
	assert(index, `type {typeof(value)} isn't a type that can be serialized / has instance properties`)

	local key = SupportedTypeNames[index]
	local compressionPair = Types[key]
	
	return compressionPair.encode(value)
end

return Util