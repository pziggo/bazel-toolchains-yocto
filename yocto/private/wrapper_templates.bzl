""" Template makro for root BUILD file """


_script_header = """\
#!/bin/bash --norc

"""

_ld_exec_wrapper = """\
# Resolve absolute path relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
exec "$REPO_ROOT/{native_sysroot}"/lib/ld-linux-x86-64.so.2 \
  --inhibit-cache --inhibit-rpath '' \
  --library-path "$REPO_ROOT/{native_sysroot}/lib:$REPO_ROOT/{native_sysroot}/usr/lib" \
"""

_wrapper_for_ld_template = _script_header + _ld_exec_wrapper + """\
  "$@"
"""

def WRAPPER_for_ld(path, config):
    """Emits a wrapper file for ld inside the SDK tree.

    Args:
        path (str): base path of the sysroots
        config (struct): Yocto SDK configuration

    Returns:
        str: The contents for the wrapper file
    """
    return _wrapper_for_ld_template.format(
        native_sysroot = config.native_sysroot,
    )

_wrapper_for_clang =  _script_header + _ld_exec_wrapper + """\
  "$REPO_ROOT/{native_sysroot}/usr/bin/clang" \
  "$@"
"""

def WRAPPER_for_clang(name, path, config):
    """Emits a wrapper file for clang inside the SDK tree.

    Args:
        name (str): Name of the tool
        path (str): base path of the sysroots
        config (struct): Yocto SDK configuration

    Returns:
        str: The contents for the wrapper file
    """
    return _wrapper_for_clang.format(
        name = name,
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )

_wrapper_for_compiler_template = _script_header + """\
GCC_EXEC_PREFIX=$(dirname "$0")

""" + _ld_exec_wrapper + """\
  "$REPO_ROOT/{native_sysroot}/usr/bin/{target_prefix}/{name}" \
  -B "$GCC_EXEC_PREFIX" \
  -wrapper "$GCC_EXEC_PREFIX"/ld-linux-x86-64.so.2 \
  "$@"
"""

def WRAPPER_for_compiler(name, path, config):
    """Emits a wrapper file for the compilers inside the SDK tree.

    Args:
        name (str): Name of the tool
        path (str): base path of the sysroots
        config (struct): Yocto SDK configuration

    Returns:
        str: The contents for the wrapper file
    """
    return _wrapper_for_compiler_template.format(
        name = name,
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )

_wrapper_for_generic_tool_template = _script_header + _ld_exec_wrapper + """\
  "$REPO_ROOT/{native_sysroot}/usr/bin/{target_prefix}/{name}" \
  "$@"
"""

def WRAPPER_for_generic_tool(name, path, config):
    """Emits a wrapper file for a generic tool inside the SDK tree.

    Args:
        name (str): Name of the tool
        path (str): base path of the sysroots
        config (struct): Yocto SDK configuration

    Returns:
        str: The contents for the wrapper file
    """
    return _wrapper_for_generic_tool_template.format(
        name = name,
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )

_wrapper_for_real_ld_template = _script_header + _ld_exec_wrapper + """\
  "$REPO_ROOT/{native_sysroot}"/usr/bin/{target_prefix}/{target_prefix}-ld \
  "$@"
"""

def WRAPPER_for_real_ld(path, config):
    """Emits a wrapper file for a the real ld inside the SDK tree.

    Args:
        path (str): base path of the sysroots
        config (struct): Yocto SDK configuration

    Returns:
        str: The contents for the wrapper file
    """
    return _wrapper_for_real_ld_template.format(
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )
