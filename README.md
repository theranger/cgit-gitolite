This patch adds support for Gitolite authorization when accessing git repositories via cgit web interface.

This version adds an additional `project-filter` configuration option that refers to a worker script written in Lua. It will not perform authentication by itself, but rather reads the authenticated user name from web server's `REMOTE_USER` environment variable.

When building repository list, filter script will be called with a repository name currently being processed. Script must return either 1 to allow or 0 to deny access. Repository paths that got access denied will be excluded from listing therefore hiding them and effectively banning any further access.

Populating the `REMOTE_USER` variable can be done via HTTP Authentication (e.g. Basic). Please be reminded that HTTP Basic Authentication is insecure and should only be used over SSL channel. Since authentication is done by the web server, any method works as long as the username will be stored in a `REMOTE_USER` environment variable.

This solution can be used with any available authorization system, but it was originally developed for using with Gitolite. Since Gitolite requires `HOME` environment variable to be set to a directory where Gitolite configuration resides, please see the documentation in the source tree that has examples how to do that.

Further technical information is located in a sample filter script and configuration manual under `project-filter` configuration option.