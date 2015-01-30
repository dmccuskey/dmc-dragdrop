# dmc-dragdrop

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-dragdrop"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-dragdrop",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_dragdrop.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library",
			"dmc-objects"
		]
	},
	"examples": {
		"base_dir": "examples",
		"apps": [
			{
				"exp_dir": "dmc-dragdrop-basic",
				"requires": []
			},
			{
				"exp_dir": "dmc-dragdrop-oop",
				"requires": [
					"dmc-utils"
				]
			}
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-dragdrop", module_config )

