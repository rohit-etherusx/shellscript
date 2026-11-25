hl.config({
    general = {
        layout          = "dwindle",
        allow_tearing   = false,  -- Allows the `immediate` window rule to work
        gaps_workspaces = V.workspaceGaps,
        gaps_in         = V.windowGapsIn,
        gaps_out        = V.windowGapsOut,
        border_size     = V.windowBorderSize,
        col = {
            active_border   = rgba(C.primary .. "e6"),
            inactive_border = rgba(C.onSurfaceVariant .. "11"),
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },
})
