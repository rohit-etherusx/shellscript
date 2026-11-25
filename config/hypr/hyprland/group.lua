local active, inactive = rgba(C.primary .. "e6"), rgba(C.onSurfaceVariant .. "11")
hl.config({
    group = {
        col = {
            border_active          = active,
            border_inactive        = inactive,
            border_locked_active   = active,
            border_locked_inactive = inactive,
        },
        groupbar = {
            font_family               = "JetBrains Mono NF",
            font_size                 = 15,
            gradients                 = true,
            gradient_round_only_edges = false,
            gradient_rounding         = 5,
            height                    = 25,
            indicator_height          = 0,
            gaps_in                   = 3,
            gaps_out                  = 3,
            text_color                = rgb(C.onPrimary),
            col = {
                active          = rgba(C.primary .. "d4"),
                inactive        = rgba(C.outline .. "d4"),
                locked_active   = rgba(C.primary .. "d4"),
                locked_inactive = rgba(C.secondary .. "d4"),
            },
        },
    },
})
