-- This script can be used with project-filter option
-- It uses REMOTE_USER environment variable to obtain the user who needs to be authorized
-- This variable is normally set by HTTP Basic Authentication.
-- In Apache something like this can be used:
--
--    AuthType Basic
--    AuthName Protected area
--    AuthUserFile users.htpasswd
--    Require valid-user
--
-- For anonymous access a public username can be set in environment config.
-- In Apache, using mod_env:
--
--    SetEnv REMOTE_USER gitweb
--
-- Gitolite requires HOME environment variable to work properly and point to valid Gitolite
-- environment. Since the user, under which web server process runs, usually does not have
-- this set, HOME should be explicitly configured and pointed to valid gitolite setup.
-- In Apache, using mod_env:
--
--    SetEnv HOME /path/to/gitolite/home


local git = {}
local http = {}
local repos = {}
local action = nil

function action_init()
	-- Anonymous access, cancel repo list building
	if git.user == nil or git.user == "" then return end
	
	local handle = io.popen("gitolite list-phy-repos | gitolite access % " .. git.user .. " R any")
	
	while true do
		local repo = handle:read()
		if repo == nil then break end
		
		-- Skip DENIED repos
		if not string.find(repo, "DENIED") then
			-- Gitolite returns string: <repo>\t<user>\t<refs>
			-- We are interested only in the first field for now
			-- Append .git extension since Gitolite does not and cgit repo name has it
			local name = string.sub(repo, 0, string.find(repo, "\t") - 1) .. ".git"
			repos[name] = 1 -- Authorize flag is > 0
		end
	end
	
	handle:close()
end

function action_filter()
	-- Return > 0 if access is authorized
	return repos[git.repo]
end

local actions = {}
actions["init"] = action_init;
actions["filter"] = action_filter;

function filter_open(...)
	action = actions[select(1, ...)]
	
	git["repo"] = select(2, ...)
	git["user"] = select(3, ...)
	
	http["server"] = select(4, ...)
	http["path"] = select(5, ...)
end

function filter_close()
	return action()
end

