#TODO

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

You'll need to move MQ2Bard.dll into your MQ/plugins directory, restart MQ, then /plugin load MQ2Bard

#Burns
Burns are all hard-coded at the moment.  New ones are simple enough to add, but
do need to be placed in the code itself rather than config. (class.initBurns)

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

