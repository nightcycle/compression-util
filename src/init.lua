local Package = script
local _Packages = Package.Parent

-- local Serialize = require(Packages.Serialize)

local Util = {}

type Data = {[any]: any}
type ConverterTable<T> = {
	Serialize: (T) -> Data,
	Deserialize: (Data) -> T,
}

local serialConvert: <T>(T) -> Data
local deserialConvert: <T>(Data) -> T

local converters: {[string]: any} = {
	["BrickColor"] = {
		Serialize = function(value: BrickColor): Data
			return {
				Index = value.Number
			}
		end,
		Deserialize = function(data: Data): BrickColor
			return BrickColor.new(data.Index :: number)
		end,
	} :: ConverterTable<BrickColor>,
	["CFrame"] = {
		Serialize = function(value: CFrame): Data
			return {
				Position = value.Position,
				XVector = serialConvert(value.XVector),
				YVector = serialConvert(value.YVector),
				ZVector = serialConvert(value.ZVector),
			}
		end,
		Deserialize = function(data: Data): CFrame
			return CFrame.fromMatrix(data.Position or Vector3.new(0,0,0), deserialConvert(data.XVector), deserialConvert(data.YVector), deserialConvert(data.ZVector))
		end,
	} :: ConverterTable<CFrame>,
	["Color3"] = {
		Serialize = function(value: Color3): Data
			return {
				Hex = value:ToHex()
			}
		end,
		Deserialize = function(data: Data): Color3
			return Color3.fromHex(data.Hex)
		end,
	} :: ConverterTable<Color3>,
	["ColorSequence"] = {
		Serialize = function(value: ColorSequence): Data
			local keypointData = {}
			for i, keypoint: ColorSequenceKeypoint in ipairs(value.Keypoints) do
				keypointData[i] = serialConvert(keypoint)
			end
			return {
				Keypoints = keypointData
			}
		end,
		Deserialize = function(data: Data): ColorSequence
			local keypoints = {}
			for i, keypointData in ipairs(data.Keypoints) do
				keypoints[i] = deserialConvert(keypointData)
			end
			return ColorSequence.new(keypoints)
		end,
	} :: ConverterTable<ColorSequence>,
	["ColorSequenceKeypoint"] = {
		Serialize = function(value: ColorSequenceKeypoint): Data
			return {
				Time = value.Time,
				Value = serialConvert(value.Value),
			}
		end,
		Deserialize = function(data: Data): ColorSequenceKeypoint
			return ColorSequenceKeypoint.new(data.Time, deserialConvert(data.Value))
		end,
	} :: ConverterTable<ColorSequenceKeypoint>,
	["DateTime"] = {
		Serialize = function(value: DateTime): Data
			return {
				Milliseconds = value.UnixTimestampMillis
			}
		end,
		Deserialize = function(data: Data): DateTime
			return DateTime.fromUnixTimestampMillis(data.Milliseconds)
		end,
	} :: ConverterTable<DateTime>,
	["Enum"] = {
		Serialize = function(value: Enum): Data
			return {
				Name = tostring(value)
			}
		end,
		Deserialize = function(data: Data): Enum
			return Enum[data.Name]
		end,
	} :: ConverterTable<Enum>,
	["EnumItem"] = {
		Serialize = function(value: EnumItem): Data
			return {
				EnumName = tostring(value.EnumType),
				Name = value.Name,
			}
		end,
		Deserialize = function(data: Data): EnumItem
			return Enum[data.EnumName][data.Name]
		end,
	} :: ConverterTable<EnumItem>,
	-- ["Instance"] = {
	-- 	Serialize = function(value: Instance): Data
	-- 		return {
	-- 			SerialData = Serialize.Serialize(value)
	-- 		}
	-- 	end,
	-- 	Deserialize = function(data: Data): Instance
	-- 		return Serialize.Deserialize(data.SerialData)
	-- 	end,
	-- } :: ConverterTable<Instance>,
	["NumberRange"] = {
		Serialize = function(value: NumberRange): Data
			return {
				Minimum = value.Min,
				Maximum = value.Max
			}
		end,
		Deserialize = function(data: Data): NumberRange
			return NumberRange.new(data.Minimum, data.Maximum)
		end,
	} :: ConverterTable<NumberRange>,
	["NumberSequence"] = {
		Serialize = function(value: NumberSequence): Data
			local keypointData = {}
			for i, keypoint: NumberSequenceKeypoint in ipairs(value.Keypoints) do
				keypointData[i] = serialConvert(keypoint)
			end
			return {
				Keypoints = keypointData
			}
		end,
		Deserialize = function(data: Data): NumberSequence
			local keypoints = {}
			for i, keypointData in ipairs(data.Keypoints) do
				keypoints[i] = deserialConvert(keypointData)
			end
			return NumberSequence.new(keypoints)
		end,
	} :: ConverterTable<NumberSequence>,
	["NumberSequenceKeypoint"] = {
		Serialize = function(value: NumberSequenceKeypoint): Data
			return {
				Time = value.Time,
				Value = value.Value,
			}
		end,
		Deserialize = function(data: Data): NumberSequenceKeypoint
			return NumberSequenceKeypoint.new(data.Time, data.Value)
		end,
	} :: ConverterTable<NumberSequenceKeypoint>,
	["PathWaypoint"] = {
		Serialize = function(value: PathWaypoint): Data
			return {
				Position = serialConvert(value.Position),
				Action = serialConvert(value.Action),
				Label = (value :: any).Label
			}
		end,
		Deserialize = function(data: Data): PathWaypoint
			return (PathWaypoint.new :: any)(deserialConvert(data.Position), deserialConvert(data.Action), data.Label :: string)
		end,
	} :: ConverterTable<PathWaypoint>,
	["PhysicalProperties"] = {
		Serialize = function(value: PhysicalProperties): Data
			return {
				Density = value.Density,
				Friction = value.Friction,
				Elasticity = value.Elasticity,
				FrictionWeight = value.FrictionWeight,
				ElasticityWeight = value.ElasticityWeight
			}
		end,
		Deserialize = function(data: Data): PhysicalProperties
			return PhysicalProperties.new(data.Density, data.Friction, data.Elasticity, data.FrictionWeight, data.ElasticityWeight)
		end,
	} :: ConverterTable<PhysicalProperties>,
	["Ray"] = {
		Serialize = function(value: Ray): Data
			return {
				Origin = serialConvert(value.Origin),
				Direction = serialConvert(value.Direction),
			}
		end,
		Deserialize = function(data: Data): Ray
			return Ray.new(deserialConvert(data.Origin), deserialConvert(data.Direction))
		end,
	} :: ConverterTable<Ray>,
	["Rect"] = {
		Serialize = function(value: Rect): Data
			return {
				Min = serialConvert(value.Min),
				Max = serialConvert(value.Max)
			}
		end,
		Deserialize = function(data: Data): Rect
			return Rect.new(deserialConvert(data.Min), deserialConvert(data.Max))
		end,
	} :: ConverterTable<Rect>,
	["Region3"] = {
		Serialize = function(value: Region3): Data
			return {
				Size = serialConvert(value.Size),
				CFrame = serialConvert(value.CFrame),
			}
		end,
		Deserialize = function(data: Data): Region3
			local cf = deserialConvert(data.CFrame)
			local size = deserialConvert(data.Size)
			local min = (cf * CFrame.new(-size/2)).Position
			local max = (cf * CFrame.new(size/2)).Position
			return Region3.new(
				Vector3.new(
					math.min(min.X, max.X),
					math.min(min.Y, max.Y),
					math.min(min.Z, max.Z)
				),
				Vector3.new(
					math.max(min.X, max.X),
					math.max(min.Y, max.Y),
					math.max(min.Z, max.Z)
				)
			)
		end,
	} :: ConverterTable<Region3>,
	["Region3int16"] = {
		Serialize = function(value: Region3int16): Data
			return {
				Minimum = serialConvert(value.Min),
				Maximum = serialConvert(value.Max)
			}
		end,
		Deserialize = function(data: Data): Region3int16
			return Region3int16.new(deserialConvert(data.Min), deserialConvert(data.Max))
		end,
	} :: ConverterTable<Region3int16>,
	["TweenInfo"] = {
		Serialize = function(value: TweenInfo): Data
			return {
				Time = value.Time,
				EasingStyle = serialConvert(value.EasingStyle),
				EasingDirection = serialConvert(value.EasingDirection),
				RepeatCount = value.RepeatCount,
				Reverses = value.Reverses,
				DelayTime = value.DelayTime
			}
		end,
		Deserialize = function(data: Data): TweenInfo
			return TweenInfo.new(data.Time, deserialConvert(data.EasingStyle), deserialConvert(data.EasingDirection), data.RepeatCount, data.Reverses, data.DelayTime)
		end,
	} :: ConverterTable<TweenInfo>,
	["UDim"] = {
		Serialize = function(value: UDim): Data
			return {
				Scale = value.Scale,
				Offset = value.Offset
			}
		end,
		Deserialize = function(data: Data): UDim
			return UDim.new(data.Scale, data.Offset)
		end,
	} :: ConverterTable<UDim>,
	["UDim2"] = {
		Serialize = function(value: UDim2): Data
			return {
				X = serialConvert(value.X),
				Y = serialConvert(value.Y)
			}
		end,
		Deserialize = function(data: Data): UDim2
			return UDim2.new(deserialConvert(data.X), deserialConvert(data.Y))
		end,
	} :: ConverterTable<UDim2>,
	["Vector2"] = {
		Serialize = function(value: Vector2): Data
			return {
				X = value.X,
				Y = value.Y,
			}
		end,
		Deserialize = function(data: Data): Vector2
			return Vector2.new(data.X, data.Y)
		end,
	} :: ConverterTable<Vector2>,
	["Vector2int16"] = {
		Serialize = function(value: Vector2int16): Data
			return {
				X = value.X,
				Y = value.Y
			}
		end,
		Deserialize = function(data: Data): Vector2int16
			return Vector2int16.new(data.X, data.Y)
		end,
	} :: ConverterTable<Vector2int16>,
	["Vector3"] = {
		Serialize = function(value: Vector3): Data
			return {
				X = value.X,
				Y = value.Y,
				Z = value.Z
			}
		end,
		Deserialize = function(data: Data): Vector3
			return Vector3.new(data.X, data.Y, data.Z)
		end,
	} :: ConverterTable<Vector3>,
	["Vector3int16"] = {
		Serialize = function(value: Vector3int16): Data
			return {
				X = value.X,
				Y = value.Y,
				Z = value.Z,
			}
		end,
		Deserialize = function(data: Data): Vector3int16
			return Vector3int16.new(data.X, data.Y, data.Z)
		end,
	} :: ConverterTable<Vector3int16>,
	["nil"] = {
		Serialize = function(): Data
			return "nil" :: any
		end,
		Deserialize = function(data: Data): nil
			return nil :: any
		end,
	} :: ConverterTable<nil>,
	["number"] = {
		Serialize = function(value: number): Data
			return value :: any
		end,
		Deserialize = function(data: Data): number
			return data :: any
		end,
	} :: ConverterTable<number>,
	["string"] = {
		Serialize = function(value: string): Data
			return value :: any
		end,
		Deserialize = function(data: Data): string
			return data :: any
		end,
	} :: ConverterTable<string>,
	["boolean"] = {
		Serialize = function(value: boolean): Data
			return value :: any
		end,
		Deserialize = function(data: Data): boolean
			return data :: any
		end,
	} :: ConverterTable<boolean>,
	["table"] = {
		Serialize = function(value: {[any]: any}): Data

			local refList = {}

			local function sTable(subV)
				if refList[subV] then return refList[subV] end
				refList[subV] = subV
				if typeof(subV) == "table" then
					if subV["TYPE"] then
						local serData = serialConvert(subV)
						refList[subV] = serData

						return serData
					else
						local output = {}
						for k, v in pairs(subV) do
							if not refList[k] then
								refList[k] = sTable(k)
							end
							k = refList[k]
			
							if not refList[v] then
								refList[v] = sTable(v)
							end
							v = refList[v]
							output[k] = v
						end
						refList[subV] = output
						return output
					end
				else
					return serialConvert(subV)
				end	
			end

			return sTable(value)
		end,
		Deserialize = function(data: Data): {[any]: any}
			local function unpackTable(d: Data)
				local input = {}

				for k, v in pairs(d) do
					local dK
					local dV
					if typeof(v) == "table" then
						if v["TYPE"] then
							dV = deserialConvert(v)
						else
							dV = unpackTable(v)
						end
					else
						dV = v
					end
					if typeof(k) == "table" then
						if k["TYPE"] then
							dK = deserialConvert(k)
						else
							dK = unpackTable(k)
						end
					else
						dK = k
					end
					input[dK] = dV
				end
				return input
			end
			return unpackTable(data)
		end,
	} :: ConverterTable<{[any]: any}>,
}

serialConvert = function<T>(value: T): Data
	if type(value) == "table" or type(value) == "userdata" or type(value) == "vector" then
		local t = typeof(value)
		local converter = converters[t]

		assert(converter ~= nil, "No current support for "..tostring(t))
		local data = converter.Serialize(value)
		return {
			TYPE = t,
			DATA = data,
		}
	else
		return value :: any
	end
end

deserialConvert = function<T>(data: Data): T
	if type(data) == "table" then
		local t = data["TYPE"]
		local d = data["DATA"]
		local converter = converters[tostring(t)]
		assert(converter ~= nil, "No current support for "..tostring(t))
		assert(data ~= nil, "Bad data for "..tostring(t))
		return converter.Deserialize(d)
	else
		return data :: any
	end
end

function Util.serialize<T>(data: T): Data
	return serialConvert(data)
end

function Util.deserialize<T>(data: Data): T
	return deserialConvert(data)
end

return Util