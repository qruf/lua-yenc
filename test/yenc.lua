local assert   = require "test.assert"
local yenc     = require "yenc"

-- yenc.crc32
local crc = yenc.crc32("old woman killed by little glass planet", 39)
assert.equal(crc, 1475994199)

-- yenc.crc32_combine
local crc1, crc2 = yenc.crc32("old woman killed by ", 20), yenc.crc32("little glass planet", 19)
local crcc = yenc.crc32_combine(crc1, crc2, 19)
assert.equal(crc, 1475994199)

-- yenc.encode
local fd = io.open("test/test.bin")
local src = fd:read("*a")
local crc_src = yenc.crc32(src, 16384)
assert.equal(crc_src, 556610920)
local enc, crc_enc = yenc.encode(src, 16384, 128, 0)
assert.equal(crc_src, crc_enc)

-- yenc.decode
local dec, crc_dec = yenc.decode(enc, 16384, 0)
assert.equal(crc_src, crc_dec)

