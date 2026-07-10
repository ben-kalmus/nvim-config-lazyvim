return {
	-- Auto-detect indentation style (tabs vs spaces, tab width) per buffer.
	-- Reads the file's existing indentation and sets expandtab/tabstop/shiftwidth
	-- accordingly, so tab-indented files (Go) and space-indented files (Lua) both
	-- behave correctly without manual per-filetype config.
	"tpope/vim-sleuth",
	event = "BufReadPre",
}
