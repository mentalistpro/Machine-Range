name                        = "Machine Range Indicator"
description                 = "Able you to check range of your machines:\n-Ice Flingomatic\n-Sprinkler\n-Oscillating Fan\n-Lightning Rod"
author                      = "Henry BioHazard and mentalistpro"
version                     = "1.6.2"
forumthread                 = ""
api_version                 = 6
priority                    = -1

dont_starve_compatible      = true
reign_of_giants_compatible  = true
shipwrecked_compatible      = true
hamlet_compatible           = true

icon_atlas                  = "modicon.xml"
icon                        = "modicon.tex"

configuration_options =
{
    {
        name = "range_fadetime",
        label = "Range fade time",
        options =
        {
            {description = "5s", data = -1},
            {description = "10s", data = 0},
            {description = "20s", data = 1},
            {description = "50s", data = 2},
            {description = "100s", data = 3},
            {description = "200s", data = 4},
            {description = "Infinite", data = 5},
        },
        default = 0,
    },

    {
        name = "automatic_refuel",
        label = "Automatic Refuel",
        options =
        {
            {description = "Yes", data = 0},
            {description = "No", data = 1},
        },
        default = 0,
    },

    {
        name = "campfire_safe",
        label = "Campfire safe",
        options =
        {
            {description = "Yes", data = 0},
            {description = "No", data = 1},
        },
        default = 0,
    },

    {
        name = "constructionplans",
        label = "Construction plans",
        options =
        {
            {description = "Yes", data = 0},
            {description = "No", data = 1},
        },
        default = 0,
    },

}