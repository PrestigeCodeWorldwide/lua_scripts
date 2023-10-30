	#NOTES
	class.spellRotations = {melee={},caster={},meleedot={}, med={}, downtime={}}
	 class.medleyRunning == 'none'

#TODO
- Add UseSelos option/check
- Turn off medley when pausing (?maybe)
- Add /twist off alias for /relocate and other things expecting mq2twist
 
 https://www.redguides.com/community/threads/cwtn-mode-reference-chart.77526/
 - especially make sure the modes for taunt/ sits down works

#BOXR
In order for Boxr to work, regardless of whether your lua responds to the same commands as another automation,
you still must pass one of the internal Boxr "checks" to see which automation you're using.  The only one that
functions NOT as a macro (which is key, since we don't want to block any other macro) is the CWTN plugins, so
we need to spoof the CWTN bard plugin (which doesn't exist yet) and pretend to be it instead of ourselves.  This
also has added benefit of making it 1:1 with the plugin suite we all prefer.

I spoofed the plugin by creating a new plugin (mkplugin.exe MQ2Bard) in the source build repo, then adding it
to MacroQuest.sln as a new project and building it.  The plugin does *NOTHING*, consumes no resources, does not
tick, and effectively acts as a false flag to Boxr merely by being enabled.  I've included the resulting DLL in
this repo, but you can also build it yourself if you want to be sure it's not malicious.

## Boxr Commands supported:

void CwtnControl::Pause() {
boxrRunCommandf("/{} pause on", GetClassCommand());
}

void CwtnControl::Unpause() {
boxrRunCommandf("/{} pause off", GetClassCommand());
}

void CwtnControl::Chase() {
boxrRunCommandf("/{} mode chase", GetClassCommand());
}

void CwtnControl::Camp() {
boxrRunCommandf("/{} mode assist", GetClassCommand());
boxrRunCommandf("/{} resetcamp", GetClassCommand());
}

void CwtnControl::Manual() {
boxrRunCommandf("/{} mode manual", GetClassCommand());
}

void CwtnControl::BurnNow() {
boxrRunCommandf("/{} BurnNow", GetClassCommand());
}

void CwtnControl::SetRaidAssistNum(int raidAssistNum) {
boxrRunCommandf("/{} raidassistnum {}", GetClassCommand(), raidAssistNum);
}


#Useful Commands
/caption npc ${NamingSpawn.CleanName}\n${NamingSpawn.Name}-${NamingSpawn.ID}
/echo ${Spawn[1000].Buff[Slumber]}
/echo ${Spawn[27138].BuffDuration[Slumber]}


#Medley setup
This bot makes use of 5 different medley lineups for different situations.  

1. Downtime - What to play when not in combat and also not specifically meditating.  Running around in general will cause this to play.  If bard is invis, does not play at all. 
2. Med - What to play when specifically "Medding" because of low mana.  Very very infrequent need
3. Melee - Combat lineup to play in melee group.  This is selected in the GUI as one of the dropdown options
4. MeleeDot - Combat lineup with a couple melee buffs and all personal dots.  This is selected in the GUI as one of the dropdown options
5. Caster - Combat lineup to play in caster groups.  This is selected in the GUI as one of the dropdown options
6. Tank - Played in Tank groups
You need to configure these in an ini file.  Inside your MQ2 installation directory is a config directory.  Inside of it will be an ini file named like `server_character.ini`  For example, `test_kodajii.ini`

Inside that file, add the following sections wherever and change to suit your lineups.  Mine are semi optimized for 120 already:

[MQ2Medley]
Debug=0
Delay=3
Medley=melee
Playing=0
Quiet=1

[MQ2Medley-meleedot]
song1=Shak Dathor's Chant of Flame^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
song2=Sylra Fris' Chant of Frost^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
song3=Cruor's Chant of Poison^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
song4=Coagulus' Chant of Disease^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
songIF=!${Me.Invis}

[MQ2Medley-downtime]
song1=Zelinstein's Lively Crescendo^30^${Group.LowMana[95]} > 0
song2=Pulse of Nikolas^30^1
song3=Xetheg's Spry Sonata^30^1
song4=Aria of Pli Xin Liako^27^1
song5=War March of Centien Xi Va Xakra^30^1
song6=Unified Phoenix Feather^30^(!${Group} || ${SpawnCount[group radius 250]}==${Group.GroupSize}) && !${Me.Song[Grace of Unity].ID} && ${Me.CombatState.Equal[COMBAT]} && ${Me.PctEndurance} < 95
song7=Shojralen's Song of Suffering^24^1
songIF=!${Me.Invis}

[MQ2Medley-melee]
song1=Xetheg's Spry Sonata^30^1
song2=Aria of Pli Xin Liako^27^1
song3=Blade of Vesagran^180^${Me.Combat}
song4=War March of Centien Xi Va Xakra^30^1
song5=Unified Phoenix Feather^30^(!${Group} || ${SpawnCount[group radius 250]}==${Group.GroupSize}) && !${Me.Song[Grace of Unity].ID} && ${Me.CombatState.Equal[COMBAT]} && ${Me.PctEndurance} < 95
song6=Shojralen's Song of Suffering^24^1
song7=Ecliptic Psalm^60^${Me.Combat} && (${Target.PctHPs} > 50 || ${Target.Named} || ${Me.XTarget} > 1)
song8=Zelinstein's Lively Crescendo^30^${Group.LowMana[95]} > 0
songIF=!${Me.Invis}

[MQ2Medley-caster]
song1=Fyrthek Fior's Psalm of Potency^30^1
song11=Shojralen's Song of Suffering^24^1
song15=Zelinstein's Lively Crescendo^30^${Group.LowMana[95]} > 0
song2=Aria of Pli Xin Liako^27^1
song3=Blade of Vesagran^180^${Me.Combat}
song4=Ecliptic Psalm^60^${Me.Combat} && (${Target.PctHPs} > 50 || ${Target.Named} || ${Me.XTarget} > 1)
song6=Unified Phoenix Feather^30^(!${Group} || ${SpawnCount[group radius 250]}==${Group.GroupSize}) && !${Me.Song[Grace of Unity].ID} && ${Me.CombatState.Equal[COMBAT]} && ${Me.PctEndurance} < 95
song7=Shak Dathor's Chant of Flame^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
song8=Sylra Fris' Chant of Frost^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
song9=Cruor's Chant of Poison^30^${Me.Combat} && ${Target.Type.Equal[NPC]} && (${Target.PctHPs} > 40 || ${Target.Named})
songIF=!${Me.Invis}

[MQ2Medley-med]
song1=Zelinstein's Lively Crescendo^45^1
song2=Pulse of Nikolas^30^1
song3=Chorus of Shei Vinitras^30^1
songIF=!${Me.Invis}

[MQ2Medley-tank]
song1=Xetheg's Spry Sonata^30^1
song2=Aria of Pli Xin Liako^27^1
song3=Blade of Vesagran^180^${Me.Combat}
song4=War March of Centien Xi Va Xakra^30^1
song5=Unified Phoenix Feather^30^(!${Group} || ${SpawnCount[group radius 250]}==${Group.GroupSize}) && !${Me.Song[Grace of Unity].ID} && ${Me.CombatState.Equal[COMBAT]} && ${Me.PctEndurance} < 95
song6=Shojralen's Song of Suffering^24^1
song7=Ecliptic Psalm^60^${Me.Combat} && (${Target.PctHPs} > 50 || ${Target.Named} || ${Me.XTarget} > 1)
song8=Zelinstein's Lively Crescendo^30^${Group.LowMana[95]} > 0
songIF=!${Me.Invis}
