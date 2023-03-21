"""Unit tests for starlark helpers
See https://bazel.build/rules/testing#testing-starlark-utilities
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//yocto/private:common_utils.bzl",
    "format_command_options",
    "relativize_sysroot_path",
)

def _format_command_options_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, ["cmd", "arg1"], format_command_options("cmd arg1"))
    asserts.equals(env, ["cmd", "arg1"], format_command_options("cmd    arg1"))
    asserts.equals(env, ["cmd", "arg1"], format_command_options("\"cmd arg1\""))
    asserts.equals(env, ["cmd", "arg1"], format_command_options("\"cmd\" \"arg1\""))
    asserts.equals(env, ["cmd", "arg1"], format_command_options("\"cmd\" \"\" \"arg1\""))

    asserts.equals(env, ["arg1", "arg2"], format_command_options("cmd arg1 arg2", True))
    asserts.equals(env, ["arg1", "arg2"], format_command_options("   cmd arg1 arg2", True))
    asserts.equals(env, ["arg1", "arg2"], format_command_options("\"cmd arg1\" arg2", True))

    return unittest.end(env)

def _relativize_sysroot_path_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        "base/sysroots/a",
        relativize_sysroot_path(
            "repository",
            "/bazel/outputBase/external/repository/base",
            "/path/to/base/sysroots/a",
        ),
    )
    asserts.equals(
        env,
        "sysroots/a",
        relativize_sysroot_path(
            "repository",
            "/bazel/outputBase/external/repository",
            "/bazel/outputBase/external/repository/sysroots/a",
        ),
    )
    return unittest.end(env)

# The unittest library requires that we export the test cases as named test rules,
# but their names are arbitrary and don't appear anywhere.
_t0_test = unittest.make(_format_command_options_test_impl)
_t1_test = unittest.make(_relativize_sysroot_path_test_impl)

def common_utils_test_suite(name):
    unittest.suite(name, _t0_test, _t1_test)
