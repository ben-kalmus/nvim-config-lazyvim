return {
	"nvim-mini/mini.ai",
	version = false,
	config = function()
		require("mini.ai").setup({
			custom_textobjects = {
				p = { { "%b()", "%b[]", "%b{}", "%b<>" }, "^.().*().$" },
			},
		})
	end,
}
