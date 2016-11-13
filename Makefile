PREFIX  = /usr/local
PKGCONF = pkg-config
LUA     = lua
LUAVER  = 5.2
LUAPC   = lua$(LUAVER)

LIBNAME  := yenc.so
LIBDIR   := $(PREFIX)/lib/lua/$(LUAVER)
CPPFLAGS := -Wall -fPIC `$(PKGCONF) --cflags $(LUAPC)`
LDFLAGS  := -shared

.PHONY: all test install debian clean

$(LIBNAME): yenc.c vendor/zlib/crc32.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@ $^

test: yenc.so
	$(LUA) test/yenc.lua

install: $(LIBNAME)
	mkdir -p $(LIBDIR)
	cp $(LIBNAME) $(LIBDIR)

debian:
	dpkg-buildpackage -us -uc

clean:
	$(RM) $(LIBNAME)

