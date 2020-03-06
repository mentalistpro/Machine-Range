name                        = "Machine Range Check"
description                 = "Able you to check range of your machines:\n-Ice Flingomatic\n-Sprinkler\n-Oscillating Fan\n-Lightning Rod"
author                      = "_Q_, Henry BioHazard and mentalistpro"
version                     = "1.4"
forumthread                 = ""
api_version                 = 6

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
		label = "Range fades in",
        options =
        {
            {description = "2s", data = 0},
            {description = "5s", data = 1},
            {description = "10s", data = 2},
            {description = "20s", data = 3},
            {description = "50s", data = 4},
            {description = "100s", data = 5},
            {description = "Infinite", data = 6},
        },
        default = 2,
    },	
}