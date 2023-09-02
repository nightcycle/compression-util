--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
local HttpService = game:GetService("HttpService")
-- Packages
-- Modules
-- Types
-- Constants
local SEED = tick()
local BIG = 10000000000
local ARRAY_LENGTH = 2000
local ARRAY_COUNT = 30
-- Variables
-- References

-- Class
return function()
	describe("serialize-util", function()
		local SerializeUtil = require(script.Parent)

		describe("encode-array", function()
		
			local function testFloatArray(test: {[number]: {[number]: number}})

				local encodedTest: {[number]: string?} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeFloatArray(array)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, array in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeFloatArray(array)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testIntegerArray(test: {[number]: {[number]: number}})
				local encodedTest: {[number]: string?} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeIntegerArray(array)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, array in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeIntegerArray(array)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			local function testDoubleArray(test: {[number]: {[number]: number}})
				local encodedTest: {[number]: string?} = {}
				for i, array in ipairs(test) do
					encodedTest[i] = SerializeUtil.encodeDoubleArray(array)
				end

				local decodeTest: {[number]: {[number]: number}} = {}
				for i, array in ipairs(encodedTest) do
					decodeTest[i] = SerializeUtil.decodeDoubleArray(array)
				end

				for i, v in ipairs(decodeTest) do
					expect(HttpService:JSONEncode(v)).to.be.equal(HttpService:JSONEncode(test[i]))
				end
			end

			it("float", function()
				local rng = Random.new(SEED)

				local test: {[number]: {[number]: number}} = {}
				for i=1, ARRAY_COUNT do
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
				for i=1, ARRAY_COUNT do
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
				for i=1, ARRAY_COUNT do
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
		end)
	end)
end
