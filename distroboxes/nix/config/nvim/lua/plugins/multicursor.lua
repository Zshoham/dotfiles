return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, "<leader>mk", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add cursor below" })
      set({ "n", "x" }, "<leader>mj", function()
        mc.lineAddCursor(1)
      end, { desc = "Add cursor above" })
      set({ "n", "x" }, "<leader>mK", function()
        mc.lineSkipCursor(-1)
      end, { desc = "Skip cursor above" })
      set({ "n", "x" }, "<leader>mJ", function()
        mc.lineSkipCursor(1)
      end, { desc = "Skip cursor below" })

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "<leader>mn", function()
        mc.matchAddCursor(1)
      end, { desc = "Add cursor by next match/selection" })
      set({ "n", "x" }, "<leader>ms", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip cursor by next match/selection" })
      set({ "n", "x" }, "<leader>mN", function()
        mc.matchAddCursor(-1)
      end, { desc = "Add cursor by previous match/selection" })
      set({ "n", "x" }, "<leader>mS", function()
        mc.matchSkipCursor(-1)
      end, { desc = "Skip cursor by previous match/selection" })

      -- Pressing `gaip` will add a cursor on each line of a paragraph.
      set("n", "<leader>mo", mc.addCursorOperator, { desc = "Add cursor acording to operator." })

      -- Pressing `<leader>miwap` will create a cursor in every match of the
      -- string captured by `iw` inside range `ap`.
      -- This action is highly customizable, see `:h multicursor-operator`.
      set({ "n", "x" }, "<leader>mO", mc.operator, { desc = "Add cursor in every match by operator, acording to second operator." })

      -- Align cursor columns.
      set("n", "<leader>ma", mc.alignCursors, { desc = "Align cursor columns." })

      -- Split visual selections by regex.
      set("x", "<leader>mvs", mc.splitCursors, { desc = "Split visual selction by regex." })
      set("x", "<leader>mvr", mc.matchCursors, { desc = "Match new cursors within visual selection by regex." })
      set("n", "<leader>mu", mc.restoreCursors, { desc = "Undo cursor clear." })
      set({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "Add cursor to all matches of word/selction in document" })

      -- Rotate the text contained in each visual selection between cursors.
      set("x", "<leader>mt", function()
        mc.transposeCursors(1)
      end, { desc= "Rotate text between cursors" })
      set("x", "<leader>mT", function()
        mc.transposeCursors(-1)
      end, { desc= "Rotate text back between cursors." })

      -- Add a cursor and jump to the next/previous search result.
      set("n", "<leader>m/n", function()
        mc.searchAddCursor(1)
      end, { desc = "Add cursor and jump to next search." })
      set("n", "<leader>m/N", function()
        mc.searchAddCursor(-1)
      end, { desc = "Add cursor and jump to previous search." })

      -- Jump to the next/previous search result without adding a cursor.
      set("n", "<leader>m/s", function()
        mc.searchSkipCursor(1)
      end, { desc = "Jump to next search without adding a cursor." })
      set("n", "<leader>m/S", function()
        mc.searchSkipCursor(-1)
      end, { desc = "Jump to previous search without adding a cursor." })

      set("n", "<leader>m/A", mc.searchAllAddCursors, { desc = "Add cursor to all search results in buffer." })

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
}
