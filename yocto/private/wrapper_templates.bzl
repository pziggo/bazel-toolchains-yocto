""" Template makro for root BUILD file """

_script_header = """\
#!/bin/bash --norc

"""

_ld_exec_wrapper = """\
exec "{path}/{native_sysroot}"/lib/ld-linux-x86-64.so.2 \
  --inhibit-cache --inhibit-rpath '' \
  --library-path "{path}/{native_sysroot}/lib:{path}/{native_sysroot}/usr/lib" \
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
        path = path,
        native_sysroot = config.native_sysroot,
    )

_wrapper_for_compiler_template = _script_header + """\
GCC_EXEC_PREFIX=$(dirname "$0")

""" + _ld_exec_wrapper + """\
  "{path}/{native_sysroot}/usr/bin/{target_prefix}/{name}" \
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
        path = path,
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )

_wrapper_for_generic_tool_template = _script_header + _ld_exec_wrapper + """\
  "{path}/{native_sysroot}/usr/bin/{target_prefix}/{name}" \
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
        path = path,
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )

_wrapper_for_real_ld_template = _script_header + _ld_exec_wrapper + """\
  "{path}/{native_sysroot}"/usr/bin/{target_prefix}/{target_prefix}-ld \
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
        path = path,
        native_sysroot = config.native_sysroot,
        target_prefix = config.target_prefix,
    )
