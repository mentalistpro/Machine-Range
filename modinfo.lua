name                        = "Machine Range Check"
description                 = "Able you to check range of your machines:\n-Ice Flingomatic\n-Sprinkler\n-Oscillating Fan\n-Lightning Rod"
author                      = "_Q_, Black Mirror, Henry BioHazard and mentalistpro"
version                     = "1.3"
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
            {description = "15s", data = 3},
            {description = "20s", data = 4},
            {description = "25s", data = 5},
            {description = "30s", data = 6},
			{descriptoin = "Indefinite", data = 7}
        },
        default = 0,
    },
	
	{
        name = "range_colour",
		label = "Range colour",
        options =
        {
			{description = "orange", data = 0},
			{descriptoin = "yellow", data = 1},
            {description = "white", data = 2},
            {description = "grey", data = 3},
        },
        default = 0,
    },
	
}