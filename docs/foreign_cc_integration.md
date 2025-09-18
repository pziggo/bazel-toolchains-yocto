# rules_foreign_cc Integration

This toolchain automatically detects and configures `rules_foreign_cc` toolchains using your Yocto SDK build tools, eliminating the 8-10 minute bootstrapping delay.

## Automatic Detection

The toolchain automatically detects these tools in your Yocto SDK:
- **cmake** - `/usr/bin/cmake`
- **ninja** - `/usr/bin/ninja`
- **pkg-config** - `/usr/bin/pkg-config`
- **make** - `/usr/bin/make` or `/usr/bin/gmake`

If cmake and at least one build system (ninja or make) plus pkg-config are available, the toolchain will automatically register a `rules_foreign_cc` toolchain.

## Usage

### 1. Add rules_foreign_cc to your MODULE.bazel

```starlark
bazel_dep(name = "rules_foreign_cc", version = "0.11.1")

# Your Yocto toolchain setup
local_yocto_toolchain(name = "yocto_aarch64")
```

### 2. Register the auto-detected foreign_cc toolchain

```starlark
# Register the foreign_cc toolchain provided by your Yocto SDK
register_toolchains("@yocto_aarch64//:yocto_foreign_cc_toolchain")
```

### 3. Use in your CMake rules

```starlark
load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

cmake(
    name = "your_project",
    # The toolchain will automatically use your SDK's cmake, ninja, and pkg-config
    lib_source = ":your_cmake_project_sources",
    out_static_libs = ["libyour_project.a"],
)
```

## Benefits

✅ **No 8-10 minute bootstrap delay** - Uses SDK tools directly
✅ **Perfect compatibility** - Tools match your cross-compilation environment
✅ **Zero configuration** - Works automatically when tools are detected
✅ **Version consistency** - Same tool versions across all builds

## Debug Output

When the toolchain is initialized, you'll see detection output:

```
=== FOREIGN_CC TOOLS DETECTION ===
  cmake available: True
  ninja available: True
  pkg-config available: True
  make available: False
  foreign_cc enabled: True
```

## Manual Override

If you need to disable the auto-detection or prefer manual configuration, you can still use the traditional `rules_foreign_cc` configuration methods in your project.

## Troubleshooting

If foreign_cc integration isn't working:

1. **Check the detection output** - Look for the debug messages during toolchain setup
2. **Verify tools exist** - Check `/opt/your/sdk/sysroots/x86_64-pokysdk-linux/usr/bin/` for cmake, ninja, pkg-config
3. **Check toolchain registration** - Ensure you've registered the foreign_cc toolchain in your MODULE.bazel
4. **Version compatibility** - Ensure your `rules_foreign_cc` version supports the native_tools_toolchain API (>= 0.10.0)

