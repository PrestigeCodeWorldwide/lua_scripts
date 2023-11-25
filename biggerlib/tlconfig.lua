return {
    include_dir = {
        "vendor/",
		"src/"   
    },
    source_dir = "src/",
	build_dir = "dist/",
    --[[ 
	include_dir {string} prepend dir to module search path
	include     {string} Set of files to compile
	exclude     {string} Set of files to ignore
	source_dir   string  Set the directory to be searched for files. build will compile every .tl file in every subdirectory by default.
	build_dir    string Set the directory for generated files, mimicking the file structure of the source files.
	
	-p --pretend both dry run
	disable_warnings {string} Disable given warnings
	global_env_def    string  Specify a definition module declaring any custom globals predefined in your Lua environment
	
	]]
}