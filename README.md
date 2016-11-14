# lua-yenc

A [yEnc](http://www.yenc.org/) encoder and decoder for Lua 5.1, 5.2, 5.3 and LuaJIT.

## Installation

With LuaRocks:

    $ luarocks install lua-yenc

On Debian, Ubuntu and other apt-based distros:

    # apt-get install dpkg-dev dh-lua 
    $ make debian
    # dpkg -i ../lua-yenc_VERSION.deb

## Usage

### yenc.encode(buf, inlen, linelen, crc)

Encodes the input string *buf* and returns it. *inlen* is the size of the decoded part. Newlines
will be inserted after every *linelen* characters.

If *crc* is a number, both the crc32 of this part and the combined crc32 are also returned.

### yenc.decode(buf, outlen, crc)

Decodes the input string *buf* and returns it. *outlen* is the size of the decoded part.

If *crc* is a number, both the crc32 of this part and the combined crc32 are also returned.

### yenc.crc32(buf, len, crc)

Returns the crc32 checksum of *buf*. If *crc* is provided, it will be used as an initial value.

### yenc.crc32_combine(crc1, crc2, len2)

Returns the combined crc32 checksums of *crc1* and *crc2*. *len2* is the length of the buffer from
which *crc2* was obtained.
