/*
 * Copyright (c) 2016 qruf at b23 dot be
 * 
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdlib.h>
#include <stdint.h> 
#include <lua.h>
#include <lauxlib.h>
#include "vendor/zlib/zlib.h"

#if LUA_VERSION_NUM > 501
#define REGISTER(L, idx) luaL_setfuncs(L, idx, 0)
#else
#define REGISTER(L, idx) luaL_register(L, 0, idx)
#define lua_rawlen lua_objlen
#endif

#define ESCAPE_ALL(c) (c == 0x00 || c == 0x0A || c == 0x0D || c == 0x3D)
#define ESCAPE_BOL(c) (c == 0x09 || c == 0x20 || c == 0x2E)
#define ESCAPE_EOL(c) (c == 0x09 || c == 0x20)
#define ESCAPE(c,p,l) (ESCAPE_ALL(c) || (p == 0 && ESCAPE_BOL(c)) || (p + 1 >= l && ESCAPE_EOL(c)))

static int l_encode(lua_State * L) {
    size_t buflen = luaL_checkinteger(L, 2);
    const uint8_t * buf = luaL_checklstring(L, 1, &buflen);
    size_t linelen = luaL_checkinteger(L, 3);
    size_t linepos = 0;
    size_t i = 0;
    struct luaL_Buffer out;
    luaL_buffinit(L, &out);

    do {
        uint8_t chr = *(buf + i) + 0x2A;
        if (ESCAPE(chr, linepos, linelen)) {
            chr += 0x40;
            luaL_addchar(&out, '=');
            linepos++;
        }
        luaL_addchar(&out, chr);
        linepos++;
        if (linepos >= linelen || i == buflen - 1) {
            luaL_addlstring(&out, "\r\n", 2);
            linepos = 0;
        }
    } while (++i < buflen);

    luaL_pushresult(&out);

    if (lua_type(L, 4) == LUA_TNUMBER) {
        unsigned long icrc = lua_tointeger(L, 4);
        unsigned long ocrc = crc32(0, buf, buflen);
        lua_pushnumber(L, ocrc);
        lua_pushnumber(L, crc32_combine(icrc, ocrc, buflen));
        return 3;
    }

    return 1;
}

static int l_decode(lua_State * L) {
    const uint8_t * ibuf = luaL_checkstring(L, 1);
    size_t buflen = lua_rawlen(L, 1);
    size_t outlen = luaL_checkinteger(L, 2);
    uint8_t * out = malloc(sizeof(uint8_t) * outlen);
    uint8_t * outp = out;

    while (buflen--) {
        uint8_t chr = *(ibuf++);
        switch (chr) {
            case '\r': case '\n':
                continue;
            case '=':
                buflen--;
                chr = *(ibuf++) - 0x40;
        }
        *(outp++) = chr - 0x2A;
    }

    lua_pushlstring(L, out, outlen);

    if (lua_type(L, 3) == LUA_TNUMBER) {
        unsigned long icrc = lua_tointeger(L, 4);
        unsigned long ocrc = crc32(0, out, outlen);
        lua_pushnumber(L, ocrc);
        lua_pushnumber(L, crc32_combine(icrc, ocrc, outlen));
        free(out);
        return 3;
    }

    free(out);
    return 1;
}

static int l_crc32(lua_State * L) {
    size_t len = luaL_checkinteger(L, 2);
    const Bytef * buf = luaL_checklstring(L, 1, &len);
    uLong crc = luaL_optinteger(L, 3, 0);
    uLong out = crc32(crc, buf, len);
    lua_pushnumber(L, out);
    return 1;
}

static int l_crc32_combine(lua_State * L) {
    uLong crc1 = luaL_checkinteger(L, 1);
    uLong crc2 = luaL_checkinteger(L, 2);
    z_off_t len = luaL_checkinteger(L, 3);
    uLong out = crc32_combine(crc1, crc2, len);
    lua_pushnumber(L, out);
    return 1;
}

int luaopen_yenc(lua_State * L) {
    static const luaL_Reg yenc[] = {
        { "encode", l_encode },
        { "decode", l_decode },
        { "crc32", l_crc32 },
        { "crc32_combine", l_crc32_combine },
        { 0, 0 }
    };
    lua_newtable(L);
    REGISTER(L, yenc);
    return 1;
}
