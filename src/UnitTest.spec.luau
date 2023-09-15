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
local SHORT_MAX = 65535
local ARRAY_LENGTH = 10--00
local SAMPLE_SIZE = 10--00
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
		
			local function testLongArray(test: {[number]: {[number]: number}}, isUnsigned: boolean)

				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.Array.Long.encode(array, isUnsigned)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.Array.Long.decode(value, isUnsigned)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testShortArray(test: {[number]: {[number]: number}}, isUnsigned: boolean)
				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.Array.Short.encode(array, isUnsigned)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.Array.Short.decode(value, isUnsigned)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testNumberArray(test: {[number]: {[number]: number}}, isUnsigned: boolean)
				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.Array.Number.encode(array, isUnsigned)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.Array.Number.decode(value, isUnsigned)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testStringArray(test: {[number]: {[number]: string}})
				local encodedTest: {[number]: string} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.Array.String.encode(array)
				end

				local decodeTest: {[number]: {[number]: string}} = {}
				for i, value in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.Array.String.decode(value)
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

			it("long-unsigned", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextInteger(0, BIG)
					end
					test[i] = array
				end
				testLongArray(test, true)
			end)
		
			it("long-signed", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextInteger(-BIG, BIG)
					end
					test[i] = array
				end
				testLongArray(test, false)
			end)

			it("short-unsigned", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextInteger(0, SHORT_MAX)
					end
					test[i] = array
				end

				testShortArray(test, true)
			end)

			it("number-signed", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, SAMPLE_SIZE do
					local array: {[number]: number} = {}
					for j=1, ARRAY_LENGTH do
						array[j] = rng:NextNumber(-SHORT_MAX, SHORT_MAX)
					end
					test[i] = array
				end

				testNumberArray(test, false)
			end)

			it("long-empty", function()
				local test: {[number]: {[number]: number}} = {
					{}
				}
				testLongArray(test, false)
			end)

			it("short-empty", function()
				local test: {[number]: {[number]: number}} = {
					{}
				}
				testShortArray(test, false)
			end)

			it("number-empty", function()
				local test: {[number]: {[number]: number}} = {
					{}
				}
				testNumberArray(test, false)
			end)
			it("string-empty", function()
				local test: {[number]: {[number]: string}} = {
					{}
				}
				testStringArray(test)
			end)
			
		end)

		describe("encode-type", function()
			describe("BrickColor", function()
				it("blind", function()
					-- local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = BrickColor.random()
						local encoded = SerializeUtil.Types.Library.BrickColor.encode(v, true)
						local out = SerializeUtil.Types.Library.BrickColor.decode(encoded, true)
						expect(v.Number).to.be.equal(out.Number)
					end
				end)
				it("generic", function()
					-- local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = BrickColor.random()
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: BrickColor
						expect(v.Number).to.be.equal(out.Number)
					end
				end)
			end)
			
			describe("CFrame", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: CFrame} = {}
				for i=1, SAMPLE_SIZE do
					local pos = rng:NextUnitVector()*rng:NextNumber(-127, 127)
					table.insert(ledger, CFrame.fromMatrix(
						Vector3.new(
							math.round(pos.X),
							math.round(pos.Y),
							math.round(pos.Z)
						),
						rng:NextUnitVector(),
						rng:NextUnitVector(),
						rng:NextUnitVector()
					))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.CFrame.encode(v, true)
							local out = SerializeUtil.Types.Library.CFrame.decode(encoded, true)
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Rotation.X).to.be.equal(out.Rotation.X)
							expect(v.Rotation.Y).to.be.equal(out.Rotation.Y)
							expect(v.Rotation.Z).to.be.equal(out.Rotation.Z)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.CFrame.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.CFrame.decode(encoded, true, "n")
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Rotation.X).to.be.equal(out.Rotation.X)
							expect(v.Rotation.Y).to.be.equal(out.Rotation.Y)
							expect(v.Rotation.Z).to.be.equal(out.Rotation.Z)
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.CFrame.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.CFrame.decode(encoded, true, "b")
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Rotation.X).to.be.near(out.Rotation.X, math.rad(2))
							expect(v.Rotation.Y).to.be.near(out.Rotation.Y, math.rad(2))
							expect(v.Rotation.Z).to.be.near(out.Rotation.Z, math.rad(2))
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.CFrame.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.CFrame.decode(encoded, true, "h")
							expect(v.Position.X).to.be.near(out.Position.X, 1)
							expect(v.Position.Y).to.be.near(out.Position.Y, 1)
							expect(v.Position.Z).to.be.near(out.Position.Z, 1)
							expect(v.Rotation.X).to.be.near(out.Rotation.X, math.rad(0.2))
							expect(v.Rotation.Y).to.be.near(out.Rotation.Y, math.rad(0.2))
							expect(v.Rotation.Z).to.be.near(out.Rotation.Z, math.rad(0.2))
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: CFrame
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Rotation.X).to.be.equal(out.Rotation.X)
							expect(v.Rotation.Y).to.be.equal(out.Rotation.Y)
							expect(v.Rotation.Z).to.be.equal(out.Rotation.Z)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: CFrame
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Rotation.X).to.be.equal(out.Rotation.X)
							expect(v.Rotation.Y).to.be.equal(out.Rotation.Y)
							expect(v.Rotation.Z).to.be.equal(out.Rotation.Z)
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: CFrame
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Rotation.X).to.be.near(out.Rotation.X, math.rad(2))
							expect(v.Rotation.Y).to.be.near(out.Rotation.Y, math.rad(2))
							expect(v.Rotation.Z).to.be.near(out.Rotation.Z, math.rad(2))
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: CFrame
							expect(v.Position.X).to.be.near(out.Position.X, 1)
							expect(v.Position.Y).to.be.near(out.Position.Y, 1)
							expect(v.Position.Z).to.be.near(out.Position.Z, 1)
							expect(v.Rotation.X).to.be.near(out.Rotation.X, math.rad(0.2))
							expect(v.Rotation.Y).to.be.near(out.Rotation.Y, math.rad(0.2))
							expect(v.Rotation.Z).to.be.near(out.Rotation.Z, math.rad(0.2))
						end
					end)
				end)
			end)
			describe("Color3", function()
				it("blind", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = Color3.fromRGB(
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255)
						)
						local encoded = SerializeUtil.Types.Library.Color3.encode(v, true)
						local out = SerializeUtil.Types.Library.Color3.decode(encoded, true)
						expect(v:ToHex()).to.be.equal(out:ToHex())
					end
				end)
				it("generic", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = Color3.fromRGB(
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255)
						)
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: Color3
						expect(v:ToHex()).to.be.equal(out:ToHex())
					end
				end)
			end)

			describe("ColorSequenceKeypoint", function()
				local ledger: {[number]: ColorSequenceKeypoint} = {}
				local rng = Random.new(SEED)
				for i=1, SAMPLE_SIZE do
					table.insert(ledger, ColorSequenceKeypoint.new(
						rng:NextNumber(),
						Color3.fromRGB(
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255),
							rng:NextInteger(1, 255)
						)
					))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequenceKeypoint.encode(v, true)
							local out = SerializeUtil.Types.Library.ColorSequenceKeypoint.decode(encoded, true) :: ColorSequenceKeypoint
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequenceKeypoint.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.ColorSequenceKeypoint.decode(encoded, true, "n") :: ColorSequenceKeypoint
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequenceKeypoint.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.ColorSequenceKeypoint.decode(encoded, true, "b") :: ColorSequenceKeypoint
							expect(v.Time).to.be.near(out.Time, 1/255)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequenceKeypoint.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.ColorSequenceKeypoint.decode(encoded, true, "h") :: ColorSequenceKeypoint
							expect(v.Time).to.be.near(out.Time, 1)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: ColorSequenceKeypoint
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: ColorSequenceKeypoint
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: ColorSequenceKeypoint
							expect(v.Time).to.be.near(out.Time, 1/255)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: ColorSequenceKeypoint
							expect(v.Time).to.be.near(out.Time, 1)
							expect(v.Value:ToHex()).to.be.equal(out.Value:ToHex())
						end
					end)
				end)
			end)
			
			describe("ColorSequence", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: ColorSequence} = {}
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
					table.insert(ledger, ColorSequence.new(keypoints))
				end

				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequence.encode(v, true)
							local out = SerializeUtil.Types.Library.ColorSequence.decode(encoded, true) :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequence.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.ColorSequence.decode(encoded, true, "n") :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequence.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.ColorSequence.decode(encoded, true, "b") :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/255)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.ColorSequence.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.ColorSequence.decode(encoded, true, "h") :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/SHORT_MAX)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/255)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: ColorSequence
		
							for j, point in ipairs(v.Keypoints) do
								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/SHORT_MAX)
								expect(point.Value:ToHex()).to.be.equal(out.Keypoints[j].Value:ToHex())
							end
						end
					end)
				end)
			end)
			describe("DateTime", function()
				it("blind", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
	
						local v = DateTime.fromUnixTimestampMillis(rng:NextInteger(1, math.round(tick())) * 1000)
						local encoded = SerializeUtil.Types.Library.DateTime.encode(v, true)
						local out = SerializeUtil.Types.Library.DateTime.decode(encoded, true) :: DateTime
						expect(v.UnixTimestampMillis).to.be.equal(out.UnixTimestampMillis)
					end
				end)
				it("generic", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
	
						local v = DateTime.fromUnixTimestampMillis(rng:NextInteger(1, math.round(tick())) * 1000)
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: DateTime
						expect(v.UnixTimestampMillis).to.be.equal(out.UnixTimestampMillis)
					end
				end)
			end)

			describe("Enum", function()
				it("blind", function()
					for i, v in ipairs(Enum:GetEnums()) do
						local encoded = SerializeUtil.Types.Library.Enum.encode(v, true)
						local out = SerializeUtil.Types.Library.Enum.decode(encoded, true) :: Enum
						expect(v).to.be.equal(out)
					end
				end)
				it("generic", function()
					for i, v in ipairs(Enum:GetEnums()) do
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: Enum
						expect(v).to.be.equal(out)
					end
				end)
			end)
			describe("EnumItem", function()
				it("blind", function()
					for i, enum in ipairs(Enum:GetEnums()) do
						if enum ~= Enum.ReservedHighlightId then
							for j, v in ipairs(enum:GetEnumItems()) do

								local encoded = SerializeUtil.Types.Library.EnumItem.encode(v, true)
								local out = SerializeUtil.Types.Library.EnumItem.decode(encoded, true) :: EnumItem
								expect(v).to.be.equal(out)
							end
						end
					end
				end)
				it("generic", function()
					for i, enum in ipairs(Enum:GetEnums()) do
						if enum ~= Enum.ReservedHighlightId then
							for j, v in ipairs(enum:GetEnumItems()) do
								local encoded = SerializeUtil.Types.encode(v)
								local out = SerializeUtil.Types.decode(encoded) :: EnumItem
								expect(v).to.be.equal(out)
							end
						end

					end
				end)
			end)
			describe("NumberSequenceKeypoint", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: NumberSequenceKeypoint} = {}
				for i=1, SAMPLE_SIZE do
					table.insert(ledger, NumberSequenceKeypoint.new(
						rng:NextNumber(),
						rng:NextNumber() * rng:NextInteger(-126, 126),
						rng:NextNumber()
					))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequenceKeypoint.encode(v, true)
							local out = SerializeUtil.Types.Library.NumberSequenceKeypoint.decode(encoded, true)
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value).to.be.equal(out.Value)
							expect(v.Envelope).to.be.equal(out.Envelope)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequenceKeypoint.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.NumberSequenceKeypoint.decode(encoded, true, "n")
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value).to.be.equal(out.Value)
							expect(v.Envelope).to.be.equal(out.Envelope)
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequenceKeypoint.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.NumberSequenceKeypoint.decode(encoded, true, "b")
							expect(v.Time).to.be.near(out.Time, 1/255)
							expect(v.Value).to.be.near(out.Value, 1)
							expect(v.Envelope).to.be.near(out.Envelope, 1)
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequenceKeypoint.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.NumberSequenceKeypoint.decode(encoded, true, "h")
							expect(v.Time).to.be.near(out.Time, 1/SHORT_MAX)
							expect(v.Value).to.be.near(out.Value, 1)
							expect(v.Envelope).to.be.near(out.Envelope, 1)
						end
					end)
				end)
				it("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: NumberSequenceKeypoint
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value).to.be.equal(out.Value)
							expect(v.Envelope).to.be.equal(out.Envelope)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: NumberSequenceKeypoint
							expect(v.Time).to.be.equal(out.Time)
							expect(v.Value).to.be.equal(out.Value)
							expect(v.Envelope).to.be.equal(out.Envelope)
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: NumberSequenceKeypoint
							expect(v.Time).to.be.near(out.Time, 1/255)
							expect(v.Value).to.be.near(out.Value, 1)
							expect(v.Envelope).to.be.near(out.Envelope, 1)
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: NumberSequenceKeypoint
							expect(v.Time).to.be.near(out.Time, 1/SHORT_MAX)
							expect(v.Value).to.be.near(out.Value, 1)
							expect(v.Envelope).to.be.near(out.Envelope, 1)
						end
					end)
				end)
			end)
			describe("NumberSequence", function()
				local ledger: {[number]: NumberSequence} = {}
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
								rng:NextNumber() * rng:NextInteger(-126, 126),
								rng:NextNumber()
							)
						)
					end
					table.insert(ledger, NumberSequence.new(keypoints))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequence.encode(v, true)
							local out = SerializeUtil.Types.Library.NumberSequence.decode(encoded, true)

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value).to.be.equal(out.Keypoints[j].Value)
								expect(point.Envelope).to.be.equal(out.Keypoints[j].Envelope)
							end
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequence.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.NumberSequence.decode(encoded, true, "n")

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value).to.be.equal(out.Keypoints[j].Value)
								expect(point.Envelope).to.be.equal(out.Keypoints[j].Envelope)
							end
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequence.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.NumberSequence.decode(encoded, true, "b")

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/255)
								expect(point.Value).to.be.near(out.Keypoints[j].Value, 1)
								expect(point.Envelope).to.be.near(out.Keypoints[j].Envelope, 1)
							end
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.NumberSequence.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.NumberSequence.decode(encoded, true, "h")

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/SHORT_MAX)
								expect(point.Value).to.be.near(out.Keypoints[j].Value, 1)
								expect(point.Envelope).to.be.near(out.Keypoints[j].Envelope, 1)
							end
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded)

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value).to.be.equal(out.Keypoints[j].Value)
								expect(point.Envelope).to.be.equal(out.Keypoints[j].Envelope)
							end
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n")

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.equal(out.Keypoints[j].Time)
								expect(point.Value).to.be.equal(out.Keypoints[j].Value)
								expect(point.Envelope).to.be.equal(out.Keypoints[j].Envelope)
							end
						end
					end)
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b")

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/255)
								expect(point.Value).to.be.near(out.Keypoints[j].Value, 1)
								expect(point.Envelope).to.be.near(out.Keypoints[j].Envelope, 1)
							end
						end
					end)
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h")

							for j, point in ipairs(v.Keypoints) do

								expect(point.Time).to.be.near(out.Keypoints[j].Time, 1/SHORT_MAX)
								expect(point.Value).to.be.near(out.Keypoints[j].Value, 1)
								expect(point.Envelope).to.be.near(out.Keypoints[j].Envelope, 1)
							end
						end
					end)
				end)
			end)
			describe("Vector2", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Vector2} = {}

				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					table.insert(ledger, Vector2.new(v3.X, v3.Y))

				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2.encode(v, true)
							local out = SerializeUtil.Types.Library.Vector2.decode(encoded, true)
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Vector2.decode(encoded, true, "n")
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Vector2.decode(encoded, true, "b")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Vector2.decode(encoded, true, "h")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Vector2
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Vector2
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Vector2
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Vector2
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
				end)
			end)
			describe("Vector2int16", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Vector2int16} = {}

				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					table.insert(ledger, Vector2int16.new(v3.X, v3.Y))

				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2int16.encode(v, true)
							local out = SerializeUtil.Types.Library.Vector2int16.decode(encoded, true)
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2int16.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Vector2int16.decode(encoded, true, "n")
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2int16.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Vector2int16.decode(encoded, true, "b")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector2int16.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Vector2int16.decode(encoded, true, "h")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Vector2
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Vector2
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Vector2
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Vector2
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
						end
					end)
				end)
			end)
			describe("Vector3", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Vector3} = {}

				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					table.insert(ledger, Vector3.new(v3.X, v3.Y, v3.Z))

				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3.encode(v, true)
							local out = SerializeUtil.Types.Library.Vector3.decode(encoded, true)
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Vector3.decode(encoded, true, "n")
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Vector3.decode(encoded, true, "b")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Vector3.decode(encoded, true, "h")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)

						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Vector3
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Vector3
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Vector3
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Vector3
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)
						end
					end)
				end)
			end)
			describe("Vector3int16", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Vector3int16} = {}

				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					table.insert(ledger, Vector3int16.new(v3.X, v3.Y, v3.Z))

				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3int16.encode(v, true)
							local out = SerializeUtil.Types.Library.Vector3int16.decode(encoded, true)
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3int16.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Vector3int16.decode(encoded, true, "n")
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3int16.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Vector3int16.decode(encoded, true, "b")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Vector3int16.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Vector3int16.decode(encoded, true, "h")
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)

						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Vector3
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Vector3
							expect(v.X).to.be.equal(out.X)
							expect(v.Y).to.be.equal(out.Y)
							expect(v.Z).to.be.equal(out.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Vector3
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Vector3
							expect(v.X).to.be.near(out.X, 1)
							expect(v.Y).to.be.near(out.Y, 1)
							expect(v.Z).to.be.near(out.Z, 1)
						end
					end)
				end)
			end)
			describe("PathWaypoint", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: PathWaypoint} = {}

				for i=1, SAMPLE_SIZE do
					local v3 = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					table.insert(ledger, PathWaypoint.new(
						Vector3.new(v3.X, v3.Y, v3.Z),
						if rng:NextNumber() < 0.3 then Enum.PathWaypointAction.Jump elseif rng:NextNumber() < 0.31 then Enum.PathWaypointAction.Walk else Enum.PathWaypointAction.Custom
					))

				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PathWaypoint.encode(v, true)
							local out = SerializeUtil.Types.Library.PathWaypoint.decode(encoded, true)
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PathWaypoint.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.PathWaypoint.decode(encoded, true, "n")
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PathWaypoint.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.PathWaypoint.decode(encoded, true, "b")
							expect(v.Position.X).to.be.near(out.Position.X, 1)
							expect(v.Position.Y).to.be.near(out.Position.Y, 1)
							expect(v.Position.Z).to.be.near(out.Position.Z, 1)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PathWaypoint.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.PathWaypoint.decode(encoded, true, "h")
							expect(v.Position.X).to.be.near(out.Position.X, 1)
							expect(v.Position.Y).to.be.near(out.Position.Y, 1)
							expect(v.Position.Z).to.be.near(out.Position.Z, 1)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: PathWaypoint
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: PathWaypoint
							expect(v.Position.X).to.be.equal(out.Position.X)
							expect(v.Position.Y).to.be.equal(out.Position.Y)
							expect(v.Position.Z).to.be.equal(out.Position.Z)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: PathWaypoint
							expect(v.Position.X).to.be.near(out.Position.X, 1)
							expect(v.Position.Y).to.be.near(out.Position.Y, 1)
							expect(v.Position.Z).to.be.near(out.Position.Z, 1)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: PathWaypoint
							expect(v.Position.X).to.be.near(out.Position.X, 1)
							expect(v.Position.Y).to.be.near(out.Position.Y, 1)
							expect(v.Position.Z).to.be.near(out.Position.Z, 1)
							expect(v.Action).to.be.equal(out.Action)
						end
					end)
				end)
			end)
			describe("PhysicalProperties", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: PhysicalProperties} = {}

				for i=1, SAMPLE_SIZE do
					table.insert(ledger, PhysicalProperties.new(
						rng:NextNumber(),
						rng:NextNumber(),
						rng:NextNumber(),
						rng:NextNumber(),
						rng:NextNumber()	
					))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PhysicalProperties.encode(v, true)
							local out = SerializeUtil.Types.Library.PhysicalProperties.decode(encoded, true)
							expect(v.Friction).to.be.equal(out.Friction)
							expect(v.Elasticity).to.be.equal(out.Elasticity)
							expect(v.FrictionWeight).to.be.equal(out.FrictionWeight)
							expect(v.ElasticityWeight).to.be.equal(out.ElasticityWeight)
							expect(v.Density).to.be.equal(out.Density)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PhysicalProperties.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.PhysicalProperties.decode(encoded, true, "n")
							expect(v.Friction).to.be.equal(out.Friction)
							expect(v.Elasticity).to.be.equal(out.Elasticity)
							expect(v.FrictionWeight).to.be.equal(out.FrictionWeight)
							expect(v.ElasticityWeight).to.be.equal(out.ElasticityWeight)
							expect(v.Density).to.be.equal(out.Density)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PhysicalProperties.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.PhysicalProperties.decode(encoded, true, "b")
							expect(v.Friction).to.be.near(out.Friction, 1)
							expect(v.Elasticity).to.be.near(out.Elasticity, 1)
							expect(v.FrictionWeight).to.be.near(out.FrictionWeight, 1)
							expect(v.ElasticityWeight).to.be.near(out.ElasticityWeight, 1)
							expect(v.Density).to.be.near(out.Density, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.PhysicalProperties.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.PhysicalProperties.decode(encoded, true, "h")
							expect(v.Friction).to.be.near(out.Friction, 1)
							expect(v.Elasticity).to.be.near(out.Elasticity, 1)
							expect(v.FrictionWeight).to.be.near(out.FrictionWeight, 1)
							expect(v.ElasticityWeight).to.be.near(out.ElasticityWeight, 1)
							expect(v.Density).to.be.near(out.Density, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: PhysicalProperties
							expect(v.Friction).to.be.equal(out.Friction)
							expect(v.Elasticity).to.be.equal(out.Elasticity)
							expect(v.FrictionWeight).to.be.equal(out.FrictionWeight)
							expect(v.ElasticityWeight).to.be.equal(out.ElasticityWeight)
							expect(v.Density).to.be.equal(out.Density)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: PhysicalProperties
							expect(v.Friction).to.be.equal(out.Friction)
							expect(v.Elasticity).to.be.equal(out.Elasticity)
							expect(v.FrictionWeight).to.be.equal(out.FrictionWeight)
							expect(v.ElasticityWeight).to.be.equal(out.ElasticityWeight)
							expect(v.Density).to.be.equal(out.Density)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: PhysicalProperties
							expect(v.Friction).to.be.near(out.Friction, 1)
							expect(v.Elasticity).to.be.near(out.Elasticity, 1)
							expect(v.FrictionWeight).to.be.near(out.FrictionWeight, 1)
							expect(v.ElasticityWeight).to.be.near(out.ElasticityWeight, 1)
							expect(v.Density).to.be.near(out.Density, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: PhysicalProperties
							expect(v.Friction).to.be.near(out.Friction, 1)
							expect(v.Elasticity).to.be.near(out.Elasticity, 1)
							expect(v.FrictionWeight).to.be.near(out.FrictionWeight, 1)
							expect(v.ElasticityWeight).to.be.near(out.ElasticityWeight, 1)
							expect(v.Density).to.be.near(out.Density, 1)
						end
					end)
				end)
			end)
			describe("Ray", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Ray} = {}

				for i=1, SAMPLE_SIZE do
					local direction = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local origin = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local v = Ray.new(origin, direction)
					table.insert(ledger, v)
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Ray.encode(v, true)
							local out = SerializeUtil.Types.Library.Ray.decode(encoded, true)
							expect(v.Origin.X).to.be.equal(out.Origin.X)
							expect(v.Origin.Y).to.be.equal(out.Origin.Y)
							expect(v.Origin.Z).to.be.equal(out.Origin.Z)
							expect(v.Direction.X).to.be.equal(out.Direction.X)
							expect(v.Direction.Y).to.be.equal(out.Direction.Y)
							expect(v.Direction.Z).to.be.equal(out.Direction.Z)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Ray.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Ray.decode(encoded, true, "n")
							expect(v.Origin.X).to.be.equal(out.Origin.X)
							expect(v.Origin.Y).to.be.equal(out.Origin.Y)
							expect(v.Origin.Z).to.be.equal(out.Origin.Z)
							expect(v.Direction.X).to.be.equal(out.Direction.X)
							expect(v.Direction.Y).to.be.equal(out.Direction.Y)
							expect(v.Direction.Z).to.be.equal(out.Direction.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Ray.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Ray.decode(encoded, true, "b")
							expect(v.Origin.X).to.be.near(out.Origin.X, 1)
							expect(v.Origin.Y).to.be.near(out.Origin.Y, 1)
							expect(v.Origin.Z).to.be.near(out.Origin.Z, 1)
							expect(v.Direction.X).to.be.near(out.Direction.X, 1)
							expect(v.Direction.Y).to.be.near(out.Direction.Y, 1)
							expect(v.Direction.Z).to.be.near(out.Direction.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Ray.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Ray.decode(encoded, true, "h")
							expect(v.Origin.X).to.be.near(out.Origin.X, 1)
							expect(v.Origin.Y).to.be.near(out.Origin.Y, 1)
							expect(v.Origin.Z).to.be.near(out.Origin.Z, 1)
							expect(v.Direction.X).to.be.near(out.Direction.X, 1)
							expect(v.Direction.Y).to.be.near(out.Direction.Y, 1)
							expect(v.Direction.Z).to.be.near(out.Direction.Z, 1)

						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Ray
							expect(v.Origin.X).to.be.equal(out.Origin.X)
							expect(v.Origin.Y).to.be.equal(out.Origin.Y)
							expect(v.Origin.Z).to.be.equal(out.Origin.Z)
							expect(v.Direction.X).to.be.equal(out.Direction.X)
							expect(v.Direction.Y).to.be.equal(out.Direction.Y)
							expect(v.Direction.Z).to.be.equal(out.Direction.Z)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Ray
							expect(v.Origin.X).to.be.equal(out.Origin.X)
							expect(v.Origin.Y).to.be.equal(out.Origin.Y)
							expect(v.Origin.Z).to.be.equal(out.Origin.Z)
							expect(v.Direction.X).to.be.equal(out.Direction.X)
							expect(v.Direction.Y).to.be.equal(out.Direction.Y)
							expect(v.Direction.Z).to.be.equal(out.Direction.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Ray
							expect(v.Origin.X).to.be.near(out.Origin.X, 1)
							expect(v.Origin.Y).to.be.near(out.Origin.Y, 1)
							expect(v.Origin.Z).to.be.near(out.Origin.Z, 1)
							expect(v.Direction.X).to.be.near(out.Direction.X, 1)
							expect(v.Direction.Y).to.be.near(out.Direction.Y, 1)
							expect(v.Direction.Z).to.be.near(out.Direction.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Ray
							expect(v.Origin.X).to.be.near(out.Origin.X, 1)
							expect(v.Origin.Y).to.be.near(out.Origin.Y, 1)
							expect(v.Origin.Z).to.be.near(out.Origin.Z, 1)
							expect(v.Direction.X).to.be.near(out.Direction.X, 1)
							expect(v.Direction.Y).to.be.near(out.Direction.Y, 1)
							expect(v.Direction.Z).to.be.near(out.Direction.Z, 1)
						end
					end)
				end)
			end)
			describe("Rect", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Rect} = {}

				for i=1, SAMPLE_SIZE do
					local min = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local max = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local v = Rect.new(
						Vector2.new(min.X, min.Y),
						Vector2.new(max.X, max.Y)
					)
					table.insert(ledger, v)
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Rect.encode(v, true)
							local out = SerializeUtil.Types.Library.Rect.decode(encoded, true)
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Rect.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Rect.decode(encoded, true, "n")
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Rect.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Rect.decode(encoded, true, "b")
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Rect.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Rect.decode(encoded, true, "h")
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)

						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Rect
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Rect
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Rect
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Rect
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
						end
					end)
				end)
			end)
			describe("Region3", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Region3} = {}

				for i=1, SAMPLE_SIZE do
					local min = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local max = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local v = Region3.new(
						min,
						max
					)
					table.insert(ledger, v)
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3.encode(v, true)
							local out = SerializeUtil.Types.Library.Region3.decode(encoded, true)
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

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Region3.decode(encoded, true, "n")
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
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Region3.decode(encoded, true, "b")
							expect(v.Size.X).to.be.near(out.Size.X, 1)
							expect(v.Size.Y).to.be.near(out.Size.Y, 1)
							expect(v.Size.Z).to.be.near(out.Size.Z, 1)
							expect(v.CFrame.X).to.be.near(out.CFrame.X, 1)
							expect(v.CFrame.Y).to.be.near(out.CFrame.Y, 1)
							expect(v.CFrame.Z).to.be.near(out.CFrame.Z, 1)
							expect(v.CFrame.Rotation.X).to.be.near(out.CFrame.Rotation.X, math.rad(3))
							expect(v.CFrame.Rotation.Y).to.be.near(out.CFrame.Rotation.Y,math.rad(3))
							expect(v.CFrame.Rotation.Z).to.be.near(out.CFrame.Rotation.Z, math.rad(3))
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Region3.decode(encoded, true, "h")
							expect(v.Size.X).to.be.near(out.Size.X, 2)
							expect(v.Size.Y).to.be.near(out.Size.Y, 2)
							expect(v.Size.Z).to.be.near(out.Size.Z, 2)
							expect(v.CFrame.X).to.be.near(out.CFrame.X, 2)
							expect(v.CFrame.Y).to.be.near(out.CFrame.Y, 2)
							expect(v.CFrame.Z).to.be.near(out.CFrame.Z, 2)
							expect(v.CFrame.Rotation.X).to.be.near(out.CFrame.Rotation.X, math.rad(360/SHORT_MAX))
							expect(v.CFrame.Rotation.Y).to.be.near(out.CFrame.Rotation.Y, math.rad(360/SHORT_MAX))
							expect(v.CFrame.Rotation.Z).to.be.near(out.CFrame.Rotation.Z, math.rad(360/SHORT_MAX))
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Region3
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
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Region3
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
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Region3
							expect(v.Size.X).to.be.near(out.Size.X, 1)
							expect(v.Size.Y).to.be.near(out.Size.Y, 1)
							expect(v.Size.Z).to.be.near(out.Size.Z, 1)
							expect(v.CFrame.X).to.be.near(out.CFrame.X, 1)
							expect(v.CFrame.Y).to.be.near(out.CFrame.Y, 1)
							expect(v.CFrame.Z).to.be.near(out.CFrame.Z, 1)
							expect(v.CFrame.Rotation.X).to.be.near(out.CFrame.Rotation.X, math.rad(3))
							expect(v.CFrame.Rotation.Y).to.be.near(out.CFrame.Rotation.Y,math.rad(3))
							expect(v.CFrame.Rotation.Z).to.be.near(out.CFrame.Rotation.Z, math.rad(3))
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Region3
							expect(v.Size.X).to.be.near(out.Size.X, 2)
							expect(v.Size.Y).to.be.near(out.Size.Y, 2)
							expect(v.Size.Z).to.be.near(out.Size.Z, 2)
							expect(v.CFrame.X).to.be.near(out.CFrame.X, 2)
							expect(v.CFrame.Y).to.be.near(out.CFrame.Y, 2)
							expect(v.CFrame.Z).to.be.near(out.CFrame.Z, 2)
							expect(v.CFrame.Rotation.X).to.be.near(out.CFrame.Rotation.X, math.rad(360/SHORT_MAX))
							expect(v.CFrame.Rotation.Y).to.be.near(out.CFrame.Rotation.Y, math.rad(360/SHORT_MAX))
							expect(v.CFrame.Rotation.Z).to.be.near(out.CFrame.Rotation.Z, math.rad(360/SHORT_MAX))
						end
					end)
				end)
			end)
			describe("Region3int16", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Region3int16} = {}

				for i=1, SAMPLE_SIZE do
					local min = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local max = rng:NextUnitVector() * rng:NextInteger(-126, 126)
					local v = Region3int16.new(
						Vector3int16.new(min.X, min.Y, min.Z),
						Vector3int16.new(max.X, max.Y, max.Z)
					)
					table.insert(ledger, v)
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3int16.encode(v, true)
							local out = SerializeUtil.Types.Library.Region3int16.decode(encoded, true)
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Min.Z).to.be.equal(out.Min.Z)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
							expect(v.Max.Z).to.be.equal(out.Max.Z)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3int16.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.Region3int16.decode(encoded, true, "n")
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Min.Z).to.be.equal(out.Min.Z)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
							expect(v.Max.Z).to.be.equal(out.Max.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3int16.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.Region3int16.decode(encoded, true, "b")
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Min.Z).to.be.near(out.Min.Z, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
							expect(v.Max.Z).to.be.near(out.Max.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.Region3int16.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.Region3int16.decode(encoded, true, "h")
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Min.Z).to.be.near(out.Min.Z, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
							expect(v.Max.Z).to.be.near(out.Max.Z, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: Region3int16
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Min.Z).to.be.equal(out.Min.Z)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
							expect(v.Max.Z).to.be.equal(out.Max.Z)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: Region3int16
							expect(v.Min.X).to.be.equal(out.Min.X)
							expect(v.Min.Y).to.be.equal(out.Min.Y)
							expect(v.Min.Z).to.be.equal(out.Min.Z)
							expect(v.Max.X).to.be.equal(out.Max.X)
							expect(v.Max.Y).to.be.equal(out.Max.Y)
							expect(v.Max.Z).to.be.equal(out.Max.Z)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: Region3int16
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Min.Z).to.be.near(out.Min.Z, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
							expect(v.Max.Z).to.be.near(out.Max.Z, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: Region3int16
							expect(v.Min.X).to.be.near(out.Min.X, 1)
							expect(v.Min.Y).to.be.near(out.Min.Y, 1)
							expect(v.Min.Z).to.be.near(out.Min.Z, 1)
							expect(v.Max.X).to.be.near(out.Max.X, 1)
							expect(v.Max.Y).to.be.near(out.Max.Y, 1)
							expect(v.Max.Z).to.be.near(out.Max.Z, 1)
						end
					end)
				end)
			end)
			describe("TweenInfo", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: TweenInfo} = {}

				for i=1, SAMPLE_SIZE do
					local v = TweenInfo.new(
						rng:NextNumber(),
						Enum.EasingStyle.Bounce,
						Enum.EasingDirection.InOut,
						rng:NextInteger(1, 4),
						rng:NextNumber() < 0.5,
						rng:NextNumber() * 10
					)
					table.insert(ledger, v)
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.TweenInfo.encode(v, true)
							local out = SerializeUtil.Types.Library.TweenInfo.decode(encoded, true)
							expect(v.DelayTime).to.be.equal(out.DelayTime)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.equal(out.Time)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.TweenInfo.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.TweenInfo.decode(encoded, true, "n")
							expect(v.DelayTime).to.be.equal(out.DelayTime)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.equal(out.Time)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.TweenInfo.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.TweenInfo.decode(encoded, true, "b")
							expect(v.DelayTime).to.be.near(out.DelayTime, 1)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.near(out.Time, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.TweenInfo.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.TweenInfo.decode(encoded, true, "h")
							expect(v.DelayTime).to.be.near(out.DelayTime, 1)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.near(out.Time, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: TweenInfo
							expect(v.DelayTime).to.be.equal(out.DelayTime)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.equal(out.Time)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: TweenInfo
							expect(v.DelayTime).to.be.equal(out.DelayTime)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.equal(out.Time)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: TweenInfo
							expect(v.DelayTime).to.be.near(out.DelayTime, 1)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.near(out.Time, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: TweenInfo
							expect(v.DelayTime).to.be.near(out.DelayTime, 1)
							expect(v.EasingDirection).to.be.equal(out.EasingDirection)
							expect(v.EasingStyle).to.be.equal(out.EasingStyle)
							expect(v.RepeatCount).to.be.equal(out.RepeatCount)
							expect(v.Reverses).to.be.equal(out.Reverses)
							expect(v.Time).to.be.near(out.Time, 1)
						end
					end)
				end)
			end)
			describe("UDim", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: UDim} = {}

				for i=1, SAMPLE_SIZE do
					table.insert(ledger, UDim.new(rng:NextNumber(), rng:NextInteger(10, 126)))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim.encode(v, true)
							local out = SerializeUtil.Types.Library.UDim.decode(encoded, true)
							expect(v.Scale).to.be.equal(out.Scale)
							expect(v.Offset).to.be.equal(out.Offset)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.UDim.decode(encoded, true, "n")
							expect(v.Scale).to.be.equal(out.Scale)
							expect(v.Offset).to.be.equal(out.Offset)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.UDim.decode(encoded, true, "b")
							expect(v.Scale).to.be.near(out.Scale, 1/255)
							expect(v.Offset).to.be.near(out.Offset, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.UDim.decode(encoded, true, "h")
							expect(v.Scale).to.be.near(out.Scale, 1/SHORT_MAX)
							expect(v.Offset).to.be.near(out.Offset, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: UDim
							expect(v.Scale).to.be.equal(out.Scale)
							expect(v.Offset).to.be.equal(out.Offset)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: UDim
							expect(v.Scale).to.be.equal(out.Scale)
							expect(v.Offset).to.be.equal(out.Offset)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: UDim
							expect(v.Scale).to.be.near(out.Scale, 1/255)
							expect(v.Offset).to.be.near(out.Offset, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: UDim
							expect(v.Scale).to.be.near(out.Scale, 1/SHORT_MAX)
							expect(v.Offset).to.be.near(out.Offset, 1)
						end
					end)
				end)
			end)
			describe("UDim2", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: UDim2} = {}

				for i=1, SAMPLE_SIZE do
					table.insert(ledger, UDim2.new(rng:NextNumber(), rng:NextInteger(10, 126), rng:NextNumber(), rng:NextInteger(10, 126)))
				end
				describe("blind", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim2.encode(v, true)
							local out = SerializeUtil.Types.Library.UDim2.decode(encoded, true)
							expect(v.X.Scale).to.be.equal(out.X.Scale)
							expect(v.X.Offset).to.be.equal(out.X.Offset)
							expect(v.Y.Scale).to.be.equal(out.Y.Scale)
							expect(v.Y.Offset).to.be.equal(out.Y.Offset)
						end
					end)

					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim2.encode(v, true, "n")
							local out = SerializeUtil.Types.Library.UDim2.decode(encoded, true, "n")
							expect(v.X.Scale).to.be.equal(out.X.Scale)
							expect(v.X.Offset).to.be.equal(out.X.Offset)
							expect(v.Y.Scale).to.be.equal(out.Y.Scale)
							expect(v.Y.Offset).to.be.equal(out.Y.Offset)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim2.encode(v, true, "b")
							local out = SerializeUtil.Types.Library.UDim2.decode(encoded, true, "b")
							expect(v.X.Scale).to.be.near(out.X.Scale, 1/255)
							expect(v.X.Offset).to.be.near(out.X.Offset, 1)
							expect(v.Y.Scale).to.be.near(out.Y.Scale, 1/255)
							expect(v.Y.Offset).to.be.near(out.Y.Offset, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.Library.UDim2.encode(v, true, "h")
							local out = SerializeUtil.Types.Library.UDim2.decode(encoded, true, "h")
							expect(v.X.Scale).to.be.near(out.X.Scale, 1/SHORT_MAX)
							expect(v.X.Offset).to.be.near(out.X.Offset, 1)
							expect(v.Y.Scale).to.be.near(out.Y.Scale, 1/SHORT_MAX)
							expect(v.Y.Offset).to.be.near(out.Y.Offset, 1)
						end
					end)
				end)
				describe("generic", function()
					it("default", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v)
							local out = SerializeUtil.Types.decode(encoded) :: UDim2
							expect(v.X.Scale).to.be.equal(out.X.Scale)
							expect(v.X.Offset).to.be.equal(out.X.Offset)
							expect(v.Y.Scale).to.be.equal(out.Y.Scale)
							expect(v.Y.Offset).to.be.equal(out.Y.Offset)
						end
					end)
					it("number", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "n")
							local out = SerializeUtil.Types.decode(encoded, "n") :: UDim2
							expect(v.X.Scale).to.be.equal(out.X.Scale)
							expect(v.X.Offset).to.be.equal(out.X.Offset)
							expect(v.Y.Scale).to.be.equal(out.Y.Scale)
							expect(v.Y.Offset).to.be.equal(out.Y.Offset)
						end
					end)
					
					it("byte", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "b")
							local out = SerializeUtil.Types.decode(encoded, "b") :: UDim2
							expect(v.X.Scale).to.be.near(out.X.Scale, 1/255)
							expect(v.X.Offset).to.be.near(out.X.Offset, 1)
							expect(v.Y.Scale).to.be.near(out.Y.Scale, 1/255)
							expect(v.Y.Offset).to.be.near(out.Y.Offset, 1)
						end
					end)
										
					it("short", function()
						for i, v in ipairs(ledger) do
							local encoded = SerializeUtil.Types.encode(v, "h")
							local out = SerializeUtil.Types.decode(encoded, "h") :: UDim2
							expect(v.X.Scale).to.be.near(out.X.Scale, 1/SHORT_MAX)
							expect(v.X.Offset).to.be.near(out.X.Offset, 1)
							expect(v.Y.Scale).to.be.near(out.Y.Scale, 1/SHORT_MAX)
							expect(v.Y.Offset).to.be.near(out.Y.Offset, 1)
						end
					end)
				end)
			end)
			describe("number", function()
				it("blind", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = rng:NextNumber() * rng:NextInteger(-10000, 10000)
						local encoded = SerializeUtil.Types.Library.number.encode(v, true)
						local out = SerializeUtil.Types.Library.number.decode(encoded, true) :: number
						expect(v).to.be.equal(out)
					end
				end)
				it("generic", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = rng:NextNumber() * rng:NextInteger(-10000, 10000)
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: number
						expect(v).to.be.equal(out)
					end
				end)
			end)
			describe("string", function()
				it("blind", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = ""
						for m=1, rng:NextInteger(1, 45) do
							v ..= string.char(rng:NextInteger(48, 90))
						end						
						local encoded = SerializeUtil.Types.Library.string.encode(v, true)
						local out = SerializeUtil.Types.Library.string.decode(encoded, true) :: string
						expect(v).to.be.equal(out)
					end
				end)
				it("generic", function()
					local rng = Random.new(SEED)
					for i=1, SAMPLE_SIZE do
						local v = ""
						for m=1, rng:NextInteger(1, 45) do
							v ..= string.char(rng:NextInteger(48, 90))
						end						
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: string
						expect(v).to.be.equal(out)
					end
				end)
			end)
			describe("boolean", function()
				it("blind", function()
					for i=0, 1 do
						local v = i == 1				
						local encoded = SerializeUtil.Types.Library.boolean.encode(v, true)
						local out = SerializeUtil.Types.Library.boolean.decode(encoded, true) :: boolean
						expect(v).to.be.equal(out)
					end
				end)
				it("generic", function()
					for i=0, 1 do
						local v = i == 1				
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: boolean
						expect(v).to.be.equal(out)
					end
				end)
			end)
			describe("Axes", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Axes} = {}
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
					table.insert(ledger, v)
				end

				it("blind", function()
					for i, v in ipairs(ledger) do
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: Axes
	
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

				it("generic", function()
					for i, v in ipairs(ledger) do
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: Axes
	
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
			end)
			describe("Faces", function()
				local rng = Random.new(SEED)
				local ledger: {[number]: Faces} = {}
				for i=1, SAMPLE_SIZE do
					local axesFaces: {[number]: Enum.NormalId} = {}

					for j, v in ipairs(Enum.NormalId:GetEnumItems()) do
						if rng:NextNumber() < 0.5 then
							table.insert(axesFaces, v)
						end
					end

					local v = Faces.new(unpack(axesFaces))
					table.insert(ledger, v)
				end

				it("blind", function()
					for i, v in ipairs(ledger) do
						local encoded = SerializeUtil.Types.Library.Faces.encode(v, true)
						local out = SerializeUtil.Types.Library.Faces.decode(encoded, true)
	
						expect(v.Back).to.be.equal(out.Back)
						expect(v.Front).to.be.equal(out.Front)
						expect(v.Top).to.be.equal(out.Top)
						expect(v.Bottom).to.be.equal(out.Bottom)
						expect(v.Left).to.be.equal(out.Left)
						expect(v.Right).to.be.equal(out.Right)
					end
				end)

				it("generic", function()
					for i, v in ipairs(ledger) do
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: Faces
	
						expect(v.Back).to.be.equal(out.Back)
						expect(v.Front).to.be.equal(out.Front)
						expect(v.Top).to.be.equal(out.Top)
						expect(v.Bottom).to.be.equal(out.Bottom)
						expect(v.Left).to.be.equal(out.Left)
						expect(v.Right).to.be.equal(out.Right)
					end
				end)
			end)
			-- describe("FloatCurveKey", function()
			-- 	local rng = Random.new(SEED)
			-- 	local ledger: {[number]: FloatCurveKey} = {}

			-- 	for i=1, SAMPLE_SIZE do
			-- 		local v = FloatCurveKey.new(
			-- 			rng:NextNumber(),
			-- 			rng:NextNumber(),
			-- 			Enum.KeyInterpolationMode:GetEnumItems()[rng:NextInteger(1, #Enum.KeyInterpolationMode:GetEnumItems())]
			-- 		)
			-- 		if v.Interpolation == Enum.KeyInterpolationMode.Cubic then
			-- 			v.LeftTangent = rng:NextNumber()
			-- 			v.RightTangent = rng:NextNumber()
			-- 		end
			-- 		table.insert(ledger, v)
			-- 	end
			-- 	describe("blind", function()
			-- 		it("default", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.Library.FloatCurveKey.encode(v, true)
			-- 				local out = SerializeUtil.Types.Library.FloatCurveKey.decode(encoded, true)
			-- 				expect(v.Time).to.be.equal(out.Time)
			-- 				expect(v.Value).to.be.equal(out.Value)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.equal(out.LeftTangent)
			-- 				expect(v.RightTangent).to.be.equal(out.RightTangent)
			-- 			end
			-- 		end)

			-- 		it("number", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.Library.FloatCurveKey.encode(v, true, "n")
			-- 				local out = SerializeUtil.Types.Library.FloatCurveKey.decode(encoded, true, "n")
			-- 				expect(v.Time).to.be.equal(out.Time)
			-- 				expect(v.Value).to.be.equal(out.Value)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.equal(out.LeftTangent)
			-- 				expect(v.RightTangent).to.be.equal(out.RightTangent)
			-- 			end
			-- 		end)
					
			-- 		it("byte", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.Library.FloatCurveKey.encode(v, true, "b")
			-- 				local out = SerializeUtil.Types.Library.FloatCurveKey.decode(encoded, true, "b")
			-- 				expect(v.Time).to.be.near(out.Time, 1/255)
			-- 				expect(v.Value).to.be.near(out.Value, 1)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.near(out.LeftTangent, 1)
			-- 				expect(v.RightTangent).to.be.near(out.RightTangent, 1)
			-- 			end
			-- 		end)
										
			-- 		it("short", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.Library.FloatCurveKey.encode(v, true, "h")
			-- 				local out = SerializeUtil.Types.Library.FloatCurveKey.decode(encoded, true, "h")
			-- 				expect(v.Time).to.be.near(out.Time, 1)
			-- 				expect(v.Value).to.be.near(out.Value, 1)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.near(out.LeftTangent, 1)
			-- 				expect(v.RightTangent).to.be.near(out.RightTangent, 1)

			-- 			end
			-- 		end)
			-- 	end)
			-- 	describe("generic", function()
			-- 		it("default", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.encode(v)
			-- 				local out = SerializeUtil.Types.decode(encoded) :: FloatCurveKey
			-- 				expect(v.Time).to.be.equal(out.Time)
			-- 				expect(v.Value).to.be.equal(out.Value)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.equal(out.LeftTangent)
			-- 				expect(v.RightTangent).to.be.equal(out.RightTangent)
			-- 			end
			-- 		end)
			-- 		it("number", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.encode(v, "n")
			-- 				local out = SerializeUtil.Types.decode(encoded, "n") :: FloatCurveKey
			-- 				expect(v.Time).to.be.equal(out.Time)
			-- 				expect(v.Value).to.be.equal(out.Value)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.equal(out.LeftTangent)
			-- 				expect(v.RightTangent).to.be.equal(out.RightTangent)
			-- 			end
			-- 		end)
					
			-- 		it("byte", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.encode(v, "b")
			-- 				local out = SerializeUtil.Types.decode(encoded, "b") :: FloatCurveKey
			-- 				expect(v.Time).to.be.near(out.Time, 1/255)
			-- 				expect(v.Value).to.be.near(out.Value, 1)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.near(out.LeftTangent, 1)
			-- 				expect(v.RightTangent).to.be.near(out.RightTangent, 1)
			-- 			end
			-- 		end)
										
			-- 		it("short", function()
			-- 			for i, v in ipairs(ledger) do
			-- 				local encoded = SerializeUtil.Types.encode(v, "h")
			-- 				local out = SerializeUtil.Types.decode(encoded, "h") :: FloatCurveKey
			-- 				expect(v.Time).to.be.near(out.Time, 1)
			-- 				expect(v.Value).to.be.near(out.Value, 1)
			-- 				expect(v.Interpolation).to.be.equal(out.Interpolation)
			-- 				expect(v.LeftTangent).to.be.near(out.LeftTangent, 1)
			-- 				expect(v.RightTangent).to.be.near(out.RightTangent, 1)
			-- 			end
			-- 		end)
			-- 	end)
			-- end)		
			describe("Font", function()
				local ledger: {[number]: Font} = {}
				for _, fontFamily in ipairs(Enum.Font:GetEnumItems()) do
					if fontFamily ~= Enum.Font.Unknown then
						for _, fontWeight in ipairs(Enum.FontWeight:GetEnumItems()) do
							for _, fontStyle in ipairs(Enum.FontStyle:GetEnumItems()) do
								for _, isBold in ipairs({true, false}) do
									local v = Font.fromEnum(fontFamily)
									v.Style = fontStyle
									v.Weight = fontWeight
									v.Bold = isBold
									table.insert(ledger, v)
								end
							end
						end
					end
				end
				it("blind", function()
					for i, v in ipairs(ledger) do
						local encoded = SerializeUtil.Types.Library.Font.encode(v, true)
						local out = SerializeUtil.Types.Library.Font.decode(encoded, true) :: Font

						expect(v.Family).to.be.equal(out.Family)
						expect(v.Style).to.be.equal(out.Style)
						expect(v.Weight).to.be.equal(out.Weight)
						expect(v.Bold).to.be.equal(out.Bold)
					end
				end)
				it("generic", function()
					for i, v in ipairs(ledger) do
						local encoded = SerializeUtil.Types.encode(v)
						local out = SerializeUtil.Types.decode(encoded) :: Font

						expect(v.Family).to.be.equal(out.Family)
						expect(v.Style).to.be.equal(out.Style)
						expect(v.Weight).to.be.equal(out.Weight)
						expect(v.Bold).to.be.equal(out.Bold)
					end
				end)
			end)
		end)
	end)
end
