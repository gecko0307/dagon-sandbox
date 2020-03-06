# Dagon Sandbox
Demo application for upcoming [Dagon](https://github.com/gecko0307/dagon) 0.11.

[![Screenshot2](https://dlanggamedev.xtreme3d.ru/wp-content/uploads/2020/01/snow2.jpg)](https://dlanggamedev.xtreme3d.ru/wp-content/uploads/2020/01/snow2.jpg)

## Building
Run `dub build` as usual. It is recommended to use LDC and ` --build=release-nodounds` to get the best performance. On Linux and other non-Windows systems you should install Freetype and [Nuklear](https://github.com/vurtun/nuklear) using your system's package manager. The demo can work without them, but in that case UI will not be available. On Linux `nuklear.so` should be available in `$LD_LIBRARY_PATH` or in `/usr/local/lib`.
