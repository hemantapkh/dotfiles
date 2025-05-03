---@diagnostic disable: missing-fields
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("dap-python").setup("~/.local/share/uv/tools/debugpy/bin/python3")

      require("dapui").setup()
      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      vim.fn.sign_define("DapBreakpoint", {
        text = "✋",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "", -- or "→"
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      local opts = { noremap = true, silent = true }

      -- Toggle breakpoint
      vim.keymap.set("n", "<leader>db", function()
        dap.toggle_breakpoint()
      end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))

      -- Set conditional breakpoint
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, vim.tbl_extend("force", opts, { desc = "Set conditional breakpoint" }))

      -- Clear all breakpoints
      vim.keymap.set("n", "<leader>dC", function()
        dap.clear_breakpoints()
      end, vim.tbl_extend("force", opts, { desc = "Clear all breakpoints" }))

      -- Continue / Start
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, vim.tbl_extend("force", opts, { desc = "Start/continue debugging" }))

      -- Run to cursor
      vim.keymap.set("n", "<leader>dr", function()
        dap.run_to_cursor()
      end, vim.tbl_extend("force", opts, { desc = "Run to cursor" }))

      -- Step Over
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, vim.tbl_extend("force", opts, { desc = "Step over line" }))

      -- Step Into
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, vim.tbl_extend("force", opts, { desc = "Step into function" }))

      -- Step Out
      vim.keymap.set("n", "<leader>dO", function()
        dap.step_out()
      end, vim.tbl_extend("force", opts, { desc = "Step out of function" }))

      -- Restart debugging
      vim.keymap.set("n", "<leader>dR", function()
        dap.restart()
      end, vim.tbl_extend("force", opts, { desc = "Restart debugging" }))

      -- Terminate debugging
      vim.keymap.set("n", "<leader>dq", function()
        require("dap").terminate()
      end, vim.tbl_extend("force", opts, { desc = "Terminate debugging" }))

      -- Toggle DAP UI
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))

      -- Evaluate expression
      vim.keymap.set("n", "<leader>de", function()
        dapui.eval()
      end, vim.tbl_extend("force", opts, { desc = "Evaluate expression" }))
    end,
  },
}
