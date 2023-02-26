"""Unit tests for starlark helpers
See https://bazel.build/rules/testing#testing-starlark-utilities
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//yocto/private:common_utils.bzl", "format_command_options")

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

# The unittest library requires that we export the test cases as named test rules,
# but their names are arbitrary and don't appear anywhere.
_t0_test = unittest.make(_format_command_options_test_impl)

def common_utils_test_suite(name):
    unittest.suite(name, _t0_test)
