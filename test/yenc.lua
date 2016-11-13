local assert   = require "test.assert"
local yenc     = require "yenc"

-- yenc.crc32
local crc = yenc.crc32("old woman killed by little glass planet", 39)
assert.equal(crc, 0x57F9E257)

-- yenc.crc32_combine
local crc1, crc2 = yenc.crc32("old woman killed by ", 20), yenc.crc32("little glass planet", 19)
local crcc = yenc.crc32_combine(crc1, crc2, 19)
assert.equal(crc, 0x57F9E257)

-- yenc.encode
local fd_src = io.open("test/test.bin")
local src = fd_src:read("*a")
local fd_ync = io.open("test/test.bin.ync")
local ync = fd_ync:read("*a")
fd_src:close()
fd_ync:close()
local crc_src = yenc.crc32(src, 16384)
assert.equal(crc_src, 0x212D3568)
local enc, crc_enc = yenc.encode(src, 16384, 128, 0)
assert(enc == ync)
assert.equal(crc_src, crc_enc)

-- yenc.decode
local dec, crc_dec = yenc.decode(enc, 16384, 0)
assert(src == dec)
assert.equal(crc_src, crc_dec)

