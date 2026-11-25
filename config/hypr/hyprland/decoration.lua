hl.config({
    decoration = {
        rounding = V.windowRounding,
        blur = {
            enabled           = V.blurEnabled,
            xray              = V.blurXray,
            special           = V.blurSpecialWs,
            ignore_opacity    = true,  -- Allows opacity blurring
            new_optimizations = true,
            popups            = V.blurPopups,
            input_methods     = V.blurInputMethods,
            size              = V.blurSize,
            passes            = V.blurPasses,
        },
        shadow = {
            enabled      = V.shadowEnabled,
            range        = V.shadowRange,
            render_power = V.shadowRenderPower,
            color        = rgba(C.surface .. "d4"),
        },
    },
})
