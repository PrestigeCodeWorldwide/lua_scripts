-- Persistent Data
local multiRefObjects = {

} -- multiRefObjects
local obj1 = {
	["settings"] = {
		["broadcast"] = "None";
		["frequency"] = 250;
	};
	["text_events"] = {
		["Heros Are Forged"] = {
			["pattern"] = "#*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["name"] = "Heros Are Forged";
			["category"] = "Group";
			["singlecommand"] = false;
		};
		["DoomShadeDarkness"] = {
			["pattern"] = "#*#sends shadows at #1#.#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["name"] = "DoomShadeDarkness";
			["category"] = "ToL";
			["singlecommand"] = false;
		};
		["Narandi Shatters"] = {
			["pattern"] = "#*#Narandi appears to shatter#*#";
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "Narandi Shatters";
		};
		["Shei-Splash"] = {
			["pattern"] = "#*#You are unworthy.#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "Shei-Splash";
		};
		["MaxAAGlyphBurn"] = {
			["pattern"] = "#*#You have reached the AA point cap#*#";
			["command"] = "";
			["name"] = "MaxAAGlyphBurn";
			["singlecommand"] = false;
			["category"] = "Misc Utils";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
		};
		["Dimming Cure"] = {
			["pattern"] = "#*#The darkness inside you begins to grow#*#";
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "Dimming Cure";
		};
		["Narandi Revealed"] = {
			["pattern"] = "#*#A shell of restless ice falls away#*#";
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "Narandi Revealed";
		};
		["DoomShadeViral"] = {
			["pattern"] = "#*#curses #1#.#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["name"] = "DoomShadeViral";
			["category"] = "ToL";
			["singlecommand"] = false;
		};
		["aowmove"] = {
			["pattern"] = "#*#The Avatar of War changes the rules and chooses a new field of battle!#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "aowmove";
		};
		["aowduck"] = {
			["pattern"] = "#*#The ice encrusted Avatar of War shouts that #1# must bend the knee!#*#";
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "aowduck";
		};
		["TantorChase"] = {
			["pattern"] = "#*#Tantor roars, pointing its trunk at #1#.#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "TantorChase";
		};
		["MadEmp"] = {
			["pattern"] = "#*#Venril Sathir focuses his Intent on #1#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "MadEmp";
		};
		["Zelni-Insects"] = {
			["pattern"] = "#*#Insects begin to swarm. They seem to be drawn to #1#.#*#";
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["name"] = "Zelni-Insects";
			["category"] = "Older";
			["singlecommand"] = false;
		};
		["aowstand"] = {
			["pattern"] = "#*#The Avatar of War nods, accepting the subservience of those that gave it#*#";
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "aowstand";
		};
		["atensilence"] = {
			["pattern"] = "#*#Aten Ha Ra points at #1# with one arm#*#";
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["name"] = "atensilence";
			["category"] = "";
			["singlecommand"] = false;
		};
	};
	["condition_events"] = {
		["SheiBanish"] = {
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "SheiBanish";
		};
		["sheicureall"] = {
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["name"] = "sheicureall";
			["category"] = "";
		};
		["XpMe"] = {
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "Misc Utils";
			["name"] = "XpMe";
		};
		["sheibard"] = {
			["load"] = {
				["class"] = "";
				["characters"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "sheibard";
		};
		["AAPCT"] = {
			["load"] = {
				["class"] = "";
				["always"] = false;
				["zone"] = "";
			};
			["category"] = "";
			["name"] = "AAPCT";
		};
	};
	["categories"] = {
		[1] = {
			["name"] = "Misc Utils";
			["children"] = {
			};
		};
		[2] = {
			["name"] = "Raid";
			["children"] = {
				[1] = {
					["name"] = "LS";
					["children"] = {
					};
				};
				[4] = {
					["name"] = "Older";
					["children"] = {
					};
				};
				[2] = {
					["name"] = "NoS";
					["children"] = {
					};
				};
				[3] = {
					["name"] = "ToL";
					["children"] = {
					};
				};
			};
		};
		[3] = {
			["name"] = "Group";
			["children"] = {
			};
		};
	};
}
return obj1
