# Dagon Sandbox
Demo application for [Dagon](https://github.com/gecko0307/dagon) 0.11.0.

[![Screenshot](https://gamedev.timurgafarov.ru/wp-content/uploads/2020/01/forest2-1024x617.jpg)](https://gamedev.timurgafarov.ru/wp-content/uploads/2020/01/forest2-1024x617.jpg)

## Building
Run `dub build` as usual. It is recommended to use LDC and ` --build=release-nodounds` to get the best performance. On Linux and other non-Windows systems you should install Freetype and [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear) using your system's package manager. The demo can work without them, but in that case UI will not be available. On Linux `nuklear.so` should be available in `$LD_LIBRARY_PATH` or in `/usr/local/lib`.
