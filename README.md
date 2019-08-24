# Dagon Editor
Work-in-progress scene editor for [Dagon](https://github.com/gecko0307/dagon). Based on [NG](https://github.com/gecko0307/dagon/tree/dagon-ng) branch of the engine. Editor features are not fully implemented yet, it's more of a demo sandbox for Dagon NG at the moment.

[![Screenshot1](https://1.bp.blogspot.com/-IaDVtXOtJZw/XWG0FeJPFuI/AAAAAAAAEHQ/lk9WdRFGlegSSt0hnNLFEdGw_6XyrS7NgCLcBGAs/s1600/ng-terrain-bushes.jpg)

## Building
Run `dub build` as usual. It is recommended to use LDC and ` --build=release-nodounds` to get the best performance.

You can also build with [mimalloc](https://github.com/microsoft/mimalloc) instead of default system allocator: `dub build --conf=mimalloc`.
