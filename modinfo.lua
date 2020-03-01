name = "Machine Range Check"
description = "Able you to check range of your machines:\n-Ice Flingomatic\n-Sprinkler\n-Oscillating Fan\n-Lightning Rod"
author = "Real author is _Q_"
version = "1.3"

forumthread = ""


api_version = 6

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

icon_atlas = "modicon.xml"
icon = "icon.tex"

configuration_options =
{
    {
        name = "Range Check Time",
        options =
        {
            {description = "Short 10s", data = "short"},
			{description = "Default 30s", data = "default"},
			{description = "Long 60s", data = "long"},
			{description = "Long 3m", data = "vlong"},
        },
        default = "default",
    }
	
}