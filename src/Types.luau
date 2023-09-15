--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
local Array = require(_Package.Array)
-- Types
type CompressionPair<T> = {
	encode: (T, isBlind: boolean, altNumberFormat: string?) -> string,
	decode: (string, isBlind: boolean, altNumberFormat: string?) -> T,
}
type ValidTypes = (
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
	Faces |
	FloatCurveKey |
	Font |
	PhysicalProperties
)
-- Constants
local UNSIGNED_SHORT_LIMIT = 65535
local INT_16_OFFSET = 32768
local ANGLE_MULTIPLIER = 24
local ANGLE_DIVISOR = 3
local SUPPORTED_TYPES: {[number]: string} = {
	[1] = "BrickColor",
	[2] = "CFrame",
	[3] = "Color3",
	[4] = "ColorSequence",
	[5] = "ColorSequenceKeypoint",
	[6] = "DateTime",
	[7] = "Enum",
	[8] = "EnumItem",
	[9] = "NumberRange",
	[10] = "NumberSequence",
	[11] = "NumberSequenceKeypoint",
	[12] = "PathWaypoint",
	[13] = "PhysicalProperties",
	[14] = "Ray",
	[15] = "Rect",
	[16] = "Region3",
	[17] = "Region3int16",
	[18] = "TweenInfo",
	[19] = "UDim",
	[20] = "UDim2",
	[21] = "Vector2",
	[22] = "Vector2int16",
	[23] = "Vector3",
	[24] = "Vector3int16",
	[25] = "number",
	[26] = "string",
	[27] = "boolean",
	[28] = "Axes",
	[29] = "Faces",
	[30] = "FloatCurveKey",
	[31] = "Font",
}
local SIGN_FILTER = {

	b = "B",

	h = "H",

	l = "L",

	j = "J",

}

-- Variables
-- References
-- Private Functions
function filterSign(format: string): string
	return SIGN_FILTER[format] or format
end

function getEnumItemByValue(enum: Enum, value: number): EnumItem
	for i, enumItem in ipairs(enum:GetEnumItems()) do
		if enumItem.Value == value then
			return enumItem
		end
	end
	
	error(`bad value {value} for enum {enum}`)
end
-- Class
local Util = {}




Util.Library = {
	["BrickColor"] = {
		encode = function(value: BrickColor, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				local encoding = string.pack("H", value.Number)
				return encoding
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				local encoding = string.pack("BH", index - 1, value.Number)
				return encoding
			end
		end,		
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): BrickColor
			if isBlind then
				local num = string.unpack("H", encodedValue)
				return BrickColor.new(num)
			else
				local _index, num = string.unpack("BH", encodedValue)
				return BrickColor.new(num)
			end
		end,
	} :: CompressionPair<BrickColor>,
	["CFrame"] = {
		encode = function(value: CFrame, isBlind: boolean, altNumberFormat: string?): string
			local rX, rY, rZ = value:ToEulerAnglesXYZ()
			local numberFormat = altNumberFormat or "n"
			local angleFormat = altNumberFormat or "H"
			local x, y, z = value.X, value.Y, value.Z

			if filterSign(angleFormat) == "H" then -- short
				rX, rY, rZ = (180 + math.deg(rX)) * ANGLE_MULTIPLIER, (180 + math.deg(rY)) * ANGLE_MULTIPLIER, (180 + math.deg(rZ)) * ANGLE_MULTIPLIER
			elseif filterSign(angleFormat) == "B" then -- integer
				x = math.round(x)
				y = math.round(y)
				z = math.round(z)
				assert(x >= -127 and x <= 128, `position out of bounds for byte encoding: {value}`)
				assert(y >= -127 and y <= 128, `position out of bounds for byte encoding: {value}`)
				assert(z >= -127 and z <= 128, `position out of bounds for byte encoding: {value}`)
				rX = math.round((180 + math.deg(rX))/ANGLE_DIVISOR)
				rY = math.round((180 + math.deg(rY))/ANGLE_DIVISOR)
				rZ = math.round((180 + math.deg(rZ))/ANGLE_DIVISOR)
			else
				rX, rY, rZ = (180 + math.deg(rX)), (180 + math.deg(rY)), (180 + math.deg(rZ))
			end

			if isBlind then
				return string.pack(numberFormat:rep(3)..filterSign(angleFormat):rep(3), x, y, z, rX, rY, rZ)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack("B"..numberFormat:rep(3)..filterSign(angleFormat):rep(3), index - 1, x, y, z, rX, rY, rZ)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): CFrame
			local numberFormat = altNumberFormat or "n"
			local angleFormat = altNumberFormat or "H"

			local x: number, y: number, z: number, rX: number, rY: number, rZ: number
			if isBlind then
				x, y, z, rX, rY, rZ = string.unpack(numberFormat:rep(3)..filterSign(angleFormat):rep(3), encodedValue)
			else
				local _index: number
				_index, x, y, z, rX, rY, rZ = string.unpack("B"..numberFormat:rep(3)..filterSign(angleFormat):rep(3), encodedValue)
			end
			if filterSign(angleFormat) == "H" then -- short
				rX, rY, rZ = (math.deg(rX) - 180) / ANGLE_MULTIPLIER, (math.deg(rY) - 180) / ANGLE_MULTIPLIER, (math.deg(rZ) - 180) / ANGLE_MULTIPLIER
			elseif filterSign(angleFormat) == "B" then -- integer
				rX, rY, rZ = (math.deg(rX) - 180) * ANGLE_DIVISOR, (math.deg(rY) - 180) * ANGLE_DIVISOR, (math.deg(rZ) - 180) * ANGLE_DIVISOR
			else
				rX, rY, rZ = (math.deg(rX) - 180), (math.deg(rY) - 180), (math.deg(rZ) - 180)
			end

			return CFrame.new(x,y,z) * CFrame.fromEulerAnglesXYZ(
				math.rad(rX), 
				math.rad(rY), 
				math.rad(rZ)
			)
		end
	} :: CompressionPair<CFrame>,
	["Color3"] = {			
		encode = function(value: Color3, isBlind: boolean, altNumberFormat: string?): string

			local r,g,b = math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255)

			if isBlind then
				return string.pack("BBB", r,g,b)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("BBBB", index - 1, r,g,b)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Color3
			if isBlind then
				local r,g,b =  string.unpack("BBB", encodedValue)
				return Color3.fromRGB(r,g,b)
			else
				local _index, r,g,b =  string.unpack("BBBB", encodedValue)
				return Color3.fromRGB(r,g,b)
			end
		end,
	} :: CompressionPair<Color3>,
	["ColorSequenceKeypoint"] = {			
		encode = function(value: ColorSequenceKeypoint, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = filterSign(altNumberFormat or "n")
			local r,g,b = math.round(value.Value.R * 255), math.round(value.Value.G * 255), math.round(value.Value.B * 255)
			
			local t: number
			if numberFormat == "S" then
				t = math.round(value.Time * UNSIGNED_SHORT_LIMIT)
			elseif numberFormat == "B" then
				t = math.round(value.Time * 255)
			else
				t = value.Time
			end

			if isBlind then
				return string.pack(numberFormat.."BBB", t, r, g, b)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("B"..numberFormat.."BBB", index - 1, t, r, g, b)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): ColorSequenceKeypoint
			local numberFormat = filterSign(altNumberFormat or "n")
			local t: number, r: number, g: number, b: number
			
			if isBlind then
				t, r,g,b = string.unpack(numberFormat.."BBB", encodedValue)
			else
				local _index: number
				_index, t, r,g,b = string.unpack("B"..numberFormat.."BBB", encodedValue)
			end

			if numberFormat == "S" then
				t = t / UNSIGNED_SHORT_LIMIT
			elseif numberFormat == "B" then
				t = t / 255
			else
				t = t
			end

			return ColorSequenceKeypoint.new(t, Color3.fromRGB(r,g,b))
		end
	} :: CompressionPair<ColorSequenceKeypoint>,
	["ColorSequence"] = {			
		encode = function(value: ColorSequence, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			local tArray: {[number]: number} = {}
			local rArray: {[number]: number} = {}
			local gArray: {[number]: number} = {}
			local bArray: {[number]: number} = {}
		
			for i, v in ipairs(value.Keypoints) do
				local t: number
				if filterSign(numberFormat) == "H" then
					t = math.round(v.Time * UNSIGNED_SHORT_LIMIT)
				elseif filterSign(numberFormat) == "B" then
					t = math.round(v.Time * 255)
				else
					t = v.Time
				end
				tArray[i] = t
				rArray[i] = math.round(v.Value.R * 255)
				gArray[i] = math.round(v.Value.G * 255)
				bArray[i] = math.round(v.Value.B * 255)
			end
		
			local tEncoded = Array.encode(tArray, "n")
			local rEncoded = Array.encode(rArray, "B")
			local gEncoded = Array.encode(gArray, "B")
			local bEncoded = Array.encode(bArray, "B")
			if isBlind then
				return string.pack("ssss", tEncoded, rEncoded, gEncoded, bEncoded)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack("Bssss", index - 1, tEncoded, rEncoded, gEncoded, bEncoded)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): ColorSequence
			local numberFormat = altNumberFormat or "n"

			local tEncoded: string, rEncoded: string, gEncoded: string, bEncoded: string
			if isBlind then
				tEncoded, rEncoded, gEncoded, bEncoded = string.unpack("ssss", encodedValue)
			else
				local _index: number
				_index, tEncoded, rEncoded, gEncoded, bEncoded = string.unpack("Bssss", encodedValue)
			end
		
			local tArray: {[number]: number} = Array.decode(tEncoded, "n")
			local rArray: {[number]: number} = Array.decode(rEncoded, "B")
			local gArray: {[number]: number} = Array.decode(gEncoded, "B")
			local bArray: {[number]: number} = Array.decode(bEncoded, "B")
		
			local keypoints: {[number]: ColorSequenceKeypoint} = {}
			for i, t in ipairs(tArray) do
				local r,g,b = rArray[i], gArray[i], bArray[i]
				if filterSign(numberFormat) == "H" then
					t = t / UNSIGNED_SHORT_LIMIT
				elseif filterSign(numberFormat) == "B" then
					t = t / 255
				else
					t = t
				end
				keypoints[i] = ColorSequenceKeypoint.new(t, Color3.fromRGB(r,g,b))
			end
		
			return ColorSequence.new(keypoints)
		end
	} :: CompressionPair<ColorSequence>,
	["DateTime"] = {			
		encode = function(value: DateTime, isBlind: boolean, altNumberFormat: string?): string
			
			if isBlind then
				return string.pack("L", value.UnixTimestampMillis)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("BL", index - 1, value.UnixTimestampMillis)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): DateTime

			if isBlind then
				local tsMillis = string.unpack("L", encodedValue)
				return DateTime.fromUnixTimestampMillis(tsMillis)
			else
				local _index, tsMillis = string.unpack("BL", encodedValue)
				return DateTime.fromUnixTimestampMillis(tsMillis)
			end
		end,
	} :: CompressionPair<DateTime>,
	["Enum"] = {			
		encode = function(value: Enum, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				return string.pack("s", tostring(value))
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("Bs", index - 1, tostring(value))
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Enum
			if isBlind then
				local name = string.unpack("s", encodedValue)
				return (Enum :: any)[name]
			else
				local _index, name = string.unpack("Bs", encodedValue)
				return (Enum :: any)[name]
			end
		end
	} :: CompressionPair<Enum>,
	["EnumItem"] = {			
		encode = function(value: EnumItem, isBlind: boolean, altNumberFormat: string?): string
			assert(value.EnumType ~= Enum.ReservedHighlightId, `Enum.ReservedHighlightId is not covered because its enumItem values are absurd`)

			if isBlind then
				-- warn(`{value}: {value.Value}`)

				return string.pack("sH", tostring(value.EnumType), value.Value)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("BsH", index - 1, tostring(value.EnumType), value.Value)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): EnumItem

			local enumName: string, enumValue: number
			if isBlind then
				enumName, enumValue = string.unpack("sH", encodedValue)
			else
				local _index: number
				_index, enumName, enumValue = string.unpack("BsH", encodedValue)
			end

			local enum: Enum = (Enum :: any)[enumName]
			for i, v in ipairs(enum:GetEnumItems()) do
				if v.Value == enumValue then
					return v
				end
			end
			error(`bad enumItem {enumName}, {enumValue}`)
		end
	} :: CompressionPair<EnumItem>,
	["NumberRange"] = {			
		encode = function(value: NumberRange, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"
			if isBlind then
				return string.pack(numberFormat:rep(2), value.Min, value.Max)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("B"..numberFormat:rep(2), index - 1, value.Min, value.Max)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): NumberRange
			local min: number, max: number
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				min, max = string.unpack(numberFormat:rep(2), encodedValue)
			else
				local _index: number
				_index, min, max = string.unpack("B"..numberFormat:rep(2), encodedValue)
			end

			return NumberRange.new(min, max)
		end
	} :: CompressionPair<NumberRange>,	
	["NumberSequence"] = {			
		encode = function(value: NumberSequence, isBlind: boolean, altNumberFormat: string?): string
		
			local tArray: {[number]: number} = {}
			local vArray: {[number]: number} = {}
			local eArray: {[number]: number} = {}

			local numberFormat = altNumberFormat or "n"
		
			local ts: {[number]: number} = {}
			for i, v in ipairs(value.Keypoints) do
				if filterSign(numberFormat) == "H" then
					tArray[i] = math.round(v.Time * UNSIGNED_SHORT_LIMIT)
					vArray[i] = v.Value
					eArray[i] = v.Envelope
				elseif filterSign(numberFormat) == "B" then
					tArray[i] = math.round(v.Time * 255)
					vArray[i] = math.round(v.Value)
					eArray[i] = math.round(v.Envelope)
				else
					tArray[i] = v.Time
					vArray[i] = v.Value
					eArray[i] = v.Envelope
				end
				ts[i] = v.Time

			end
		
			-- warn(`in fmt: {numberFormat} = {table.concat(ts, ",")}`)

			local tEncoded = Array.encode(tArray, filterSign(numberFormat))
			local vEncoded = Array.encode(vArray, numberFormat)
			local eEncoded = Array.encode(eArray, filterSign(numberFormat))
		
			if isBlind then
				return string.pack("sss", tEncoded, vEncoded, eEncoded)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("Bsss", index - 1, tEncoded, vEncoded, eEncoded)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): NumberSequence

			local numberFormat = altNumberFormat or "n"
			local tEncoded: string, vEncoded: string, eEncoded: string
			if isBlind then
				tEncoded, vEncoded, eEncoded = string.unpack("sss", encodedValue)
			else
				local _index: number
				_index, tEncoded, vEncoded, eEncoded = string.unpack("Bsss", encodedValue)
			end

			local tArray: {[number]: number} = Array.decode(tEncoded, filterSign(numberFormat))
			local vArray: {[number]: number} = Array.decode(vEncoded, numberFormat)
			local eArray: {[number]: number} = Array.decode(eEncoded, filterSign(numberFormat))
		
			local keypoints: {[number]: NumberSequenceKeypoint} = {}
			local ts: {[number]: number} = {}
			for i, t in ipairs(tArray) do
				local v, e = vArray[i], eArray[i]
				if filterSign(numberFormat) == "H" then
					t = t / UNSIGNED_SHORT_LIMIT
				elseif filterSign(numberFormat) == "B" then
					t = t / 255
				end
				if i == #tArray then
					t = 1
				end
				ts[i] = t
				keypoints[i] = NumberSequenceKeypoint.new(t, v, e)
			end
			-- warn(`out fmt: {numberFormat} = {table.concat(ts, ",")}`)

			return NumberSequence.new(keypoints)
		end
	} :: CompressionPair<NumberSequence>,
	["NumberSequenceKeypoint"] = {			
		encode = function(value: NumberSequenceKeypoint, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			local t = value.Time
			local e = value.Envelope
			local v = value.Value
			-- warn(`in fmt: {numberFormat} t: {t} v: {v} e: {e}`)

			if filterSign(numberFormat) == "H" then
				t = math.round(t * UNSIGNED_SHORT_LIMIT)
			elseif filterSign(numberFormat) == "B" then
				t = math.round(t * 255)
				e = math.round(e)
				v = math.round(v)
			end
			


			if isBlind then
				return string.pack(filterSign(numberFormat):rep(2)..numberFormat, t, e, v)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack("B"..filterSign(numberFormat):rep(2)..numberFormat, index - 1, t, e, v)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): NumberSequenceKeypoint
			local numberFormat = altNumberFormat or "n"

			local t: number, v: number, e: number
			
			if isBlind then
				t, e, v = string.unpack(filterSign(numberFormat):rep(2)..numberFormat, encodedValue)
			else
				local _index: number
				_index, t, e, v = string.unpack("B"..filterSign(numberFormat):rep(2)..numberFormat, encodedValue)
			end

			if filterSign(numberFormat) == "H" then
				t /= UNSIGNED_SHORT_LIMIT
			elseif filterSign(numberFormat) == "B" then
				t /= 255

			end
			-- warn(`out fmt: {numberFormat} t: {t} v: {v} e: {e}`)
			return NumberSequenceKeypoint.new(t, v, e)
		end
		
	} :: CompressionPair<NumberSequenceKeypoint>,	
	["PathWaypoint"] = {			
		encode = function(value: PathWaypoint, isBlind: boolean, altNumberFormat: string?): string
			
			local numberFormat = altNumberFormat or "n"
		
			local action = value.Action
			local pos = value.Position

			if isBlind then
				return string.pack("B"..numberFormat:rep(3), action.Value, pos.X, pos.Y, pos.Z)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("BB"..numberFormat:rep(3), index - 1, action.Value, pos.X, pos.Y, pos.Z)
			end
		
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): PathWaypoint
			local numberFormat = altNumberFormat or "n"

			local actionValue: number, x: number, y: number, z: number
			if isBlind then
				actionValue, x, y, z = string.unpack("B"..numberFormat:rep(3), encodedValue)
			else
				local _index: number
				_index, actionValue, x, y, z = string.unpack("BB"..numberFormat:rep(3), encodedValue)
			end
		
			return PathWaypoint.new(
				Vector3.new(x,y,z),
				getEnumItemByValue(Enum.PathWaypointAction, actionValue) :: Enum.PathWaypointAction
			)
		end
	} :: CompressionPair<PathWaypoint>,		
	["PhysicalProperties"] = {			
		encode = function(value: PhysicalProperties, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			local density, elasticity, elasticWeight, friction, frictionWeight = value.Density, value.Elasticity, value.ElasticityWeight, value.Friction, value.FrictionWeight
			if isBlind then
				return string.pack(numberFormat:rep(5), density, elasticity, elasticWeight, friction, frictionWeight)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("B"..numberFormat:rep(5), index - 1, density, elasticity, elasticWeight, friction, frictionWeight)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): PhysicalProperties
			local numberFormat = altNumberFormat or "n"

			local density: number, elasticity: number, elasticWeight: number, friction: number, frictionWeight: number
			if isBlind then
				density, elasticity, elasticWeight, friction, frictionWeight = string.unpack(numberFormat:rep(5), encodedValue)
			else
				local _index: number
				_index, density, elasticity, elasticWeight, friction, frictionWeight = string.unpack("B"..numberFormat:rep(5), encodedValue)
			end
		
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
		encode = function(value: Ray, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				return string.pack(numberFormat:rep(6), value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack("B"..numberFormat:rep(6), index - 1, value.Origin.X, value.Origin.Y, value.Origin.Z, value.Direction.X, value.Direction.Y, value.Direction.Z)
			end		
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Ray
			local numberFormat = altNumberFormat or "n"

			local oX: number, oY: number, oZ: number, dX: number, dY: number, dZ: number
			if isBlind then
				oX, oY, oZ, dX, dY, dZ = string.unpack(numberFormat:rep(6), encodedValue)
			else
				local _index: number
				_index, oX, oY, oZ, dX, dY, dZ = string.unpack("B"..numberFormat:rep(6), encodedValue)
			end
		
			return Ray.new(
				Vector3.new(oX, oY, oZ),
				Vector3.new(dX, dY, dZ)
			)
		end,
	} :: CompressionPair<Ray>,	
	["Rect"] = {			
		encode = function(value: Rect, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				return string.pack(numberFormat:rep(4), value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
			else
					
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack("B"..numberFormat:rep(4), index - 1, value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Rect
			local numberFormat = altNumberFormat or "n"

			local minX: number, minY: number, maxX: number, maxY: number

			if isBlind then
				minX, minY, maxX, maxY = string.unpack(numberFormat:rep(4), encodedValue)
			else
				local _index: number
				_index, minX, minY, maxX, maxY = string.unpack("B"..numberFormat:rep(4), encodedValue)
			end
			return Rect.new(
				Vector2.new(minX, minY), 
				Vector2.new(maxX, maxY)
			)
		end
	} :: CompressionPair<Rect>,	
	["Region3"] = {			
		encode = function(value: Region3, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"
	
			local origin = value.CFrame * CFrame.new(-value.Size/2)
			local dest = value.CFrame * CFrame.new(value.Size/2)
			local maxX = dest.X
			local minX = origin.X
			local maxY = dest.Y
			local minY = origin.Y
			local maxZ = dest.Z
			local minZ = origin.Z

			if filterSign(numberFormat) == "B" then
				minX = math.round(minX)
				maxX = math.round(maxX)
				minY = math.round(minY)
				maxY = math.round(maxY)
				minZ = math.round(minZ)
				maxZ = math.round(maxZ)
			end
			
			if isBlind then
				return string.pack(numberFormat:rep(6), minX, minY, minZ, maxX, maxY, maxZ)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("B"..numberFormat:rep(6), index - 1, minX, minY, minZ, maxX, maxY, maxZ)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Region3
			local numberFormat = altNumberFormat or "n"

			local minX: number, minY: number, minZ: number, maxX: number, maxY: number, maxZ: number
			
			if isBlind then

				minX, minY, minZ, maxX, maxY, maxZ = string.unpack(numberFormat:rep(6), encodedValue)
			else
				local _index: number
				_index, minX, minY, minZ, maxX, maxY, maxZ = string.unpack("B"..numberFormat:rep(6), encodedValue)
			end

			local min = Vector3.new(minX, minY, minZ)
			local max = Vector3.new(maxX, maxY, maxZ)
		
			return Region3.new(min, max)
		end
	} :: CompressionPair<Region3>,	
	["Region3int16"] = {			
		encode = function(value: Region3int16, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "H"

			local minX = value.Min.X
			local maxX = value.Max.X
			local minY = value.Min.Y
			local maxY = value.Max.Y
			local minZ = value.Min.Z
			local maxZ = value.Max.Z

			if filterSign(numberFormat) == "B" then
				minX = math.round(minX)
				maxX = math.round(maxX)
				minY = math.round(minY)
				maxY = math.round(maxY)
				minZ = math.round(minZ)
				maxZ = math.round(maxZ)
			end
			if filterSign(numberFormat) == "H" then
				numberFormat = "H"
				minX = math.round(minX+INT_16_OFFSET)
				maxX = math.round(maxX+INT_16_OFFSET)
				minY = math.round(minY+INT_16_OFFSET)
				maxY = math.round(maxY+INT_16_OFFSET)
				minZ = math.round(minZ+INT_16_OFFSET)
				maxZ = math.round(maxZ+INT_16_OFFSET)
			elseif filterSign(numberFormat) == "B" then
				minX = math.round(minX)
				maxX = math.round(maxX)
				minY = math.round(minY)
				maxY = math.round(maxY)
				minZ = math.round(minZ)
				maxZ = math.round(maxZ)
			end


			if isBlind then
				return string.pack(numberFormat:rep(6), minX, minY, minZ, maxX, maxY, maxZ)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("B"..numberFormat:rep(6), index - 1, minX, minY, minZ, maxX, maxY, maxZ)
			end		
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Region3int16
			local numberFormat = altNumberFormat or "H"

			local minX: number, minY: number, minZ: number, maxX: number, maxY: number, maxZ: number
			
			if isBlind then

				minX, minY, minZ, maxX, maxY, maxZ = string.unpack(numberFormat:rep(6), encodedValue)
			else
				local _index: number
				_index, minX, minY, minZ, maxX, maxY, maxZ = string.unpack("B"..numberFormat:rep(6), encodedValue)
			end
			if filterSign(numberFormat) == "H" then
				minX = math.round(minX-INT_16_OFFSET)
				maxX = math.round(maxX-INT_16_OFFSET)
				minY = math.round(minY-INT_16_OFFSET)
				maxY = math.round(maxY-INT_16_OFFSET)
				minZ = math.round(minZ-INT_16_OFFSET)
				maxZ = math.round(maxZ-INT_16_OFFSET)
			end
			local min = Vector3int16.new(minX, minY, minZ)
			local max = Vector3int16.new(maxX, maxY, maxZ)

			return Region3int16.new(min, max)
		end
	} :: CompressionPair<Region3int16>,	
	["TweenInfo"] = {			
		encode = function(value: TweenInfo, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			local reverses = value.Reverses
			local repeatCount = value.RepeatCount
			local t = value.Time
			local delayTime = value.DelayTime
		
			if isBlind then
				return string.pack("BH"..numberFormat:rep(2).."BB", 
					if reverses then 1 else 0,
					repeatCount, 
					t,
					delayTime, 
					value.EasingDirection.Value, 
					value.EasingStyle.Value
				)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("BBH"..numberFormat:rep(2).."BB", 
					index - 1, 
					if reverses then 1 else 0,
					repeatCount, 
					t,
					delayTime, 
					value.EasingDirection.Value, 
					value.EasingStyle.Value
				)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): TweenInfo
			local numberFormat = altNumberFormat or "n"

			local reverseInt: number, repeatCount: number, t: number, delayTime: number, easingDirectionValue: number, easingStyleValue: number
			if isBlind then
				reverseInt, repeatCount, t, delayTime, easingDirectionValue, easingStyleValue = string.unpack("BH"..numberFormat:rep(2).."BB", encodedValue)
			else
				local _index: number
				_index, reverseInt, repeatCount, t, delayTime, easingDirectionValue, easingStyleValue = string.unpack("BBH"..numberFormat:rep(2).."BB", encodedValue)
			end
		
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
		encode = function(value: UDim, isBlind: boolean, altNumberFormat: string?): string
			local scale, offset = value.Scale, value.Offset
			if isBlind then
				return string.pack("nh", scale, offset)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("Bnh", index - 1, scale, offset)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): UDim
			local scale: number, offset: number
			if isBlind then
				scale, offset = string.unpack("nh", encodedValue)
			else
				local _index: number
				_index, scale, offset = string.unpack("Bnh", encodedValue)
			end
			return UDim.new(scale, offset)
		end
	} :: CompressionPair<UDim>,	
	["UDim2"] = {			
		encode = function(value: UDim2, isBlind: boolean, altNumberFormat: string?): string
			local xScale, xOffset, yScale, yOffset = value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset
			if isBlind then
				return string.pack("nhnh", xScale, xOffset, yScale, yOffset)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("Bnhnh", index - 1, xScale, xOffset, yScale, yOffset)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): UDim2
			local xScale: number, xOffset: number, yScale: number, yOffset: number
			if isBlind then
				xScale, xOffset, yScale, yOffset = string.unpack("nhnh", encodedValue)
			else
				local _index: number
				_index, xScale, xOffset, yScale, yOffset = string.unpack("Bnhnh", encodedValue)
			end
			return UDim2.new(xScale, xOffset, yScale, yOffset)
		end
	} :: CompressionPair<UDim2>,	
	["Vector2"] = {			
		encode = function(value: Vector2, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			local x, y = value.X, value.Y
			
			if isBlind then
				return string.pack(numberFormat:rep(2), x,y)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("B"..numberFormat:rep(2), index - 1, x,y)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Vector2
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				local x, y = string.unpack(numberFormat:rep(2), encodedValue)
				return Vector2.new(x,y)
			else
				local _index, x, y = string.unpack("B"..numberFormat:rep(2), encodedValue)
				return Vector2.new(x,y)
			end
		end
	} :: CompressionPair<Vector2>,	
	["Vector2int16"] = {			
		encode = function(value: Vector2int16, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "H"
		
			local x = value.X
			local y = value.Y
			if filterSign(numberFormat) == "H" then
				numberFormat = "H"
				x = math.round(value.X + INT_16_OFFSET)
				y = math.round(value.Y + INT_16_OFFSET)
			elseif filterSign(numberFormat) == "B" then
				x = math.round(value.X)
				y = math.round(value.Y)
			end

			if isBlind then
				return string.pack(numberFormat:rep(2), x,y)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("B"..numberFormat:rep(2), index - 1, x,y)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Vector2int16
			local numberFormat = altNumberFormat or "H"
			local x: number, y: number
			if filterSign(numberFormat) == "H" then
				numberFormat = "H"
			end
			if isBlind then
				x, y = string.unpack(numberFormat:rep(2), encodedValue)
			else
				local _index: number
				_index, x, y = string.unpack("B"..numberFormat:rep(2), encodedValue)
			end
			if filterSign(numberFormat) == "H" then
				x = math.round(x - INT_16_OFFSET)
				y = math.round(y - INT_16_OFFSET)
			end
			return Vector2int16.new(x,y)
		end
	} :: CompressionPair<Vector2int16>,	
	["Vector3"] = {			
		encode = function (value: Vector3, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			local x, y, z = value.X, value.Y, value.Z
			
			if isBlind then
				return string.pack(numberFormat:rep(3), x,y,z)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)

				return string.pack("B"..numberFormat:rep(3), index - 1, x,y,z)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Vector3
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				local x, y, z = string.unpack(numberFormat:rep(3), encodedValue)
				return Vector3.new(x,y,z)
			else
				local _index, x, y, z = string.unpack("B"..numberFormat:rep(3), encodedValue)
				return Vector3.new(x,y,z)
			end
		end
	} :: CompressionPair<Vector3>,	
	["Vector3int16"] = {			
		encode = function(value: Vector3int16, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "H"
			local x = value.X
			local y = value.Y
			local z = value.Z
			if filterSign(numberFormat) == "H" then
				numberFormat = "H"
				x = math.round(value.X + INT_16_OFFSET)
				y = math.round(value.Y + INT_16_OFFSET)
				z = math.round(value.Z + INT_16_OFFSET)
			elseif filterSign(numberFormat) == "B" then
				x = math.round(value.X)
				y = math.round(value.Y)
				z = math.round(value.Z)
			end
			if isBlind then
				return string.pack(numberFormat:rep(3), x,y,z)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("B"..numberFormat:rep(3), index - 1, x,y,z)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Vector3int16
			local numberFormat = altNumberFormat or "H"
			local x: number, y: number, z: number
			if filterSign(numberFormat) == "H" then
				numberFormat = "H"
			end
			if isBlind then
				x, y, z = string.unpack(numberFormat:rep(3), encodedValue)
			else
				local _index: number
				_index, x, y, z = string.unpack("B"..numberFormat:rep(3), encodedValue)
			end
			if filterSign(numberFormat) == "H" then
				x = math.round(x - INT_16_OFFSET)
				y = math.round(y - INT_16_OFFSET)
				z = math.round(z - INT_16_OFFSET)
			end
			return Vector3int16.new(x,y,z)
		end
	} :: CompressionPair<Vector3int16>,	
	["number"] = {		
		encode = function(value: number, isBlind: boolean, altNumberFormat: string?): string
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				return string.pack(numberFormat, value)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("B"..numberFormat, index - 1, value)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): number
			local numberFormat = altNumberFormat or "n"

			if isBlind then
				return string.unpack(numberFormat, encodedValue)
			else
				local _index, out = string.unpack("B"..numberFormat, encodedValue)
				return out
			end
		end	
	} :: CompressionPair<number>,	
	["string"] = {			
		encode = function(value: string, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				return string.pack("s", value)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("Bs", index - 1, value)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				return string.unpack("s", encodedValue)
			else
				local _index, out = string.unpack("Bs", encodedValue)
				return out
			end
		end	
	} :: CompressionPair<string>,	
	["boolean"] = {			
		encode = function(value: boolean, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				return string.pack("B", if value then 1 else 0)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack("BB", index - 1, if value then 1 else 0)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): boolean
			if isBlind then
				return string.unpack("B", encodedValue) == 1
			else
				local _index, out = string.unpack("BB", encodedValue)
				return out == 1
			end
		end	
	} :: CompressionPair<boolean>,	
	["Axes"] = {
		encode = function(value: Axes, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				return string.pack(
					"BBBBBBBBB", 
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
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack(
					"BBBBBBBBBB", 
					index - 1, 
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
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Axes
			local topValue: number, bottomValue: number, leftValue: number, rightValue: number, frontValue: number, backValue: number, xValue: number, yValue: number, zValue: number
			
			if isBlind then
				topValue, bottomValue, leftValue, rightValue, frontValue, backValue, xValue, yValue, zValue = string.unpack(
					"BBBBBBBBB", 
					encodedValue
				)
			else
				local _index: number
				_index, topValue, bottomValue, leftValue, rightValue, frontValue, backValue, xValue, yValue, zValue = string.unpack(
					"BBBBBBBBBB",
					encodedValue
				)
			end

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
	["Faces"] = {
		encode = function(value: Faces, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				return string.pack(
					"BBBBBB", 
					if value.Top then 1 else 0,
					if value.Bottom then 1 else 0,
					if value.Left then 1 else 0,
					if value.Right then 1 else 0,
					if value.Front then 1 else 0,
					if value.Back then 1 else 0
				)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
			
				return string.pack(
					"BBBBBBB", 
					index - 1, 
					if value.Top then 1 else 0,
					if value.Bottom then 1 else 0,
					if value.Left then 1 else 0,
					if value.Right then 1 else 0,
					if value.Front then 1 else 0,
					if value.Back then 1 else 0
				)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Faces
			local topValue: number, bottomValue: number, leftValue: number, rightValue: number, frontValue: number, backValue: number
			
			if isBlind then
				topValue, bottomValue, leftValue, rightValue, frontValue, backValue = string.unpack(
					"BBBBBB", 
					encodedValue
				)
			else
				local _index: number
				_index, topValue, bottomValue, leftValue, rightValue, frontValue, backValue = string.unpack(
					"BBBBBBB",
					encodedValue
				)
			end

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

			local value = Faces.new(table.unpack(faces))	
			return value
		end,
	} :: CompressionPair<Faces>,		
	-- ["FloatCurveKey"] = {
	-- 	encode = function(value: FloatCurveKey, isBlind: boolean, altNumberFormat: string?): string	
	-- 		local numberFormat = altNumberFormat or "n"


	-- 		local t = value.Time
	-- 		local v = value.Value

	-- 		warn(`pre-in fmt: {numberFormat} v: {v} t: {t}`)


	-- 		if filterSign(numberFormat) == "B" then
	-- 			t = math.round(t * 255)
	-- 			v = math.round(v)
	-- 		elseif filterSign(numberFormat) == "H" then
	-- 			t = math.round(t)
	-- 		-- elseif filterSign(numberFormat) == "H" then
	-- 		-- 	t = math.round(t * UNSIGNED_SHORT_LIMIT)
	-- 		end

	-- 		warn(`in fmt: {numberFormat} v: {v} t: {t}`)

	-- 		if isBlind then
	-- 			return string.pack(
	-- 				"B"..numberFormat:rep(4), 
	-- 				value.Interpolation.Value,
	-- 				value.LeftTangent or 0,
	-- 				value.RightTangent or 0,
	-- 				t,
	-- 				v
	-- 			)
	-- 		else
	-- 			local index = table.find(SUPPORTED_TYPES, typeof(value))
	-- 			assert(index)
	
	-- 			return string.pack(
	-- 				"BB"..numberFormat:rep(4), 
	-- 				index - 1, 
	-- 				value.Interpolation.Value,
	-- 				value.LeftTangent or 0,
	-- 				value.RightTangent or 0,
	-- 				t,
	-- 				v
	-- 			)
	-- 		end		
	-- 	end,
	-- 	decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): FloatCurveKey
	-- 		local numberFormat = altNumberFormat or "n"

	-- 		local interpolationValue: number, leftTangent: number, rightTangent: number, t: number, v: number

	-- 		if isBlind then
	-- 			interpolationValue, leftTangent, rightTangent, t, v = string.unpack(
	-- 				"B"..numberFormat:rep(4),
	-- 				encodedValue
	-- 			)		
	-- 		else
	-- 			local _index: number 
	-- 			_index, interpolationValue, leftTangent, rightTangent, t, v = string.unpack(
	-- 				"BB"..numberFormat:rep(4),
	-- 				encodedValue
	-- 			)			
	-- 		end
						
	-- 		warn(`pre-out fmt: {numberFormat} v: {v} t: {t}`)

	-- 		if filterSign(numberFormat) == "B" then
	-- 			t /= 255
	-- 		-- elseif filterSign(numberFormat) == "H" then

	-- 			-- t /= UNSIGNED_SHORT_LIMIT
	-- 		end

	-- 		warn(`out fmt: {numberFormat} v: {v} t: {t}`)

	-- 		local value = FloatCurveKey.new(
	-- 			t,
	-- 			v,
	-- 			getEnumItemByValue(Enum.KeyInterpolationMode, interpolationValue) :: Enum.KeyInterpolationMode
	-- 		)
					
	-- 		if value.Interpolation == Enum.KeyInterpolationMode.Cubic then
	-- 			if leftTangent ~= 0 then
	-- 				value.LeftTangent = leftTangent
	-- 			end
	-- 			if rightTangent ~= 0 then
	-- 				value.RightTangent = rightTangent
	-- 			end
	-- 		end

	-- 		return value
	-- 	end,
	-- } :: CompressionPair<FloatCurveKey>,	
	["Font"] = {
		encode = function(value: Font, isBlind: boolean, altNumberFormat: string?): string
			if isBlind then
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack(
					"BBHs",
					if value.Bold then 1 else 0, 
					value.Style.Value, 
					value.Weight.Value, 
					value.Family
				)
			else
				local index = table.find(SUPPORTED_TYPES, typeof(value))
				assert(index)
				return string.pack(
					"BBBHs", 
					index - 1, 
					if value.Bold then 1 else 0, 
					value.Style.Value, 
					value.Weight.Value, 
					value.Family
				)
			end
		end,
		decode = function(encodedValue: string, isBlind: boolean, altNumberFormat: string?): Font
			local boldValue: number, styleValue: number, weightValue: number, fontFamilyName: string
			if isBlind then
				boldValue, styleValue, weightValue, fontFamilyName = string.unpack(
					"BBHs", 
					encodedValue
				)	
			else
				local _index: number
				_index, boldValue, styleValue, weightValue, fontFamilyName = string.unpack(
					"BBBHs", 
					encodedValue
				)	
			end

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

function Util.decode(encodedValue: string, altNumberFormat: string?): any
	local index = string.unpack("B", encodedValue) + 1
	local key = SUPPORTED_TYPES[index]

	local compressionPair = Util.Library[key]
	assert(compressionPair, `missing valid type indicator`)
	
	return compressionPair.decode(encodedValue, false, altNumberFormat)
end

function Util.encode(value: ValidTypes, altNumberFormat: string?): string
	assert(typeof(value) ~= "table", `unstructured tables aren't supported, if it's a dictionary or array use the relevant functions`)
	
	local index = table.find(SUPPORTED_TYPES, typeof(value))
	assert(index, `type {typeof(value)} isn't a type that can be serialized / has instance properties`)

	local key = SUPPORTED_TYPES[index]
	local compressionPair = Util.Library[key]
	
	return compressionPair.encode(value, false, altNumberFormat)
end


return Util