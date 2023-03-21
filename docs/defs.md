<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Macros for downloading yocto toolchains

<a id="http_yocto_toolchain_archive"></a>

## http_yocto_toolchain_archive

<pre>
http_yocto_toolchain_archive(<a href="#http_yocto_toolchain_archive-name">name</a>, <a href="#http_yocto_toolchain_archive-environment_setup">environment_setup</a>, <a href="#http_yocto_toolchain_archive-sdk_installer">sdk_installer</a>, <a href="#http_yocto_toolchain_archive-build_file">build_file</a>, <a href="#http_yocto_toolchain_archive-build_file_content">build_file_content</a>,
                             <a href="#http_yocto_toolchain_archive-kwargs">kwargs</a>)
</pre>

Download archived toolchain script

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="http_yocto_toolchain_archive-name"></a>name |  Name of the final toolchain repository   |  none |
| <a id="http_yocto_toolchain_archive-environment_setup"></a>environment_setup |  Name of the environment setup file   |  none |
| <a id="http_yocto_toolchain_archive-sdk_installer"></a>sdk_installer |  Name of the self extracting toolchain script   |  none |
| <a id="http_yocto_toolchain_archive-build_file"></a>build_file |  The file to use as the BUILD file for the SDK tree.   |  <code>None</code> |
| <a id="http_yocto_toolchain_archive-build_file_content"></a>build_file_content |  The content for the BUILD file for the SDK tree.   |  <code>""</code> |
| <a id="http_yocto_toolchain_archive-kwargs"></a>kwargs |  Keyword arguments for the <code>http_archive</code>, see https://bazel.build/rules/lib/repo/http#http_archive.   |  none |


<a id="http_yocto_toolchain_file"></a>

## http_yocto_toolchain_file

<pre>
http_yocto_toolchain_file(<a href="#http_yocto_toolchain_file-name">name</a>, <a href="#http_yocto_toolchain_file-environment_setup">environment_setup</a>, <a href="#http_yocto_toolchain_file-build_file">build_file</a>, <a href="#http_yocto_toolchain_file-build_file_content">build_file_content</a>, <a href="#http_yocto_toolchain_file-kwargs">kwargs</a>)
</pre>

Download self extracting toolchain script

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="http_yocto_toolchain_file-name"></a>name |  Name of the final toolchain repository   |  none |
| <a id="http_yocto_toolchain_file-environment_setup"></a>environment_setup |  Name of the environment setup file   |  none |
| <a id="http_yocto_toolchain_file-build_file"></a>build_file |  The file to use as the BUILD file for the SDK tree.   |  <code>None</code> |
| <a id="http_yocto_toolchain_file-build_file_content"></a>build_file_content |  The content for the BUILD file for the SDK tree.   |  <code>""</code> |
| <a id="http_yocto_toolchain_file-kwargs"></a>kwargs |  Keyword arguments for the <code>http_file</code>, see https://bazel.build/rules/lib/repo/http#http_file.   |  none |


<a id="local_yocto_toolchain"></a>

## local_yocto_toolchain

<pre>
local_yocto_toolchain(<a href="#local_yocto_toolchain-name">name</a>, <a href="#local_yocto_toolchain-path">path</a>, <a href="#local_yocto_toolchain-build_file">build_file</a>, <a href="#local_yocto_toolchain-build_file_content">build_file_content</a>)
</pre>

Using local installed toolchain

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="local_yocto_toolchain-name"></a>name |  Name of the final toolchain repository   |  none |
| <a id="local_yocto_toolchain-path"></a>path |  local path to the repository   |  none |
| <a id="local_yocto_toolchain-build_file"></a>build_file |  The file to use as the BUILD file for the SDK tree.   |  <code>None</code> |
| <a id="local_yocto_toolchain-build_file_content"></a>build_file_content |  The content for the BUILD file for the SDK tree.   |  <code>""</code> |


