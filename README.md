# Dagon Sandbox
Work-in-progress scene editor for [Dagon](https://github.com/gecko0307/dagon). Editor features are not fully implemented yet, it's more of a demo sandbox for upcoming Dagon 0.11 at the moment.

[![Screenshot2](https://1.bp.blogspot.com/-IaDVtXOtJZw/XWG0FeJPFuI/AAAAAAAAEHQ/lk9WdRFGlegSSt0hnNLFEdGw_6XyrS7NgCLcBGAs/s1600/ng-terrain-bushes.jpg)](https://1.bp.blogspot.com/-IaDVtXOtJZw/XWG0FeJPFuI/AAAAAAAAEHQ/lk9WdRFGlegSSt0hnNLFEdGw_6XyrS7NgCLcBGAs/s1600/ng-terrain-bushes.jpg)

## Building
Run `dub build` as usual. It is recommended to use LDC and ` --build=release-nodounds` to get the best performance.

You can also build with [mimalloc](https://github.com/microsoft/mimalloc) instead of default system allocator: `dub build --conf=mimalloc`.
