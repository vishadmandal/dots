local builtin = require("telescope.builtin")
vim.keymap.set("n" , "<leader>ff" , builtin.find_files, {})
vim.keymap.set("n" , "<leader>fs" , builtin.grep_string, {})
vim.keymap.set("n" , "<C-f>" , builtin.git_files, {})


