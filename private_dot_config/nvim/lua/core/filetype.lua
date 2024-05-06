vim.filetype.add({
	extension = {
		vert = "glsl",
		frag = "glsl",
	},
	pattern = {
		["${HOME}/.local/share/chezmoi/.*"] = {
			function(path, buf)
				if path:match("/dot_") then
					return vim.filetype.match({
						filename = path:gsub("/dot_", "/."),
						buf = buf,
					})
				end
			end,
			{ priority = -math.huge },
		},
	},
})
