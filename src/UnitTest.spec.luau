--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Packages
local TableUtil = require(_Packages:WaitForChild("TableUtil"))
-- Modules
-- Types
-- Constants
local SEED = tick()
local BIG = 10000000000
local ARRAY_LENGTH = 1000
local SAMPLE_SIZE = 1000
-- Variables
-- References

-- Class
return function()
	describe("compression-util", function()
		if _Packages.Parent ~= ReplicatedStorage then
			SKIP()
		end

		local SerializeUtil = require(script.Parent)

		describe("encode-array", function()
		
			local function testFloatArray(test: {[number]: {[number]: number}})

				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeFloatArray(array)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeFloatArray(value)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testIntegerArray(test: {[number]: {[number]: number}})
				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeIntegerArray(array)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeIntegerArray(value)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testDoubleArray(test: {[number]: {[number]: number}})
				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeDoubleArray(array)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeDoubleArray(value)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testStringArray(test: {[number]: {[number]: string}})
				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeStringArray(array)
				end

				local decodeTest: {[number]: {[number]: string}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeStringArray(value)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			it("string", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: string}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: string} = {}
					for j=1, ARRAY_LENGTH do
						for m=1, rng:NextInteger(1, 45) do
							array[j] = string.char(rng:NextInteger(48, 90))
						end
		
					end
					test[i] = array
				end
				testStringArray(test)
			end)

			it("float", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextNumber(-BIG, BIG)
					end
					test[i] = array
				end
				testFloatArray(test)
			end)
		
			it("integer", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextInteger(-BIG, BIG)
					end
					test[i] = array
				end

				testIntegerArray(test)
			end)


			it("double", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextNumber(-BIG, BIG)
					end
					test[i] = array
				end

				testDoubleArray(test)
			end)

			it("integer-inf", function()
				local test: {[number]: {[number]: number}} = {
					{
						123,
						1/0,
						-math.huge,
						922337203685477599,--0,
						-922337203685477599,
						456,
					}
				}

				testIntegerArray(test)
			end)

			it("float-inf", function()
				local test: {[number]: {[number]: number}} = {
					{
						123,
						1/0,
						-math.huge,
						9223372036854776000,
						-9223372036854775999,
						456,
					}
				}

				testFloatArray(test)
			end)
			it("double-inf", function()
				local test: {[number]: {[number]: number}} = {
					{
						123,
						1/0,
						-math.huge,
						9223372036854776000,
						-9223372036854775999,
						456,
					}
				}

				testDoubleArray(test)
			end)

			it("integer-nan", function()
				local test: {[number]: {[number]: number}} = {
					{
						Vector3.zero.Unit.Magnitude
					}
				}
				testIntegerArray(test)
			end)

			it("float-nan", function()
				local test: {[number]: {[number]: number}} = {
					{
						Vector3.zero.Unit.Magnitude
					}
				}
				testFloatArray(test)
			end)

			it("double-nan", function()
				local test: {[number]: {[number]: number}} = {
					{
						Vector3.zero.Unit.Magnitude
					}
				}
				testDoubleArray(test)
			end)

			it("integer-empty", function()
				local test: {[number]: {[number]: number}} = {
					{}
				}
				testIntegerArray(test)
			end)

			it("float-empty", function()
				local test: {[number]: {[number]: number}} = {
					{}
				}
				testFloatArray(test)
			end)

			it("double-empty", function()
				local test: {[number]: {[number]: number}} = {
					{}
				}
				testDoubleArray(test)
			end)
			it("string-empty", function()
				local test: {[number]: {[number]: string}} = {
					{}
				}
				testStringArray(test)
			end)
			
		end)

		describe("encode-type", function()

			it("BrickColor", function()
				-- local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = BrickColor.random()
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: BrickColor
					expect(v.Number).to.be.equal(out.Number)
				end
			end)
			it("CFrame", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = CFrame.fromMatrix(
						rng:NextUnitVector()*rng:NextInteger(-100000, 100000),
						rng:NextUnitVector(),
						rng:NextUnitVector(),
						rng:NextUnitVector()
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: CFrame
					expect(v.Position.X).to.be.equal(out.Position.X)
					expect(v.Position.Y).to.be.equal(out.Position.Y)
					expect(v.Position.Z).to.be.equal(out.Position.Z)
					expect(v.Rotation.X).to.be.equal(out.Rotation.X)
					expect(v.Rotation.Y).to.be.equal(out.Rotation.Y)
					expect(v.Rotation.Z).to.be.equal(out.Rotation.Z)
				end
			end)
			it("Color3", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = Color3.fromRGB(
						rng:NextInteger(1, 255),
						rng:NextInteger(1, 255),
						rng:NextInteger(1, 255)
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Color3
					expect(v:ToHex()).to.be.equal(out:ToHex())
				end
			end)
			it("ColorSequenceKeypoint", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = ColorSequenceKeypoint.new(
						rng:NextNumber(),
						Color3.fromRGB(
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255)
						)
					)
					
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: ColorSequenceKeypoint
					expect(v.Time).to.be.equal(out.Time)
					expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
				end
			end)
			it("ColorSequence", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local len = rng:NextInteger(2, 8)
					local keypoints: {[number]: ColorSequenceKeypoint} = {}
					for j=0, len do
						local t = j/len
						table.insert(
							keypoints, 
							ColorSequenceKeypoint.new(
								t,
								Color3.fromRGB(
									rng:NextInteger(1, 255),
									rng:NextInteger(1, 255),
									rng:NextInteger(1, 255)
								)
							)
						)
					end
					local v = ColorSequence.new(keypoints)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: ColorSequence

					for j, point in ipairs(v.Keypoints) do
						expect(point.Time).to.be.equal(out.Keypoints[j].Time)
						expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
					end

				end
			end)
			it("DateTime", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do

					local v = DateTime.fromUnixTimestampMillis(rng:NextInteger(1, math.round(tick())) * 1000)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: DateTime
					expect(v.UnixTimestampMillis).to.be.equal(out.UnixTimestampMillis)
				end
			end)
			it("Enum", function()
				-- local rng = Random.new(SEED)
				for i, v in ipairs(Enum:GetEnums()) do
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Enum
					expect(v).to.be.equal(out)
				end
			end)
			it("EnumItem", function()
				-- local rng = Random.new(SEED)
				for i, enum in ipairs(Enum:GetEnums()) do
					for j, v in ipairs(enum:GetEnumItems()) do
						local encoded = SerializeUtil.encodeType(v)
						local out = SerializeUtil.decodeType(encoded) :: EnumItem
						expect(v).to.be.equal(out)
					end
				end
			end)
			it("NumberSequenceKeypoint", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = NumberSequenceKeypoint.new(
						rng:NextNumber(),
						rng:NextNumber() * rng:NextInteger(-10000, 10000),
						rng:NextNumber()
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: NumberSequenceKeypoint
					expect(v.Time).to.be.equal(out.Time)
					expect(v.Value).to.be.equal(out.Value)
					expect(v.Envelope).to.be.equal(out.Envelope)
				end
			end)
			it("NumberSequence", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local len = rng:NextInteger(2, 8)
					local keypoints: {[number]: NumberSequenceKeypoint} = {}
					for j=0, len do
						local t = j/len
						table.insert(
							keypoints, 
							NumberSequenceKeypoint.new(
								t,
								rng:NextNumber() * rng:NextInteger(-10000, 10000),
								rng:NextNumber()
							)
						)
					end
					local v = NumberSequence.new(keypoints)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: NumberSequence

					for j, point in ipairs(v.Keypoints) do

						expect(point.Time).to.be.equal(out.Keypoints[j].Time)
						expect(point.Value).to.be.equal(out.Keypoints[j].Value)
						expect(point.Envelope).to.be.equal(out.Keypoints[j].Envelope)
					end
				end
			end)
			it("Vector2", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Vector2.new(v3.X, v3.Y)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Vector2
					expect(v.X).to.be.equal(out.X)
					expect(v.Y).to.be.equal(out.Y)
				end
			end)
			it("Vector2int16", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Vector2int16.new(v3.X, v3.Y)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Vector2int16
					expect(v.X).to.be.equal(out.X)
					expect(v.Y).to.be.equal(out.Y)
				end
			end)
			it("Vector3", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Vector3
					expect(v.X).to.be.equal(out.X)
					expect(v.Y).to.be.equal(out.Y)
					expect(v.Z).to.be.equal(out.Z)
				end
			end)
			it("Vector3int16", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Vector3int16.new(v3.X, v3.Y, v3.Z)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Vector3int16
					expect(v.X).to.be.equal(out.X)
					expect(v.Y).to.be.equal(out.Y)
					expect(v.Z).to.be.equal(out.Z)
				end
			end)
			it("PathWaypoint", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = PathWaypoint.new(
						rng:NextUnitVector() * rng:NextInteger(-10000, 10000),
						if rng:NextNumber() < 0.3 then Enum.PathWaypointAction.Jump elseif rng:NextNumber() < 0.31 then Enum.PathWaypointAction.Walk else Enum.PathWaypointAction.Custom
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: PathWaypoint
					expect(v.Position.X).to.be.equal(out.Position.X)
					expect(v.Position.Y).to.be.equal(out.Position.Y)
					expect(v.Position.Z).to.be.equal(out.Position.Z)
					expect(v.Action).to.be.equal(out.Action)
				end
			end)
			it("PhysicalProperties", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = PhysicalProperties.new(
						rng:NextNumber(),
						rng:NextNumber(),
						rng:NextNumber(),
						rng:NextNumber(),
						rng:NextNumber()	
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: PhysicalProperties
					expect(v.Friction).to.be.equal(out.Friction)
					expect(v.Elasticity).to.be.equal(out.Elasticity)
					expect(v.FrictionWeight).to.be.equal(out.FrictionWeight)
					expect(v.ElasticityWeight).to.be.equal(out.ElasticityWeight)
					expect(v.Density).to.be.equal(out.Density)
				end
			end)
			it("Ray", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local direction = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local origin = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Ray.new(origin, direction)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Ray
					expect(v.Origin.X).to.be.equal(out.Origin.X)
					expect(v.Origin.Y).to.be.equal(out.Origin.Y)
					expect(v.Origin.Z).to.be.equal(out.Origin.Z)
					expect(v.Direction.X).to.be.equal(out.Direction.X)
					expect(v.Direction.Y).to.be.equal(out.Direction.Y)
					expect(v.Direction.Z).to.be.equal(out.Direction.Z)
				end
			end)
			it("Rect", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local min = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local max = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Rect.new(
						Vector2.new(min.X, min.Y),
						Vector2.new(max.X, max.Y)
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Rect
					expect(v.Min.X).to.be.equal(out.Min.X)
					expect(v.Min.Y).to.be.equal(out.Min.Y)
					expect(v.Max.X).to.be.equal(out.Max.X)
					expect(v.Max.Y).to.be.equal(out.Max.Y)
				end
			end)
			it("Region3", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local min = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local max = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Region3.new(
						min,
						max
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Region3

					expect(v.Size.X).to.be.near(out.Size.X, 0.002)
					expect(v.Size.Y).to.be.near(out.Size.Y, 0.002)
					expect(v.Size.Z).to.be.near(out.Size.Z, 0.002)
					expect(v.CFrame.X).to.be.near(out.CFrame.X, 0.002)
					expect(v.CFrame.Y).to.be.near(out.CFrame.Y, 0.002)
					expect(v.CFrame.Z).to.be.near(out.CFrame.Z, 0.002)
					expect(v.CFrame.Rotation.X).to.be.near(out.CFrame.Rotation.X, 0.002)
					expect(v.CFrame.Rotation.Y).to.be.near(out.CFrame.Rotation.Y, 0.002)
					expect(v.CFrame.Rotation.Z).to.be.near(out.CFrame.Rotation.Z, 0.002)
				end
			end)
			it("Region3int16", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local min = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local max = rng:NextUnitVector() * rng:NextInteger(-10000, 10000)
					local v = Region3int16.new(
						Vector3int16.new(min.X, min.Y, min.Z),
						Vector3int16.new(max.X, max.Y, max.Z)
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Region3int16
					expect(v.Min.X).to.be.equal(out.Min.X)
					expect(v.Min.Y).to.be.equal(out.Min.Y)
					expect(v.Min.Z).to.be.equal(out.Min.Z)
					expect(v.Max.X).to.be.equal(out.Max.X)
					expect(v.Max.Y).to.be.equal(out.Max.Y)
					expect(v.Max.Z).to.be.equal(out.Max.Z)
				end
			end)
			it("TweenInfo", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = TweenInfo.new(
						rng:NextNumber(),
						Enum.EasingStyle.Bounce,
						Enum.EasingDirection.InOut,
						rng:NextInteger(1, 4),
						rng:NextNumber() < 0.5,
						rng:NextNumber() * 10
					)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: TweenInfo
					expect(v.DelayTime).to.be.equal(out.DelayTime)
					expect(v.EasingDirection).to.be.equal(out.EasingDirection)
					expect(v.EasingStyle).to.be.equal(out.EasingStyle)
					expect(v.RepeatCount).to.be.equal(out.RepeatCount)
					expect(v.Reverses).to.be.equal(out.Reverses)
					expect(v.Time).to.be.equal(out.Time)
				end
			end)
			it("UDim", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = UDim.new(rng:NextNumber(), rng:NextInteger(10, 300))
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: UDim
					expect(v.Scale).to.be.equal(out.Scale)
					expect(v.Offset).to.be.equal(out.Offset)
				end
			end)
			it("UDim2", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = UDim2.new(rng:NextNumber(), rng:NextInteger(10, 300), rng:NextNumber(), rng:NextInteger(10, 300))
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: UDim2
					expect(v.X.Scale).to.be.equal(out.X.Scale)
					expect(v.X.Offset).to.be.equal(out.X.Offset)
					expect(v.Y.Scale).to.be.equal(out.Y.Scale)
					expect(v.Y.Offset).to.be.equal(out.Y.Offset)
				end
			end)
			it("number", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = rng:NextNumber() * rng:NextInteger(-10000, 10000)
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: number
					expect(v).to.be.equal(out)
				end
			end)
			it("string", function()
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local v = ""
					for m=1, rng:NextInteger(1, 45) do
						v ..= string.char(rng:NextInteger(48, 90))
					end
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded)
					expect(v).to.be.equal(out)
				end
			end)
			it("boolean", function()
				for i=0, 1 do
					local v = i == 1
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: boolean
					expect(v).to.be.equal(out)
				end
			end)
			it("Axes", function()
				
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local axesFaces: {[number]: any} = {}

					for j, v in ipairs(Enum.NormalId:GetEnumItems()) do
						if rng:NextNumber() < 0.5 then
							table.insert(axesFaces, v)
						end
					end
					for j, v in ipairs(Enum.Axis:GetEnumItems()) do
						if rng:NextNumber() < 0.5 then
							table.insert(axesFaces, v)
						end
					end

					local v = Axes.new(unpack(axesFaces))
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Axes

					expect(v.Back).to.be.equal(out.Back)
					expect(v.Front).to.be.equal(out.Front)
					expect(v.Top).to.be.equal(out.Top)
					expect(v.Bottom).to.be.equal(out.Bottom)
					expect(v.Left).to.be.equal(out.Left)
					expect(v.Right).to.be.equal(out.Right)
					expect(v.X).to.be.equal(out.X)
					expect(v.Y).to.be.equal(out.Y)
					expect(v.Z).to.be.equal(out.Z)
				end
			end)
			it("CatalogSearchParams", function()
				
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local params = CatalogSearchParams.new() :: any
					local assetTypes: {[number]: Enum.AvatarAssetType} = {}
					for j, v in ipairs(Enum.AvatarAssetType:GetEnumItems()) do
						table.insert(assetTypes, v)
					end
					params.AssetTypes = assetTypes
					-- for j, v in pairs(params.AssetTypes) do
					-- 	warn(j.."] late verifying "..tostring(v).." with value "..tostring(v.Value))
					-- 	warn(j.."] vs "..tostring(assetTypes[j]).." with value "..tostring(assetTypes[j].Value))
					-- end

					local bundleTypes: {[number]: Enum.AvatarAssetType} = {}
					for j, v in ipairs(Enum.BundleType:GetEnumItems()) do
						if rng:NextNumber() < 0.5 then
							table.insert(bundleTypes, v)
						end
					end
					params.BundleTypes = bundleTypes

					params.MinPrice = rng:NextInteger(0, 100)
					params.MaxPrice = params.MinPrice + rng:NextNumber(1, 10000000)
					params.CategoryFilter = TableUtil.randomize(Enum.CatalogCategoryFilter:GetEnumItems())[rng:NextInteger(1, #Enum.CatalogCategoryFilter:GetEnumItems())]
					params.SortType = TableUtil.randomize(Enum.CatalogSortType:GetEnumItems())[rng:NextInteger(1, #Enum.CatalogSortType:GetEnumItems())]
					params.SearchKeyword = string.pack("L", rng:NextInteger(10000000, 100000000000))
					params.IncludeOffSale = rng:NextNumber() <= 0.5
					params.CreatorName = string.pack("L", rng:NextInteger(10000000, 100000000000))
					params.SalesTypeFilter = TableUtil.randomize(Enum.SalesTypeFilter:GetEnumItems())[rng:NextInteger(1, #Enum.SalesTypeFilter:GetEnumItems())]
					params.SortAggregation = TableUtil.randomize(Enum.CatalogSortAggregation:GetEnumItems())[rng:NextInteger(1, #Enum.CatalogSortAggregation:GetEnumItems())]


					local encoded = SerializeUtil.encodeType(params)
					local out = SerializeUtil.decodeType(encoded) :: any--CatalogSearchParams

					for j, v in ipairs(params.AssetTypes) do
						expect(table.find(out.AssetTypes, v) ~= nil).to.be.equal(true)
					end
					for j, v in ipairs(params.BundleTypes) do
						expect(table.find(out.BundleTypes, v) ~= nil).to.be.equal(true)
					end
					expect(params.CategoryFilter).to.be.equal(out.CategoryFilter)
					expect(params.MinPrice).to.be.equal(out.MinPrice)
					expect(params.MaxPrice).to.be.equal(out.MaxPrice)
					expect(params.SortType).to.be.equal(out.SortType)
					expect(params.SearchKeyword).to.be.equal(out.SearchKeyword)
					expect(params.SortAggregation).to.be.equal(out.SortAggregation)
				end
			end)
			it("Faces", function()
				
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					local axesFaces: {[number]: Enum.NormalId} = {}

					for j, v in ipairs(Enum.NormalId:GetEnumItems()) do
						if rng:NextNumber() < 0.5 then
							table.insert(axesFaces, v)
						end
					end

					local v = Faces.new(unpack(axesFaces))
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: Faces

					expect(v.Back).to.be.equal(out.Back)
					expect(v.Front).to.be.equal(out.Front)
					expect(v.Top).to.be.equal(out.Top)
					expect(v.Bottom).to.be.equal(out.Bottom)
					expect(v.Left).to.be.equal(out.Left)
					expect(v.Right).to.be.equal(out.Right)
				end
			end)
			it("FloatCurveKey", function()
				
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					
					local v = FloatCurveKey.new(
						rng:NextNumber(),
						rng:NextNumber(),
						Enum.KeyInterpolationMode:GetEnumItems()[rng:NextInteger(1, #Enum.KeyInterpolationMode:GetEnumItems())]
					)
					if v.Interpolation == Enum.KeyInterpolationMode.Cubic then
						v.LeftTangent = rng:NextNumber()
						v.RightTangent = rng:NextNumber()
					end
		
					local encoded = SerializeUtil.encodeType(v)
					local out = SerializeUtil.decodeType(encoded) :: FloatCurveKey

					expect(v.Time).to.be.equal(out.Time)
					expect(v.Value).to.be.equal(out.Value)
					expect(v.Interpolation).to.be.equal(out.Interpolation)
					expect(v.LeftTangent).to.be.equal(out.LeftTangent)
					expect(v.RightTangent).to.be.equal(out.RightTangent)
				end
			end)
			it("Font", function()
				for _, fontFamily in ipairs(Enum.Font:GetEnumItems()) do
					if fontFamily ~= Enum.Font.Unknown then
						for _, fontWeight in ipairs(Enum.FontWeight:GetEnumItems()) do
							for _, fontStyle in ipairs(Enum.FontStyle:GetEnumItems()) do
								for _, isBold in ipairs({true, false}) do
									local v = Font.fromEnum(fontFamily)
									v.Style = fontStyle
									v.Weight = fontWeight
									v.Bold = isBold
	
									local encoded = SerializeUtil.encodeType(v)
									local out = SerializeUtil.decodeType(encoded) :: Font
	
									expect(v.Family).to.be.equal(out.Family)
									expect(v.Style).to.be.equal(out.Style)
									expect(v.Weight).to.be.equal(out.Weight)
									expect(v.Bold).to.be.equal(out.Bold)
								end
							end
						end
					end
				end
			end)
		end)
	end)
end
