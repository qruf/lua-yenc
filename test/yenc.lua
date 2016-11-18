package.cpath  = "./?.so"
local assert   = require "test.assert"
local yenc     = require "yenc"

local fd_src = io.open("test/test.bin")
local src = fd_src:read("*a")
local fd_ref = io.open("test/test.bin.ync")
local ref = fd_ref:read("*a")
fd_src:close()
fd_ref:close()

-- yenc.crc32
local crc_ref = yenc.crc32(src, 16384)
assert.equal(crc_ref, 0x212D3568)

-- yenc.crc32_combine
local crc_cmb = yenc.crc32_combine(crc_ref, crc_ref, 16384)
assert.equal(crc_cmb, 0xD612F035)

-- yenc.encode
local enc, crc_enc = yenc.encode(src, 16384, 128, 0)
if arg[1] == "-o" then
    io.write(enc)
end
assert(enc == ref)
assert.equal(crc_enc, 0x212D3568)

enc, crc_enc, crc_cmb = yenc.encode(src, 16384, 128, crc_enc)
assert(enc == ref)
assert.equal(crc_enc, 0x212D3568)
assert.equal(crc_cmb, 0xD612F035)

-- yenc.decode
local dec, crc_dec = yenc.decode(enc, 16384, 0)
assert(src == dec)
assert.equal(crc_dec, 0x212D3568)

