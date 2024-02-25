-- presets
return {
    -- Examples:
    --     ["Clouds 1"] = {
    --         ["sim/private/controls/new_clouds/high_freq_amp"] = 0.3,
    --         ["sim/private/controls/new_clouds/density"] = 300, -- between 100 and 700 is ok
    --         ["sim/private/controls/new_clouds/direct"] = 1.4, -- between 0.1 and 4 is ok, normal is 1
    --     },
    --     ["Clouds 2"] = {
    --         ["_includes"] = { "Clouds 1" }, -- makes this preset include other presets
    --         ["sim/private/controls/new_clouds/high_freq_amp"] = 0.2,
    --         ["sim/private/controls/new_clouds/density"] = 150,
    --         ["sim/private/controls/new_clouds/direct"] = 1.4,
    --     },
    ["_my"] = {
        ["_includes"] = {
            "atmosphere:unhaze",
            "lights+",
            "rain-",
            "albedo",
            "ozone:blue-",
            "water:ungloss",
            "stars+",
        }
    },
    -- Bishop_DE https://discord.com/channels/842725192119353354/874557875824001095/1164966272728039444
    ["tonemap+"] = {
    -- can't be set:
--         ["sim/private/controls/lighting/E_sun_lx"] = 138459.02,
--         ["sim/private/controls/atmo/ozone_center"] = 22349.9,
--         ["sim/private/controls/atmo/ozone_width"] = 35660.71,
--         ["sim/private/controls/cubemap/z_offset"] = 1.0,
--         ["sim/private/controls/cloud/temporal_alpha"] = 0.5,
--         ["sim/private/controls/autoexposure/gain_lo"] = 0.5,
        ["sim/private/controls/tonemap/blend"] = 0.4,
    },
    ["tonemap++"] = {
    -- can't be set:
--         ["sim/private/controls/lighting/E_sun_lx"] = 138459.02,
--         ["sim/private/controls/atmo/ozone_center"] = 22349.9,
--         ["sim/private/controls/atmo/ozone_width"] = 35660.71,
--         ["sim/private/controls/cubemap/z_offset"] = 1.0,
--         ["sim/private/controls/cloud/temporal_alpha"] = 0.5,
--         ["sim/private/controls/autoexposure/gain_lo"] = 0.5,
        ["sim/private/controls/tonemap/blend"] = 0.7,
    },
    ["ozone:blue-"] = {
        ["sim/private/controls/atmo/ozone_r"] = 2.2911,
        ["sim/private/controls/atmo/ozone_g"] = 1.5404,
        ["sim/private/controls/atmo/ozone_b"] = 0.0,
    },
    ["ozone:g4xp12 blue"] = {
        ["sim/private/controls/atmo/ozone_r"] = 3,
        ["sim/private/controls/atmo/ozone_g"] = 2,
        ["sim/private/controls/atmo/ozone_b"] = 0,
    },
    ["ozone:g4xp12 golden"] = {
        ["sim/private/controls/atmo/ozone_r"] = 0,
        ["sim/private/controls/atmo/ozone_g"] = 1.9,
        ["sim/private/controls/atmo/ozone_b"] = 1,
    },
    ["rain:kill"] = {
        ["sim/private/controls/rain/kill_3d_rain"] = 1,
    },
    ["clouds:less frac"] = {
--         ["sim/private/controls/new_clouds/high_freq_rat"] = 8,
        ["sim/private/controls/new_clouds/low_freq_rat"] = 6.5,
    },
    ["clouds:less frac+"] = {
--         ["sim/private/controls/new_clouds/high_freq_rat"] = 8,
        ["sim/private/controls/new_clouds/low_freq_rat"] = 5,
    },
    ["water:ungloss"] = {
        ["sim/private/controls/water/gloss"] = 0.7,
    },
    ["water:ungloss+"] = {
        ["sim/private/controls/water/gloss"] = 0.6,
    },
    ["water:ungloss++"] = {
        ["sim/private/controls/water/gloss"] = 0.4,
    },
    ["use_post_aa"] = {
        ["sim/private/controls/hdr/use_post_aa"] = 1,
    },
    -- https://forum.thresholdx.net/topic/187-a-decent-guide-to-crisp-shadows/
    ["shadows (mostly not writable)"] = {
        ["sim/private/controls/fbo/shadow_cam_size"] = 8192,
        -- 0..4
        ["sim/private/controls/shadow/csm_split_exterior"] = 1,
        -- 0..4
        ["sim/private/controls/shadow/csm_split_interior"] = 3,
        ["sim/private/controls/shadow/cockpit_near_adjust"] = 2.0,
        --["sim/private/controls/shadow/csm/far_limit"] = 3.0,
        ["sim/private/controls/shadow/cockpit_near_proxy"] = 2.0,
    },
    -- https://x-plane.to/file/644/xenhancer
    ["xEnhancer"] = {
        ["sim/private/controls/weather/warble_factor"] =  2,
        ["sim/private/controls/weather/real_perlin_scale"] =  0.090,
--         ["sim/private/controls/new_clouds/scale"] =  800,
        ["sim/private/controls/new_clouds/density"] =  80,
        ["sim/private/controls/new_clouds/direct"] =  2,
        ["sim/private/controls/new_clouds/march/seg_steps"] =  200,
        --["sim/private/controls/scattering/multi_rat"] =  2.8,
        --["sim/private/controls/scattering/single_rat"] =  2.3,
        --["sim/private/controls/render/reflection_update"] =  1,
    },
    ["xEnhancer-"] = {
--         ["sim/private/controls/weather/warble_factor"] =  2,
--         ["sim/private/controls/weather/real_perlin_scale"] =  0.090,
--         ["sim/private/controls/new_clouds/density"] =  80,
        ["sim/private/controls/new_clouds/direct"] =  1.5,
        ["sim/private/controls/new_clouds/march/seg_steps"] =  200,
--         ["sim/private/controls/render/reflection_update"] =  1,
    },
    ["sun scattering---"] = {
        ["sim/private/controls/scattering/override_turbidity_t"] = 3.,
    },
    ["sun scattering--"] = {
        ["sim/private/controls/scattering/override_turbidity_t"] = 2.,
    },
    ["sun scattering-"] = {
        ["sim/private/controls/scattering/override_turbidity_t"] = 1.,
    },
    -- https://forums.x-plane.org/index.php?/forums/topic/284875-lower-foghaze/
    ["atmosphere:unhaze"] = {
        ["sim/private/controls/scattering/single_rat"] = 1.5,
        ["sim/private/controls/scattering/multi_rat"] = 2,
    },
    ["atmosphere:unhaze+"] = {
        ["sim/private/controls/scattering/single_rat"] = 1.2,
        ["sim/private/controls/scattering/multi_rat"] = 1.5,
    },
    ["water:enable_turbidity=0"] = {
        ["sim/private/controls/water/enable_turbidity"] = 0,
    },
    ["water:turbidity"] = {
        ["sim/private/controls/water/turbidity"] = .01,
    },
    ["water:cutoff"] = {
        ["sim/private/controls/water/turbidity/cutoff"] = -1,
    },
    ["draw far"] = {
        ["sim/private/controls/clip/override_far"] = 200000,
    },
    ["draw far+"] = {
        ["sim/private/controls/clip/override_far"] = 500000,
    },
    ["draw far++"] = {
        ["sim/private/controls/clip/override_far"] = 1000000,
    },

    -- adjusted from graphics4xp12 by hakanr339b 1.0.0
    -- https://forums.x-plane.org/index.php?/files/file/85470-graphics4xp12-by-hakanr339b/
    ["clouds:graphics4xp12"] = {
        ["sim/private/controls/new_clouds/low_freq_rat"] = 23,
        ["sim/private/controls/new_clouds/high_freq_rat"] = 23,
        ["sim/private/controls/new_clouds/high_freq_amp"] = 0.2,
        ["sim/private/controls/new_clouds/march/seg_steps"] = 479,
        ["sim/private/controls/new_clouds/ambient"] = 0.1,
--         ["sim/private/controls/new_clouds/scale"] = 850,
--         ["sim/private/controls/new_clouds/low_freq_rat"] = 37,
--         ["sim/private/controls/new_clouds/high_freq_rat"] = 37,
--         ["sim/private/controls/new_clouds/high_freq_amp"] = 0.37,
--         ["sim/private/controls/new_clouds/march/seg_steps"] = 500,
    },
    ["clouds:g4xp12 2"] = {
        ["sim/private/controls/new_clouds/low_freq_rat"] = 23,
        ["sim/private/controls/new_clouds/high_freq_rat"] = 23,
        ["sim/private/controls/new_clouds/march/seg_steps"] = 509,
    },
    ["lighting:g4xp12"] = {
        ["sim/private/controls/cubemap/x_scale"] = 1.5,
    },
    ["albedo"] = {
        ["sim/private/controls/scattering/earth_albedo"] = 0.05,
    },
    ["albedo+"] = {
        ["sim/private/controls/scattering/earth_albedo"] = -0.02,
    },
    ["albedo++"] = {
        ["sim/private/controls/scattering/earth_albedo"] = -0.07,
    },
    ["lights+"] = {
        ["sim/private/controls/lights/photobb/attenuation1"] = 10,
    },
    ["lights++"] = {
        ["sim/private/controls/lights/photobb/attenuation1"] = 20,
    },
    ["lights+++"] = {
        ["sim/private/controls/lights/photobb/attenuation1"] = 50,
    },
    ["stars"] = {
        ["sim/private/controls/stars/gain_photometric"] = 100,
    },
    ["stars+"] = {
        ["sim/private/controls/stars/gain_photometric"] = 200,
    },
    ["stars++"] = {
        ["sim/private/controls/stars/gain_photometric"] = 500,
    },
    ["rain-"] = {
         ["sim/private/controls/rain/intensity_power"] = 0.5,
         ["sim/private/controls/rain/intensity_scale"] = 0.7,
         ["sim/private/controls/rain/scale"] = 0.5,
--          ["sim/private/controls/rain/acceleration_factor"] = 0.01,
    },
--     ["clouds:WClouds 1"] = {
--         ["sim/private/controls/new_clouds/low_freq_rat"] = 14,
--         ["sim/private/controls/new_clouds/high_freq_amp"] = 0.65,
-- --         ["sim/private/controls/new_clouds/scale"] = 1200,
--         ["sim/private/controls/new_clouds/direct"] = 2,
--         ["sim/private/controls/new_clouds/density"] = 300,
--         ["sim/private/controls/new_clouds/high_freq_rat"] = 8,
--         ["sim/private/controls/new_clouds/march/seg_mul"] = 1.5,
--         ["sim/private/controls/new_clouds/march/seg_steps"] = 125,
--         ["sim/private/controls/new_clouds/march/step_len_start"] = 20,
--         ["sim/private/controls/new_clouds/march/seg_count"] = 10,
--     },
--     ["clouds: WClouds 2"] = {
--         ["sim/private/controls/new_clouds/low_freq_rat"] = 18,
--         ["sim/private/controls/new_clouds/high_freq_amp"] = 0.45,
-- --         ["sim/private/controls/new_clouds/scale"] = 1100,
--         ["sim/private/controls/new_clouds/direct"] = 2.5,
--         ["sim/private/controls/new_clouds/density"] = 300,
--         ["sim/private/controls/new_clouds/high_freq_rat"] = 6,
--         ["sim/private/controls/new_clouds/march/seg_mul"] = 1.5,
--         ["sim/private/controls/new_clouds/march/seg_steps"] = 500,
--         ["sim/private/controls/new_clouds/march/step_len_start"] = 30,
--         ["sim/private/controls/new_clouds/march/seg_count"] = 9,
--     }
}
