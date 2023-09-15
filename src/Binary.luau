--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local HEX_TO_BIN = {
	["0"] = "0000",
	["1"] = "0001",
	["2"] = "0010",
	["3"] = "0011",
	["4"] = "0100",
	["5"] = "0101",
	["6"] = "0110",
	["7"] = "0111",
	["8"] = "1000",
	["9"] = "1001",
	["A"] = "1010",
	["B"] = "1011",
	["C"] = "1100",
	["D"] = "1101",
	["E"] = "1110",
	["F"] = "1111",
}
local BIN_TO_HEX: {[string]: string} = {}
for k, v in pairs(HEX_TO_BIN) do
	BIN_TO_HEX[v] = k
end

-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

function Util.fromHex(bitString: string): string
	local hex: string = ""
	local sets = bitString:len()/4
	assert(sets%4 == 0, `bitString isn't a multiple of 4: {bitString}`)
	for i=1, sets do
		local key = bitString:sub(1+((i-1)*4),1+(i*4))
		assert(BIN_TO_HEX[key], `bad binaryString key "{key}" from binaryString "{bitString}"`)
		hex ..= BIN_TO_HEX[key]
	end
	return hex
end

function Util.toHex(hex: string): string
	local bitString: string = ""
	for i=1, hex:len() do
		local key = hex:sub(i,i):upper()
		assert(HEX_TO_BIN[key], `bad hex key "{key}" from hex "{hex}"`)
		bitString ..= HEX_TO_BIN[key]
	end
	return bitString
end


function Util.fromBinaryStringToBitArray(binaryString: string): {[number]: boolean}
	local out: {[number]: boolean} = {}

	for i=1, binaryString:len() do
		local char = binaryString:sub(i,i)
		if char == "0" then
			out[i] = false
		elseif char == "1" then
			out[i] = true
		else
			error(`bad character "{char}" at index {i} in binaryString {binaryString}`)
		end
	end

	return out
end

function Util.fromBitArrayToBinaryString(bitArray: {[number]: boolean}): string
	local out = ""
	for i, v in ipairs(bitArray) do
		if v == true then
			out..="1"
		else
			out..="0"
		end
	end
	return out
end

return Util