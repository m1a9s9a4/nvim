return {
	-- nvim-dap: Debug Adapter Protocol client
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- nvim-dap-ui: UI for nvim-dap
			{
				"rcarriga/nvim-dap-ui",
				dependencies = {
					"nvim-neotest/nvim-nio",
				},
			},
			-- nvim-dap-go: Go-specific configuration
			{
				"leoluz/nvim-dap-go",
				config = function()
					require("dap-go").setup({
						-- デバッグアダプターの設定
						dap_configurations = {
							{
								type = "go",
								name = "Attach remote (backend-api)",
								mode = "remote",
								request = "attach",
								-- api-debug-headless で起動したプロセスに接続
								connect = {
									host = "127.0.0.1",
									port = "2345",
								},
							},
							{
								type = "go",
								name = "Debug (with .env)",
								request = "launch",
								program = "${file}",
								-- .envファイルを読み込む設定
								envFile = "${workspaceFolder}/.env",
							},
							{
								type = "go",
								name = "Debug Package (with .env)",
								request = "launch",
								program = "${fileDirname}",
								envFile = "${workspaceFolder}/.env",
							},
							{
								type = "go",
								name = "Debug backend-api (cmd/apiserver)",
								request = "launch",
								program = "${workspaceFolder}/cmd/apiserver",
								envFile = "${workspaceFolder}/.env",
							},
						},
						-- Delveの設定
						delve = {
							-- Delveのパス（デフォルトはPATHから検索）
							path = "dlv",
							-- デバッグアダプターのポート
							initialize_timeout_sec = 20,
							port = "${port}",
							args = {},
							build_flags = "",
						},
					})
				end,
			},
			-- nvim-dap-virtual-text: 変数の値をインラインで表示
			{
				"theHamsta/nvim-dap-virtual-text",
				config = function()
					require("nvim-dap-virtual-text").setup({})
				end,
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- DAP UIの設定
			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 },
							{ id = "breakpoints", size = 0.25 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 10,
						position = "bottom",
					},
				},
			})

			-- デバッグ開始時にUIを自動で開く
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			-- デバッグ終了時にUIを自動で閉じる
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- ブレークポイントのアイコン設定
			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "⚫", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "", linehl = "", numhl = "" })
		end,
		keys = {
			-- デバッグ開始/続行
			{ "<leader>dc", function() require("dap").continue() end, desc = "Debug: Continue" },
			-- ブレークポイントのトグル
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
			-- 条件付きブレークポイント
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: Conditional Breakpoint",
			},
			-- ステップオーバー（次の行）
			{ "<leader>dn", function() require("dap").step_over() end, desc = "Debug: Step Over" },
			-- ステップイン（関数に入る）
			{ "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step Into" },
			-- ステップアウト（関数から出る）
			{ "<leader>do", function() require("dap").step_out() end, desc = "Debug: Step Out" },
			-- デバッグ終了
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
			-- UIのトグル
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
			-- カーソル下の変数を評価
			{ "<leader>de", function() require("dapui").eval() end, desc = "Debug: Eval", mode = { "n", "v" } },
			-- REPLを開く
			{ "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
		},
	},
}
