	#NOTES
	class.spellRotations = {melee={},caster={},meleedot={}, med={}, downtime={}}
	 class.medleyRunning == 'none'

#TODO
- Add UseSelos option/check
- Turn off medley when pausing (?maybe)
- Add /twist off alias for /relocate and other things expecting mq2twist
 
 https://www.redguides.com/community/threads/cwtn-mode-reference-chart.77526/
 - especially make sure the modes for taunt/ sits down works
 

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
