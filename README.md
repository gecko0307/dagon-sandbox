# Dagon Editor
Work-in-progress scene editor for [Dagon](https://github.com/gecko0307/dagon). Based on [NG](https://github.com/gecko0307/dagon/tree/dagon-ng) branch of the engine. Editor features are not fully implemented yet, it's more of a demo sandbox for Dagon NG at the moment.

[![Screenshot1](https://1.bp.blogspot.com/-qC2fIlkQA7E/XO2335jW2iI/AAAAAAAAD8I/8fqMNFd02UA74qDgkJUp0HTj_5qNyAyvQCLcBGAs/s1600/2019-05-29%2B01_20_42-Dagon%2BNG.jpg)](https://1.bp.blogspot.com/-qC2fIlkQA7E/XO2335jW2iI/AAAAAAAAD8I/8fqMNFd02UA74qDgkJUp0HTj_5qNyAyvQCLcBGAs/s1600/2019-05-29%2B01_20_42-Dagon%2BNG.jpg)

## Building
Run `dub build` as usual. It is recommended to use LDC and ` --build=release-nodounds` to get the best performance.

You can also build with [mimalloc](https://github.com/microsoft/mimalloc) instead of default system allocator: `dub build --conf=mimalloc`.
