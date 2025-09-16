# X-PlaneSceneryLibrary — Agent Instructions

Goal: Get productive fast in this C++20 library that parses X‑Plane scenery (library.txt, obj8) via a virtual file system and region/season selection.

## Big picture
- Single library target XPSceneryLib (no app). Code in `xplib/`, wired by `cmake/xplib.cmake`.
- Namespaces: `XPLibrary` (VFS, regions, seasons, parsing) and `XPAsset` (asset models like obj8).
- Flow: `VirtualFileSystem::LoadFileSystem(xpRoot, currentPackage, customPacks)` → crawl real assets and parse all `library.txt` (custom packs in priority + default scenery). Commands build `Definition`s keyed by virtual paths, with `RegionalDefinitions` and weighted `DefinitionOptions`.

## Where to look/edit
- VFS and parser: `xplib/include/XPLibrarySystem.h`, `xplib/src/XPLibrarySystem.cpp` (commands: EXPORT, EXPORT_BACKUP, EXPORT_RATIO, EXPORT_EXCLUDE, REGION_*, EXPORT_*_SEASON).
- Path/selection model: `xplib/include/XPLibraryPath.h` (DefinitionPath, DefinitionOptions, Region, RegionalDefinitions, Definition; seasons like `'s','w','f','p','d'`).
- Asset parsing: `xplib/include/XPObj.h`, `xplib/src/XPObj.cpp` (vertices/indices/draw calls; texture directives; uses `XPLayerGroups`).
- Layer groups: `xplib/include/XPLayerGroups.h|.cpp` (Resolve group+offset ↔ vertical order).
- Tokenization utils: `xplib/include/TextUtils.h`, `xplib/src/TextUtils.cpp`.

## Conventions and behaviors
- C++20; MSVC-friendly flags (`/utf-8`, UNICODE, `_CRT_SECURE_NO_WARNINGS`). No in‑source builds (CMake errors out).
- Includes use repo-root prefix: `<xplib/include/...>`.
- Region selection uses bbox check + optional conditions; region map lives inside `VirtualFileSystem`.
- Seasons: single-char tags; selection falls back: seasonal → default → backup.
- Weighted choice: `DefinitionOptions::AddOption(path, ratio)` and `GetRandomOption()`.
- Real asset ingestion: scanned extensions (from `XPLibrarySystem.cpp`) → `.lin, .pol, .str, .ter, .net, .obj, .agb, .ags, .agp, .bch, .fac, .for`. To add more, update the `vctXPExtensions` list.
- Textures: `.dds`/`.png` are commonly referenced by assets (e.g., OBJ, POL) but are not ingested as primary assets.

## Build and dev
- Windows one-shot: run `SetupProject.bat` (creates `build/`, logs to `CMake_Gen.log`, generates VS solution).
- Manual: out-of-source CMake; VS generator or Ninja (see `CMakeSettings.json` → `out/build/x64-{Config}`).
- Pre-build (Windows/MSVC): `scripts/increment_xplib_build.py` bumps `xplib/config/resource.h` (needs Python 3 on PATH).
- Outputs (top level): `bin/{Config}`; tests are present but disabled in `CMakeLists.txt`.

## Minimal usage example
```cpp
XPLibrary::VirtualFileSystem vfs;
vfs.LoadFileSystem(xpRoot, currentPkg, customPacks);
// auto def = vfs.GetDefinition("lib/objects/house.obj");
// auto real = def.GetPath(/* vfs regions */, 39.85, -104.67, XPLibrary::SEASON_SUMMER);
```

## Extending safely
- New library.txt command: add a case in `XPLibrarySystem.cpp`; tokenize with `TextUtils`; use `DefinitionPath::SetPath`, `GetRegionalDefinitionIdx`, `DefinitionOptions`.
- New asset type: derive from `XPAsset::Asset`, add a parser next to `XPObj.cpp`.
- Maintain layer ordering via `XPLayerGroups::Resolve(group, offset)`.

## Integration
- vcpkg toolchain auto-detected at `dependency/vcpkg/...` if present; optional.
- `XP_SCENERY_LIB_INSTALL` enables install/export (`XPSceneryLib::XPSceneryLib`).

## Formats and references
- Official X‑Plane format specs relevant to supported extensions:
	- NET (.net): https://developer.x-plane.com/article/vector-network-net-file-format-specification/
	- LIBRARY.TXT: https://developer.x-plane.com/article/library-library-txt-file-format-specification/
	- LIN (.lin): https://developer.x-plane.com/article/painted-line-lin-file-format-specification/
	- TER (.ter): https://developer.x-plane.com/article/terrain-type-ter-file-format-specification/
	- FAC (.fac): https://developer.x-plane.com/article/x-plane-10-facade-fac-file-format-specification/
	- POL (.pol): https://developer.x-plane.com/article/draped-polygon-polfac-file-format-specification/
	- STR (.str): https://developer.x-plane.com/article/object-string-str-file-format-specification/
	- AGS (.ags): https://developer.x-plane.com/article/autogen-string-ags-file-format-specification/
	- AGB (.agb): https://developer.x-plane.com/article/autogen-block-agb-file-format-specification/
	- AGP (.agp): https://developer.x-plane.com/article/x-plane-10-autogen-scenery-file-format/
	- FOR (.for): https://developer.x-plane.com/article/forest-for-file-format-specification/

---
