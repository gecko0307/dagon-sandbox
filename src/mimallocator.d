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

module mimallocator;

import core.exception;
import std.algorithm.comparison;
import bindbc.mimalloc;
import dlib.memory.allocator;

class Mimallocator: Allocator
{
    void[] allocate(size_t size)
    {
        if (!size)
        {
           return null;
        }
        auto p = mi_malloc(size);

        if (!p)
        {
           onOutOfMemoryError();
        }
        return p[0..size];
    }

    bool deallocate(void[] p)
    {
        if (p !is null)
        {
            mi_free(p.ptr);
        }
        return true;
    }

    bool reallocate(ref void[] p, size_t size)
    {
        if (!size)
        {
            deallocate(p);
            p = null;
            return true;
        }
        else if (p is null)
        {
            p = allocate(size);
            return true;
        }
        auto r = mi_realloc(p.ptr, size);

        if (!r)
        {
            onOutOfMemoryError();
        }
        p = r[0..size];

        return true;
    }

    @property immutable(uint) alignment() const
    {
        return cast(uint) max(double.alignof, real.alignof);
    }

    static @property Mimallocator instance() @nogc nothrow
    {
        if (instance_ is null)
        {
            immutable size = __traits(classInstanceSize, Mimallocator);
            void* p = mi_malloc(size);

            if (p is null)
            {
                onOutOfMemoryError();
            }
            p[0..size] = typeid(Mimallocator).initializer[];
            instance_ = cast(Mimallocator) p[0..size].ptr;
        }
        return instance_;
    }

    private static __gshared Mimallocator instance_;
}
