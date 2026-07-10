return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		default = {
			-- Directory to save images (relative to current file)
			dir_path = "assets",
			-- Image file naming pattern
			file_name = "%Y-%m-%d-%H-%M-%S",
			-- Use absolute or relative path in markdown
			use_absolute_path = false,
			-- Prompt for confirmation before pasting
			prompt_for_file_name = true,
			-- Show notification after pasting
			show_dir_path_in_prompt = true,
			-- Use cursor location for prompt
			insert_mode_after_paste = true,
		},
		-- Filetype specific settings
		filetypes = {
			markdown = {
				-- Template for markdown image syntax
				url_encode_path = true,
				template = "![$CURSOR]($FILE_PATH)",
				-- Download URLs when pasting
				download_images = true,
			},
			vimwiki = {
				url_encode_path = true,
				template = "![$CURSOR]($FILE_PATH)",
				download_images = true,
			},
			html = {
				template = '<img src="$FILE_PATH" alt="$CURSOR">',
			},
			tex = {
				template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
    ]],
			},
			typst = {
				template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
    ]],
			},
			org = {
				template = [=[
#+BEGIN_FIGURE
[[file:$FILE_PATH]]
#+CAPTION: $CURSOR
#+NAME: fig:$LABEL
#+END_FIGURE
    ]=],
			},
		},
	},
	keys = {
		-- Paste image from clipboard
		{ "<leader>mp", "<cmd>PasteImage<cr>", desc = "Paste Image from Clipboard", ft = { "markdown", "vimwiki" } },
	},
}
