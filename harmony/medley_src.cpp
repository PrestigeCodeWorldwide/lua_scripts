







#include <mq/Plugin.h>

PreSetup("MQ2Medley");
PLUGIN_VERSION(1.07);

#define PLUGIN_MSG "\arMQMedley\au:: "

constexpr int MAX_MEDLEY_SIZE = 30;

class SongData
{
public:
	enum SpellType {
		SONG = 1,
		ITEM = 2,
		AA = 3,
		NOT_FOUND = 4
	};

	std::string name;
	SpellType type;
	bool once;
	uint32_t castTimeMs;
	unsigned int targetID;
	std::string durationExp;
	std::string conditionalExp;
	std::string targetExp;
public:
	SongData(std::string spellName, SpellType spellType, uint32_t spellCastTimeMs);

	bool isReady();
	double evalDuration();
	bool evalCondition();
	DWORD evalTarget();
};

const SongData nullSong = SongData("", SongData::NOT_FOUND, 0);

bool MQ2MedleyEnabled = false;
uint32_t castPadTimeMs = 300;
std::list<SongData> medley;
std::string medleyName;

std::map<std::string, uint64_t > songExpires;

SongData currentSong = nullSong;
boolean bWasInterrupted = false;
uint64_t CastDue = 0;
PSPAWNINFO TargetSave = nullptr;

bool bTwist = false;

bool quiet = false;
bool DebugMode = false;
bool Initialized = false;
char SongIF[MAX_STRING] = "";

void resetTwistData()
{
	medley.clear();
	medleyName = "";

	currentSong = nullSong;
	bWasInterrupted = false;

	bTwist = false;
	SongIF[0] = 0;
	WritePrivateProfileString("MQ2Medley", "Playing", "0", INIFileName);
	WritePrivateProfileString("MQ2Medley", "Medley", "", INIFileName);
}

double getTimeTillQueueEmpty()
{
	double time = 0.0;
	boolean isOnceQueued = false;

	for (auto song = medley.begin(); song != medley.end(); song++) {
		if (song->once) {
			isOnceQueued = true;
			time += castPadTimeMs;
			time += song->castTimeMs;
		}
	}

	if (currentSong.once || isOnceQueued) {

		time += CastDue - MQGetTickCount64();
	}

	return time;
}

void Evaluate(char *zOutput, char *zFormat, ...) {

	va_list vaList;
	va_start(vaList, zFormat);
	vsprintf_s(zOutput, MAX_STRING, zFormat, vaList);

	ParseMacroData(zOutput,MAX_STRING);

}

int GetItemCastTime(const std::string& ItemName)
{
	char zOutput[MAX_STRING] = { 0 };
	sprintf_s(zOutput, "${FindItem[=%s].CastTime}", ItemName.c_str());
	ParseMacroData(zOutput, MAX_STRING);
	DebugSpew("MQ2Medley::GetItemCastTime ${FindItem[=%s].CastTime} returned=%s", ItemName.c_str(), zOutput);
	return GetIntFromString(zOutput, -1);
}

int GetAACastTime(const std::string& AAName)
{
	char zOutput[MAX_STRING] = { 0 };
	sprintf_s(zOutput, "${Me.AltAbility[%s].Spell.CastTime}", AAName.c_str());
	ParseMacroData(zOutput, MAX_STRING);
	DebugSpew("MQ2Medley::GetAACastTime ${Me.AltAbility[%s].Spell.CastTime} returned=%s", AAName.c_str(), zOutput);
	return GetIntFromString(zOutput, -1);
}

void MQ2MedleyDoCommand(PSPAWNINFO pChar, PCHAR szLine)
{
	DebugSpew("MQ2Medley::MQ2MedleyDoCommand(pChar, %s)", szLine);
	HideDoCommand(pChar, szLine, FromPlugin);
}

int GemCastTime(const std::string& spellName)
{
	ItemPtr n;

	for (int i = 0; i < NUM_SPELL_GEMS; i++)
	{

		PSPELL pSpell = GetSpellByID(GetPcProfile()->MemorizedSpells[i]);
		if (pSpell && starts_with(pSpell->Name, spellName)) {
			const float mct = static_cast<float>(GetCastingTimeModifier(pSpell) + GetFocusCastingTimeModifier(pSpell, n, false) + pSpell->CastTime);
			if (mct < 0.50f * static_cast<float>(pSpell->CastTime))
				return static_cast<int>(0.50 * (pSpell->CastTime));

			return static_cast<int>(mct);
		}
	}

	return -1;
}




SongData getSongData(const char* name)
{
	std::string spellName = name;

	const int spellNum = GetIntFromString(name, 0);
	if (spellNum>0 && spellNum <= NUM_SPELL_GEMS) {
		DebugSpew("MQ2Medley::TwistCommand Parsing gem %d", spellNum);
		PSPELL pSpell = GetSpellByID(GetPcProfile()->MemorizedSpells[spellNum - 1]);
		if (pSpell) {
			spellName = pSpell->Name;
		}
		else {
			WriteChatf(PLUGIN_MSG "\arInvalid spell number specified (\ay%s\ar) - ignoring.", name);
			return nullSong;
		}
	}

	int castTime = GemCastTime(spellName);
	if (castTime >= 0)
	{
		if (castTime == 0) {

			castTime = 100;
		}
		return SongData(spellName, SongData::SONG, castTime);
	}

	castTime = GetItemCastTime(spellName);
	if (castTime >= 0)
	{
		return SongData(spellName, SongData::ITEM, castTime);
	}

	castTime = GetAACastTime(spellName);
	if (castTime >= 0)
	{
		return SongData(spellName, SongData::AA, castTime);
	}

	return nullSong;
}

int32_t doCast(const SongData& SongTodo)
{
	DebugSpew("MQ2Medley::doCast(%s) ENTER", SongTodo.name.c_str());

	char szTemp[MAX_STRING] = { 0 };
	if (GetCharInfo())
	{
		if (GetCharInfo()->pSpawn)
		{
			switch (SongTodo.type) {
			case SongData::SONG:
				for (int i = 0; i < NUM_SPELL_GEMS; i++)
				{
					PSPELL pSpell = GetSpellByID(GetPcProfile()->MemorizedSpells[i]);
					if (pSpell && starts_with(pSpell->Name, SongTodo.name)) {
						int gemNum = i + 1;

						if (!SongTodo.targetID) {

						}
						else if (PSPAWNINFO Target = (PSPAWNINFO)GetSpawnByID(SongTodo.targetID)) {
							TargetSave = pTarget;
							pTarget = Target;
							DebugSpew("MQ2Medley::doCast - Set target to %d", Target->SpawnID);
						}
						else {
							WriteChatf("MQ2Medley::doCast - cannot find targetID=%d for to cast \"%s\", SKIPPING", SongTodo.targetID, SongTodo.name.c_str());
							return -1;
						}

						sprintf_s(szTemp, "/multiline ; /stopsong ; /cast %d", gemNum);
						MQ2MedleyDoCommand(GetCharInfo()->pSpawn, szTemp);

						return SongTodo.castTimeMs;
					}
				}
				WriteChatf("MQ2Medley::doCast - could not find \"%s\" to cast, SKIPPING", SongTodo.name.c_str());

				return -1;
			case SongData::ITEM:
				DebugSpew("MQ2Medley::doCast - Next Song (Casting Item  \"%s\")", SongTodo.name.c_str());
				sprintf_s(szTemp, "/multiline ; /stopsong ; /cast item \"%s\"", SongTodo.name.c_str());
				MQ2MedleyDoCommand(GetCharInfo()->pSpawn, szTemp);

				return SongTodo.castTimeMs;
			case SongData::AA:
				DebugSpew("MQ2Medley::doCast - Next Song (Casting AA  \"%s\")", SongTodo.name.c_str());
				sprintf_s(szTemp, "/multiline ; /stopsong ; /alt act ${Me.AltAbility[%s].ID}", SongTodo.name.c_str());
				MQ2MedleyDoCommand(GetCharInfo()->pSpawn, szTemp);

				return SongTodo.castTimeMs;
			default:

				WriteChatf("MQ2Medley::doCast - unsupported type %d for \"%s\", SKIPPING", SongTodo.type, SongTodo.name.c_str());
				return -1;
			}
		}
	}
	return -1;
}

void Update_INIFileName(PCHARINFO pCharInfo) {
	sprintf_s(INIFileName, "%s\\%s_%s.ini", gPathConfig, GetServerShortName(), pCharInfo->Name);
}

void Load_MQ2Medley_INI_Medley(PCHARINFO pCharInfo, const std::string& medleyNameIni);
void Load_MQ2Medley_INI(PCHARINFO pCharInfo)
{
	char szTemp[MAX_STRING] = { 0 };

	Update_INIFileName(pCharInfo);

	castPadTimeMs = GetPrivateProfileInt("MQ2Medley", "Delay", 3, INIFileName) * 100;

	WritePrivateProfileInt("MQ2Medley", "Delay", castPadTimeMs/100, INIFileName);
	quiet = GetPrivateProfileInt("MQ2Medley", "Quiet", 0, INIFileName) ? 1 : 0;
	WritePrivateProfileInt("MQ2Medley", "Quiet", quiet, INIFileName);
	DebugMode = GetPrivateProfileInt("MQ2Medley", "Debug", 1, INIFileName) ? 1 : 0;
	WritePrivateProfileInt("MQ2Medley", "Debug", DebugMode, INIFileName);
	GetPrivateProfileString("MQ2Medley", "Medley", "", szTemp, MAX_STRING, INIFileName);
	if (szTemp[0] != 0)
	{
		Load_MQ2Medley_INI_Medley(pCharInfo, szTemp);
		bTwist = GetPrivateProfileInt("MQ2Medley", "Playing", 1, INIFileName) ? 1 : 0;
	}
}

void Load_MQ2Medley_INI_Medley(PCHARINFO pCharInfo, const std::string& medleyNameIni)
{
	char szTemp[MAX_STRING] = { 0 };
	char *pNext;

	medley.clear();
	Update_INIFileName(pCharInfo);

	std::string iniSection = "MQ2Medley-" + medleyNameIni;
	for (int i = 0; i < MAX_MEDLEY_SIZE; i++)
	{
		std::string iniKey = "song" + std::to_string(i + 1);
		if (GetPrivateProfileString(iniSection.c_str(), iniKey.c_str(), "", szTemp, MAX_STRING, INIFileName))
		{
			SongData medleySong = nullSong;

			char *p = strtok_s(szTemp, "^", &pNext);
			if (p)
			{
				medleySong = getSongData(p);
				if (medleySong.type == SongData::NOT_FOUND) {
					WriteChatf("MQ2Medley::loadMedley - [%s] could not find song named \"%s\"", medleyNameIni.c_str(), p);
					continue;
				}
				if (p = strtok_s(nullptr, "^",&pNext))
				{
					medleySong.durationExp = p;
					if (p = strtok_s(nullptr, "^", &pNext))
					{
						medleySong.conditionalExp = p;
						if (p = strtok_s(nullptr, "^", &pNext))
						{
							medleySong.targetExp = p;
						}
					}
				}
			}

			if (medleySong.type != SongData::NOT_FOUND)
			{
				if (!quiet) WriteChatf("MQ2Medley::loadMedley - [%s] adding Song %s^%s^%s", medleyNameIni.c_str(), medleySong.name.c_str(), medleySong.durationExp.c_str(), medleySong.conditionalExp.c_str());
				medley.emplace_back(medleySong);
			}
		}
	}
	WriteChatf("MQ2Medley::loadMedley - [%s] %d song Medley loaded", medleyNameIni.c_str(), static_cast<int>(medley.size()));
	GetPrivateProfileString(iniSection.c_str(), "SongIF", "", SongIF, MAX_STRING, INIFileName);
}

void StopTwistCommand(PSPAWNINFO pChar, PCHAR szLine)
{
	char szTemp[MAX_STRING] = { 0 };
	GetArg(szTemp, szLine, 1);
	bTwist = false;
	currentSong = nullSong;
	MQ2MedleyDoCommand(pChar, "/stopsong");
	if (_strnicmp(szTemp, "silent", 6))
		WriteChatf(PLUGIN_MSG "\atStopping Medley");
	WritePrivateProfileInt("MQ2Medley", "Playing", bTwist, INIFileName);
}

void DisplayMedleyHelp() {
	WriteChatf("\arMQ2Medley \au- \atSong Scheduler - read documentation online");
}

void MedleyCommand(PSPAWNINFO pChar, PCHAR szLine)
{
	char szTemp[MAX_STRING] = { 0 }, szTemp1[MAX_STRING] = { 0 };

	int argNum = 1;
	GetArg(szTemp, szLine, argNum);

	if ((!medley.empty() && (!strlen(szTemp)) || !_strnicmp(szTemp, "start", 5))) {
		GetArg(szTemp1, szLine, 2);
		if (_strnicmp(szTemp1, "silent", 6))
			WriteChatf(PLUGIN_MSG "\atStarting Twist.");
		bTwist = true;
		CastDue = 0;
		WritePrivateProfileInt("MQ2Medley", "Playing", bTwist, INIFileName);
		return;
	}

	if (!_strnicmp(szTemp, "debug", 5)) {
		DebugMode = !DebugMode;
		WriteChatf(PLUGIN_MSG "\atDebug mode is now %s\ax.", DebugMode ? "\ayON" : "\agOFF");
		WritePrivateProfileInt("MQ2Medley", "Debug", DebugMode, INIFileName);
		return;
	}

	if (!_strnicmp(szTemp, "stop", 4) || !_strnicmp(szTemp, "end", 3) || !_strnicmp(szTemp, "off", 3)) {
		GetArg(szTemp1, szLine, 2);
		if (_strnicmp(szTemp1, "silent", 6))
			StopTwistCommand(pChar, szTemp);
		else
			StopTwistCommand(pChar, szTemp1);
		return;
	}

	if (!_strnicmp(szTemp, "reload", 6) || !_strnicmp(szTemp, "load", 4)) {
		WriteChatf(PLUGIN_MSG "\atReloading INI Values.");
		Load_MQ2Medley_INI(GetCharInfo());
		return;
	}

	if (!_strnicmp(szTemp, "delay", 5)) {
		GetArg(szTemp, szLine, 2);
		if (strlen(szTemp)) {
			int delay = GetIntFromString(szTemp, 0);
			if (delay < 0)
			{
				WriteChatf(PLUGIN_MSG "\ayWARNING: \arDelay cannot be less than 0, setting to 0");
				delay = 0;
			}
			castPadTimeMs = delay * 100;
			Update_INIFileName(GetCharInfo());
			WritePrivateProfileInt("MQ2Medley", "Delay", delay, INIFileName);
			WriteChatf(PLUGIN_MSG "\atSet delay to \ag%d\at, INI updated.", delay);
		}
		else
			WriteChatf(PLUGIN_MSG "\atDelay \ag%d\at.", castPadTimeMs/100);
		return;
	}

	if (!_strnicmp(szTemp, "quiet", 5)) {
		quiet = !quiet;
		WritePrivateProfileInt("MQ2Medley", "Quiet", quiet, INIFileName);
		WriteChatf(PLUGIN_MSG "\atNow being %s\at.", quiet ? "\ayquiet" : "\agnoisy");
		return;
	}

	if (!_strnicmp(szTemp, "clear", 5)) {
		resetTwistData();
		StopTwistCommand(pChar, szTemp);
		if (!quiet)
			WriteChatf(PLUGIN_MSG "\ayMedley Cleared.");
		return;
	}

	if (!strlen(szTemp) || !_strnicmp(szTemp, "help", 4)) {
		DisplayMedleyHelp();
		return;
	}

	if (!_strnicmp(szTemp, "queue", 4) || !_strnicmp(szTemp, "once", 4)) {
		WriteChatf(PLUGIN_MSG "\ayAdding to once queue");
		argNum++;

		GetArg(szTemp, szLine, argNum++);
		if (!strlen(szTemp)) {
			WriteChatf(PLUGIN_MSG "\atqueue requires spell/item/aa to cast", szTemp);
			return;
		}
		SongData songData = getSongData(szTemp);
		if (songData.type == SongData::NOT_FOUND) {
			WriteChatf(PLUGIN_MSG "\atUnable to find spell for \"%s\", skipping", szTemp);
			return;
		}

		do {
			GetArg(szTemp, szLine, argNum++);
			if (szTemp[0] == 0) {
				break;
			}
			else if (!_strnicmp(szTemp, "-targetid|", 10)) {
				songData.targetID = GetIntFromString(&szTemp[10], 0);
				DebugSpew("MQ2Medley::TwistCommand  - queue \"%s\" targetid=%d", songData.name.c_str(), songData.targetID);
			}
			else if (!_strnicmp(szTemp, "-interrupt", 10)) {
				currentSong = nullSong;
				CastDue = 0;
				MQ2MedleyDoCommand(pChar, "/stopsong");
			}

		} while (true);
		songData.once = true;

		DebugSpew("MQ2Medley::TwistCommand  - altQueue.push_back(%s);", songData.name.c_str());
		
		medley.push_front(songData);
		return;
	}

	if (strlen(szTemp)) {
		WriteChatf(PLUGIN_MSG "\atLoading medley \"%s\"", szTemp);
		medleyName = szTemp;
		WritePrivateProfileString("MQ2Medley", "Medley", szTemp, INIFileName);
		Load_MQ2Medley_INI_Medley(GetCharInfo(), medleyName);
		bTwist = true;
		WritePrivateProfileInt("MQ2Medley", "Playing", bTwist, INIFileName);
		return;
	}
	else if (!medley.empty()) {
		WriteChatf(PLUGIN_MSG "\atResuming medley \"%s\"", medleyName.c_str());
		bTwist = true;
		WritePrivateProfileInt("MQ2Medley", "Playing", bTwist, INIFileName);
	}
	else {
		WriteChatf(PLUGIN_MSG "\atNo medley defined");
	}
}

bool CheckCharState()
{
	if (!bTwist)
		return false;

	if (GetCharInfo()) {
		if (!GetCharInfo()->pSpawn)
			return false;
		if (GetCharInfo()->Stunned == 1)
			return false;
		switch (GetCharInfo()->standstate) {
		case STANDSTATE_SIT:

			return false;
		case STANDSTATE_FEIGN:
			MQ2MedleyDoCommand(GetCharInfo()->pSpawn, "/stand");
			return false;
		case STANDSTATE_DEAD:
			WriteChatf(PLUGIN_MSG "\ayStopping Twist.");

			return false;
		default:
			break;
		}
		if (InHoverState()) {

			return false;
		}
	}

	return true;
}

class MQ2MedleyType *pMedleyType = 0;

class MQ2MedleyType : public MQ2Type
{
private:
	char szTemp[MAX_STRING] = { 0 };
public:
	enum MedleyMembers {
		Medley = 1,
		TTQE = 2,
		Tune = 3,
		Active
	};

	MQ2MedleyType() :MQ2Type("Medley") {
		TypeMember(Medley);
		TypeMember(TTQE);
		TypeMember(Tune);
		TypeMember(Active);
	}

	virtual bool GetMember(MQVarPtr VarPtr, const char* Member, char* Index, MQTypeVar& Dest) override {
		MQTypeMember* pMember = MQ2MedleyType::FindMember(Member);
		if (!pMember)
			return false;
		switch (pMember->ID) {
			case Medley:
				
				sprintf_s(szTemp, "%s", medleyName.c_str());

				Dest.Ptr = szTemp;
				Dest.Type = mq::datatypes::pStringType;
				return true;
			case TTQE:
				
				Dest.Double = getTimeTillQueueEmpty();
				Dest.Type = mq::datatypes::pDoubleType;
				return true;
			case Tune:
				
				Dest.Int = 0;
				Dest.Type = mq::datatypes::pIntType;
				return true;
			case Active:
				
				Dest.Int = bTwist;
				Dest.Type = mq::datatypes::pBoolType;
				return true;
			default:
				break;
		}
		return false;
	}

	bool ToString(MQVarPtr VarPtr, char* Destination) override
	{
		strcpy_s(Destination, MAX_STRING, bTwist ? "TRUE" : "FALSE");
		return true;
	}
};

bool dataMedley(const char* szIndex, MQTypeVar& Dest)
{
	Dest.DWord = 1;
	Dest.Type = pMedleyType;
	return true;
}

PLUGIN_API void InitializePlugin()
{
	DebugSpewAlways("Initializing MQ2Medley");
	AddCommand("/medley", MedleyCommand, 0, 1, 1);
	AddMQ2Data("Medley", dataMedley);
	pMedleyType = new MQ2MedleyType;
	WriteChatf("\atMQ2Medley \agv%1.2f \ax loaded.", MQ2Version);
}

PLUGIN_API void ShutdownPlugin()
{
	DebugSpewAlways("MQ2Medley::Shutting down");
	RemoveCommand("/medley");
	RemoveMQ2Data("Medley");
	delete pMedleyType;
}

const SongData scheduleNextSong()
{
	uint64_t currentTickMs = MQGetTickCount64();

	if (DebugMode) WriteChatf("MQ2Medley::scheduleNextSong - currentTickMs=%I64u", currentTickMs);
	SongData * stalestSong = nullptr;
	for (auto song = medley.begin(); song != medley.end(); song++)
	{
		if (!song->isReady()) {
			DebugSpew("MQ2Medley::scheduleNextSong skipping[%s] (not ready)", song->name.c_str());
			continue;
		}
		if (!song->evalCondition()) {
			DebugSpew("MQ2Medley::scheduleNextSong skipping[%s] (condition not met)", song->name.c_str());
			continue;
		}

		if (song->once) {
			SongData nextSong = *song;
			medley.erase(song);
			return nextSong;
		}

		if (!stalestSong)
			stalestSong = &(*song);

		uint64_t startCastByMs = songExpires[song->name] - song->castTimeMs - 3000;
		if (DebugMode) WriteChatf("MQ2Medley::scheduleNextSong time till need to cast %s: %I64d ms", song->name.c_str(), startCastByMs - currentTickMs);

		if (startCastByMs  < currentTickMs)
			return *song;

		if (songExpires[song->name] < songExpires[stalestSong->name])
			stalestSong = &(*song);
	}

	if (stalestSong)
	{
		if (DebugMode) WriteChatf("MQ2Medley::scheduleNextSong no priority song found, returning stalest song: %s", stalestSong->name.c_str());
		return *stalestSong;
	}
	else {
		if (!quiet) WriteChatf(PLUGIN_MSG "\atFAILED to schedule a song, no songs ready or conditions not met");
		return nullSong;
	}
}

PLUGIN_API void OnPulse()
{
	char szTemp[MAX_STRING] = { 0 };

	if (!MQ2MedleyEnabled || !CheckCharState())
		return;

	if (medley.empty())
		return;

	if (TargetSave) {

		DebugSpew("MQ2Medley::pulse - restoring target to SpawnID %d", TargetSave->SpawnID);
		pTarget = TargetSave;
		TargetSave = nullptr;

	}

	if (pCastingWnd && pCastingWnd->IsVisible()) {

		return;
	}

	if (SongIF[0] != 0)
	{
		Evaluate(szTemp, "${If[%s,1,0]}", SongIF);
		if (DebugMode) WriteChatf(PLUGIN_MSG "\atOnPulse SongIF[%s]=>[%s]=%d", SongIF, szTemp, GetIntFromString(szTemp, 0));
		if (GetIntFromString(szTemp, 0) == 0)
			return;
	}

	if (MQGetTickCount64() > CastDue) {
		DebugSpew("MQ2Medley::Pulse - time for next cast");
		if (bWasInterrupted && currentSong.type != SongData::NOT_FOUND && currentSong.isReady())
		{
			bWasInterrupted = false;
			if (!quiet) WriteChatf("MQ2Medley::OnPulse Spell inturrupted - recast it");

		}
		else {
			if (bWasInterrupted)
			{
				if (!quiet) WriteChatf("MQ2Medley::OnPulse Spell inturrupted - spell not ready skip it");
				bWasInterrupted = false;
			}
			if (currentSong.type != SongData::NOT_FOUND)
			{

				if (!currentSong.once)
					songExpires[currentSong.name] = MQGetTickCount64() + (uint32_t)(currentSong.evalDuration() * 1000);
			}
			if (!medley.empty())
			{
				currentSong = scheduleNextSong();
				if (currentSong.type == 4) return;
				if (!quiet) WriteChatf(PLUGIN_MSG "\atScheduled: %s", currentSong.name.c_str());
				if (currentSong.targetExp.length() > 0)
					currentSong.targetID = currentSong.evalTarget();
			}
		}

		int32_t castTimeMs = doCast(currentSong);

		if (DebugMode) WriteChatf("MQ2Medley::OnPulse - casting time for %s - %d ms", currentSong.name.c_str(), castTimeMs);
		if (castTimeMs != -1)
		{

			CastDue = MQGetTickCount64() + castTimeMs + castPadTimeMs;
		}
		else {
			DebugSpew("MQ2Medley::OnPulse - cast failed for %s", currentSong.name.c_str());
			currentSong = nullSong;
		}

		DebugSpew("MQ2Medley::OnPulse - exit handling new song: %s", currentSong.name.c_str());
	}
}

PLUGIN_API bool OnIncomingChat(const char* Line, DWORD Color)
{
	if (!bTwist || !MQ2MedleyEnabled)
		return false;

	if ((strstr(Line, "You miss a note, bringing your ") && strstr(Line, " to a close!")) ||
		!strcmp(Line, "You haven't recovered yet...") ||
		(strstr(Line, "Your ") && strstr(Line, " spell is interrupted."))) {
		DebugSpew("MQ2Medley::OnIncomingChat - Song Interrupt Event: %s", Line);
		bWasInterrupted = true;
		CastDue = 0;
	} else if (!strcmp(Line, "You can't cast spells while stunned!")) {
		DebugSpew("MQ2Medley::OnIncomingChat - Song Interrupt Event (stun)");
		bWasInterrupted = true;

		CastDue = MQGetTickCount64() + 10;
	}
	return false;
}

PLUGIN_API void SetGameState(int GameState)
{
	DebugSpew("MQ2Medley::SetGameState()");
	if (GameState == GAMESTATE_INGAME) {
		MQ2MedleyEnabled = true;
		PCHARINFO pCharInfo = GetCharInfo();
		if (!Initialized && pCharInfo) {
			Initialized = true;
			Load_MQ2Medley_INI(pCharInfo);
		}
	}
	else {
		if (GameState == GAMESTATE_CHARSELECT)
			Initialized = false;
		MQ2MedleyEnabled = false;
	}
}

SongData::SongData(std::string spellName, SpellType spellType, uint32_t spellCastTime) {
	name = spellName;
	type = spellType;
	castTimeMs = spellCastTime;
	durationExp = "180";
	targetID = 0;
	conditionalExp = "1";
	targetExp = "";
	once = false;
}

bool SongData::isReady() {
	char zOutput[MAX_STRING] = { 0 };
	switch (type) {
	case SongData::SONG:
		for (int i = 0; i < NUM_SPELL_GEMS; i++)
		{
			PSPELL pSpell = GetSpellByID(GetPcProfile()->MemorizedSpells[i]);
			if (pSpell && starts_with(pSpell->Name, name))
				return GetSpellGemTimer(i) == 0;
		}
		return false;
	case SongData::ITEM:
		sprintf_s(zOutput, "${FindItem[=%s].Timer}", name.c_str());
		ParseMacroData(zOutput,MAX_STRING);
		DebugSpew("MQ2Medley::SongData::IsReady() ${FindItem[=%s].Timer} returned=%s", name.c_str(), zOutput);

		if (!_stricmp(zOutput, "null"))
			return false;
		return GetIntFromString(zOutput, 0) == 0;
	case SongData::AA:
		sprintf_s(zOutput, "${Me.AltAbilityReady[%s]}", name.c_str());
		ParseMacroData(zOutput,MAX_STRING);
		DebugSpew("MQ2Medley::SongData::IsReady() ${Me.AltAbilityReady[%s]} returned=%s", name.c_str(), zOutput);
		return _stricmp(zOutput, "TRUE") == 0;
	default:
		WriteChatf("MQ2Medley::SongData::isReady - unsupported type %d for \"%s\", SKIPPING", type, name.c_str());
		return false;
	}
}

double SongData::evalDuration() {
	char zOutput[MAX_STRING] = { 0 };
	sprintf_s(zOutput, "${Math.Calc[%s]}", durationExp.c_str());
	ParseMacroData(zOutput,MAX_STRING);
	if (DebugMode) WriteChatf("MQ2Medley::SongData::evalDuration() [%s] returned=%s", conditionalExp.c_str(), zOutput);

	return GetDoubleFromString(zOutput, 0.0);
}

bool SongData::evalCondition() {
	char zOutput[MAX_STRING] = { 0 };
	sprintf_s(zOutput, "${Math.Calc[%s]}", conditionalExp.c_str());
	ParseMacroData(zOutput,MAX_STRING);

	if (DebugMode) WriteChatf("MQ2Medley::SongData::evalCondition(%s) [%s] returned=%s", name.c_str(), conditionalExp.c_str(), zOutput);

	double result = GetDoubleFromString(zOutput, 0.0);
	return result != 0.0;
}

DWORD SongData::evalTarget() {
	char zOutput[MAX_STRING] = { 0 };
	sprintf_s(zOutput, "${Math.Calc[%s]}", targetExp.c_str());
	ParseMacroData(zOutput,MAX_STRING);
	if (DebugMode) WriteChatf("MQ2Medley::SongData::evalTarget(%s) [%s] returned=%s", name.c_str(), targetExp.c_str(), zOutput);

	const DWORD result = GetIntFromString(zOutput, 0);
	return result;
}
