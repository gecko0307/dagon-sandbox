/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
*/

module bindbc.mimalloc;

import bindbc.loader;

enum MimallocSupport {
    noLibrary,
    badLibrary,
    mimalloc105
}

extern(C) @nogc nothrow
{
    alias da_mi_malloc = void* function(size_t size);
    alias da_mi_calloc = void* function(size_t count, size_t size);
    alias da_mi_realloc = void* function(void* p, size_t newsize);
    alias da_mi_expand = void* function(void* p, size_t newsize);
    alias da_mi_free = void function(void* p);
    alias da_mi_strdup = char* function(const char* s);
    alias da_mi_strndup = char* function(const char* s, size_t n);
    alias da_mi_realpath = char* function(const char* fname, char* resolved_name);
}

__gshared
{
    da_mi_malloc mi_malloc;
    da_mi_calloc mi_calloc;
    da_mi_realloc mi_realloc;
    da_mi_expand mi_expand;
    da_mi_free mi_free;
    da_mi_strdup mi_strdup;
    da_mi_strndup mi_strndup;
    da_mi_realpath mi_realpath;
}

private
{
    SharedLib lib;
    MimallocSupport loadedVersion;
}

void unloadMimalloc()
{
    if (lib != invalidHandle)
    {
        lib.unload();
    }
}

MimallocSupport loadedMimallocVersion() { return loadedVersion; }
bool isMimallocLoaded() { return lib != invalidHandle; }

MimallocSupport loadMimalloc()
{
    version(Windows)
    {
        const(char)[][2] libNames =
        [
            "mimalloc.dll",
            "mimalloc-override.dll"
        ];
    }
    else version(OSX)
    {
        const(char)[][1] libNames =
        [
            "mimalloc.dylib"
        ];
    }
    else version(Posix)
    {
        const(char)[][2] libNames =
        [
            "libmimalloc.so.6",
            "libmimalloc.so"
        ];
    }
    else static assert(0, "mimalloc is not yet supported on this platform.");

    MimallocSupport ret;
    foreach(name; libNames)
    {
        ret = loadMimalloc(name.ptr);
        if (ret != MimallocSupport.noLibrary)
            break;
    }
    return ret;
}

MimallocSupport loadMimalloc(const(char)* libName)
{
    lib = load(libName);
    if(lib == invalidHandle)
    {
        return MimallocSupport.noLibrary;
    }

    auto errCount = errorCount();
    loadedVersion = MimallocSupport.badLibrary;

    lib.bindSymbol(cast(void**)&mi_malloc, "mi_malloc");
    lib.bindSymbol(cast(void**)&mi_calloc, "mi_calloc");
    lib.bindSymbol(cast(void**)&mi_realloc, "mi_realloc");
    lib.bindSymbol(cast(void**)&mi_expand, "mi_expand");
    lib.bindSymbol(cast(void**)&mi_free, "mi_free");
    lib.bindSymbol(cast(void**)&mi_strdup, "mi_strdup");
    lib.bindSymbol(cast(void**)&mi_strndup, "mi_strndup");
    lib.bindSymbol(cast(void**)&mi_realpath, "mi_realpath");

    loadedVersion = MimallocSupport.mimalloc105;

    if (errorCount() != errCount)
        return MimallocSupport.badLibrary;

    return loadedVersion;
}
