<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module provides the definitions for configuring a Yocto toolchain for C and C++.


<a id="yocto_download_sdk"></a>

## yocto_download_sdk

<pre>
yocto_download_sdk(<a href="#yocto_download_sdk-name">name</a>, <a href="#yocto_download_sdk-auth_patterns">auth_patterns</a>, <a href="#yocto_download_sdk-bazel_toolchains_yocto_workspace_name">bazel_toolchains_yocto_workspace_name</a>, <a href="#yocto_download_sdk-build_file">build_file</a>,
                   <a href="#yocto_download_sdk-identifier">identifier</a>, <a href="#yocto_download_sdk-installer">installer</a>, <a href="#yocto_download_sdk-netrc">netrc</a>, <a href="#yocto_download_sdk-repo_mapping">repo_mapping</a>, <a href="#yocto_download_sdk-sha256">sha256</a>, <a href="#yocto_download_sdk-strip_prefix">strip_prefix</a>, <a href="#yocto_download_sdk-urls">urls</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="yocto_download_sdk-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="yocto_download_sdk-auth_patterns"></a>auth_patterns |  An optional dict mapping host names to custom authorization patterns.<br><br>If a URL's host name is present in this dict the value will be used as a pattern when generating the authorization header for the http request. This enables the use of custom authorization schemes used in a lot of common cloud storage providers. The pattern currently supports 2 tokens: &lt;code&gt;&lt;login&gt;&lt;/code&gt; and &lt;code&gt;&lt;password&gt;&lt;/code&gt;, which are replaced with their equivalent value in the netrc file for the same host name. After formatting, the result is set as the value for the &lt;code&gt;Authorization&lt;/code&gt; field of the HTTP request. Example attribute and netrc for a http download to an oauth2 enabled API using a bearer token: &lt;pre&gt; auth_patterns = {     "storage.cloudprovider.com": "Bearer &lt;password&gt;" } &lt;/pre&gt; netrc: &lt;pre&gt; machine storage.cloudprovider.com         password RANDOM-TOKEN &lt;/pre&gt; The final HTTP request would have the following header: &lt;pre&gt; Authorization: Bearer RANDOM-TOKEN &lt;/pre&gt;   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional | <code>{}</code> |
| <a id="yocto_download_sdk-bazel_toolchains_yocto_workspace_name"></a>bazel_toolchains_yocto_workspace_name |  The name given to the bazel-toolchains-yocto repository, if the default was not used.   | String | optional | <code>"bazel_toolchains_yocto"</code> |
| <a id="yocto_download_sdk-build_file"></a>build_file |  The file to use as the BUILD file for the toolchain repository. The file does not need to be named BUILD, but can be (something like BUILD.new-repo-name may work well for distinguishing it from the repository's actual BUILD files.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="yocto_download_sdk-identifier"></a>identifier |  Identifier for the target system to match the environment-setup file suffix   | String | optional | <code>""</code> |
| <a id="yocto_download_sdk-installer"></a>installer |  Basename of the SDK installer script inside an archive.   | String | optional | <code>""</code> |
| <a id="yocto_download_sdk-netrc"></a>netrc |  Location of the .netrc file to use for authentication   | String | optional | <code>""</code> |
| <a id="yocto_download_sdk-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="yocto_download_sdk-sha256"></a>sha256 |  The expected SHA-256 of the file downloaded.<br><br>This must match the SHA-256 of the file downloaded. _It is a security risk to omit the SHA-256 as remote files can change._ At best omitting this field will make your build non-hermetic. It is optional to make development easier this attribute should be set before shipping.   | String | required |  |
| <a id="yocto_download_sdk-strip_prefix"></a>strip_prefix |  Strip directory while extracting the archive.   | String | optional | <code>""</code> |
| <a id="yocto_download_sdk-urls"></a>urls |  A list of URLs to a Yocto toolchain.<br><br>The toolchain must be in the format of a self extracting shell script with the <code>.sh</code> file extension (Yocto standard) as a single file or within an archive. Each entry must be a file, http or https URL. Redirections are followed. URLs are tried in order until one succeeds, so you should list local mirrors first. If all downloads fail, the rule will fail.   | List of strings | required |  |


