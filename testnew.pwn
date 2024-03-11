#include <a_samp>
#include <sscanf2>
#include <dc_cmd>
#include <mxINI>

#define KeyDown(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define KeyUp(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

// gravity
#if !defined GetGravity
native Float:GetGravity();
#endif

// ************************************
// TEXT COLORS
#define TEXT_COLOR_WHITE 0xFFFFFFAA
#define TEXT_COLOR_BLACK 0x00000000
#define TEXT_COLOR_BLUE 0x0000BBAA
#define TEXT_COLOR_DARKBLUE 0x300FFAAB
#define TEXT_COLOR_RED 0xAA3333AA
#define TEXT_COLOR_DARKRED 0x660000AA
#define TEXT_COLOR_GREY 0xAFAFAFAA
#define TEXT_COLOR_YELLOW 0xFFFF00AA
#define TEXT_COLOR_ORANGE 0xFF9900AA
#define TEXT_COLOR_GREEN 0x33AA33AA
#define TEXT_COLOR_DARKGREEN 0x12900BBF
#define TEXT_COLOR_ORANGE 0xFF9900AA
#define TEXT_COLOR_SYSTEM 0xEFEFF7AA

// ************************************
// CAR TYPES 
#define	SHAXSIY 500
#define	KUCHA 501
#define	AVTOMAKTAB 502
#define TAXI 503
#define	POLITSIYA 504
#define	TEZYORDAM 505
#define	XECHKIM 506
#define ANIQLANMAGAN 507

// ************************************
// FORWARDS
forward setCurretTime();
forward toggleGruzchikPicup();
forward toggleAvtomaktabPicup();
forward ActorTalkHandsOff(actorid);
forward TalkHandsOff(playerid);

// ************************************
// PLAYER INFO
enum player
{
	ID,
	NAME[MAX_PLAYER_NAME],
	PASSWORD[66],
	SKIN,
	MONEY,
	CAR,
	ADMIN,
	PRAVA,
	PHONE,
	Float:LASTX,
	Float:LASTY,
	Float:LASTZ,
	Float:LASTA,
	LASTVIRTUALWORLD,
	LASTINTERER
}
new player_info[MAX_PLAYERS][player];


// ************************************
//GPS
enum e_COORD_GPS_INFO
{
     name_gps[30],
     Float:pos_X,
     Float:pos_Y,
     Float:pos_Z
};
static const GPSCoords[4][e_COORD_GPS_INFO] =
{
    {"Avtomaktab", -2045.6704, -88.0934, 35.1641}, 
    {"Hokimiyat", 1476.1597, -1739.5961, 13.5469}, 
    {"LSPD", 1541.0000, -1675.4686, 13.5517}, 
    {"Shifoxona LS", 1178.6862, -1323.6720, 14.1323}
};

// ************************************
// AVTOMAKTAB
enum avtoMaktabCarsInfo
{
	Float:pos_X,
    Float:pos_Y,
    Float:pos_Z,
    Float:pos_A
}
static const avtoMaktabCars[3][avtoMaktabCarsInfo] = {
	{-2065.2224, -85.0000, 35.000, 180.0000},
	{-2069.8948, -85.0000, 35.000, 180.0000},
	{-2074.0603, -85.0000, 35.000, 180.0000}
};
enum avtoMaktabRoadInfo
{
	Float:pos_X,
    Float:pos_Y,
    Float:pos_Z
}
static const avtoMaktabRoad[10][avtoMaktabRoadInfo] = {
	{-2053.8604, -68.0934, 34.8989},
	{-2143.2813, -67.6612, 34.8990},
	{-2165.2637, -0.1823, 34.8989},
	{-2145.5454, 150.0802, 34.8990},
	{-2145.0403, 291.3878, 34.8989},
	{-2036.5712, 318.0920, 34.7427},
	{-2008.4562, 255.8767, 30.2441},
	{-2008.8149, 87.7218, 27.2661},
	{-2008.5677, -36.3716, 34.8629},
	{-2032.1898, -68.9198, 34.8990}
};
new avtoMaktabSI[MAX_PLAYERS] = 0; // status imtihon
new avtoMaktabSp[MAX_PLAYERS] = 0; // status jarayoni
new avtoMaktabPicupId;


// ************************************
// CARS LIST
enum cars_info
{
	cars_name[30],
	id
}
new carsList[24][cars_info] = {
	{"Infernus", 411},
	{"Cheetah", 415},
	{"Turismo", 451},
	{"Hotring", 494},
	{"Hotring A", 502},
	{"Hotring B", 503},
	{"Super GT", 506},
	{"Bullet", 541},
	{"Elegy", 562},
	{"Euros", 587},
	{"Buccanee", 518},
	{"Sentinel", 405},
	{"Sultan", 560},
	{"Taxi", 420},
	{"Cabbie - taxi 2", 438},
	{"Rhino - tank", 432},
	{"Rancher", 489},
	{"Rnchlure - rancher", 505},
	{"Huntley", 579},
	{"Nrg500", 522},
	{"Mtbike", 510},
	{"Cropdust - samolet mini", 512},
	{"Samolet", 519},
	{"Hydra", 520}
};

// ************************************
// GUNS
enum guns_info
{
	name[30],
	id,
	ammos,
	summa
}
new gunsList[17][guns_info] = {
	{"Granade", 16, 5, 500},
	{"Molotov Coctail", 18, 5, 500},
	{"9mm", 22, 50, 1000},
	{"Silenced 9mm", 23, 50, 1200},
	{"Desert Eagle", 24, 50, 2000},
	{"Sawn-off Shotgun", 26, 20, 2500},
	{"Tec-9", 32, 100, 3000},
	{"Micro SMG", 28, 90, 3500},
	{"MP5", 29, 90, 3800},
	{"AK-47", 30, 90, 5000},
	{"M4", 31, 90, 5000},
	{"Sniper Rifle", 34, 15, 5500},
	{"Flamethrower", 37, 350, 6000},
	{"Minigun", 38, 350, 6500},
	{"RPG", 35, 5, 6500},
	{"HS Rocket", 36, 5, 6700},
	{"Parachute", 46, 1, 500}
};

// ************************************
// DIALOG
enum dialog
{
	DLG_LOG,
	DLG_REG,
	DLG_GPS,
	DLG_GRUZCHIK,
	DLG_AVTOMAKTAB,
	DLG_CARS,
	DLG_GUNS,
	DLG_ACTOR,
	DLG_FSTYLE
}

// ************************************
// USTANOVLENNAYA VREMYA DLYA SERVERA
new currentServerHour = 12;


// ************************************
// RABOTA GRUZCHIKA
new GruzPickId;
new GruzRabota[MAX_PLAYERS];
new GruzSkin[MAX_PLAYERS];

// shop
new shopPhonePicId;


// cars info
enum car_params_enum
{
	type, // taksi, avtomaktab, politsiya, abtobus, lichniy
	egasi, // playerid 255 default null
	eshik, // 0 ochiq 1 yopiq
	signalizatsiya, // 0 o'chiq 1 yoniq
	fara // 0 o'chiq 1 yoniq
}
new car_params[MAX_VEHICLES][car_params_enum];


// rabota dalnaboyshika
new StatusRabotiDalnaboyshika[MAX_PLAYERS]; // dalnaboyshik
// Checkpoint
new Fura[2]; // dalnaboyshik
new Pricep[10]; // dalnaboyshik
new Text3D:Pricep3dtext[10]; // dalnaboyshik

// figthing styles
enum e_FightingStyleInfo
{
	fsName[15],
    fsID
}
new fighting_style_info[6][e_FightingStyleInfo] =
{
    {"Obichniy", FIGHT_STYLE_NORMAL},
    {"Boks", FIGHT_STYLE_BOXING},
    {"Kong-fu", FIGHT_STYLE_KUNGFU},
    {"Bez pravil", FIGHT_STYLE_KNEEHEAD},
    {"Grabkick", FIGHT_STYLE_GRABKICK},
    {"Udari loktyom", FIGHT_STYLE_ELBOW}
};

// actors
new actorsMain;

// 3d text
new avto3dTextId;

//==============================[- PICUP ID -]================================
new Picup_Bank_SF_krish;
new Picup_Bank_SF_chiqish;

new Picup_Hokimyat_LS_krish;
new Picup_Hokimyat_LS_chiqish;

new Picup_Bank_LV_krish;
new Picup_Bank_LV_chiqish;

new Picup_Lib_City_ins_krish;
new Picup_Lib_City_ins_chiqish;

main()
{
	print("\n----------------------------------");
	print(" Rz test samp v2");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	// default uylar kirish chiqish picup larini o'chirish
	DisableInteriorEnterExits();

	for(new i; i < MAX_VEHICLES; i++) car_params[i][egasi] = XECHKIM;

	new cars_kucha_1 = CreateVehicle(411, 1780.5786, -1887.4452, 13.1244, 269.9363, -1, -1, 60);
	car_params[cars_kucha_1][type] = KUCHA;
	// 3D text to avto
	avto3dTextId = Create3DTextLabel("{ffa500}[Type: {FFFFFF}ko'cha{ffa500}]\nsss", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(avto3dTextId, cars_kucha_1, 0.0, 0.0, 0.0);

	// avtomaktab
	for(new i; i < sizeof(avtoMaktabCars); i++)
	{
		new carid = CreateVehicle(411, avtoMaktabCars[i][pos_X], avtoMaktabCars[i][pos_Y], avtoMaktabCars[i][pos_Z], avtoMaktabCars[i][pos_A], -1, -1, 60);
		car_params[carid][type] = AVTOMAKTAB;
	}

	// ***************** TOCHKA VXODA *****************
	// gruzchiklik ishi
	GruzPickId = CreatePickup(1275, 23, 1779.5306, -1916.7925, 13.3890); // ishga joylashish kordinatasi x, y, z
	Create3DTextLabel("rabota gruzchika", 0xFFFFFFFF, 1779.5306, -1916.7925, 14.0500, 15, 0); // x, y, z
	// avtomaktab
	avtoMaktabPicupId = CreatePickup(1581, 23, -2031.5508, -117.4373, 1035.1719); // prava
	Create3DTextLabel("imtihonga kirish", 0xFFFFFFFF, -2031.5508, -117.4373, 1035.8000, 10, 0);

	// shop
	// phone
	shopPhonePicId = CreatePickup(330, 23, 1804.1021, -1917.4061, 13.3938);
	Create3DTextLabel("Mobile telefon\n800$", 0xFFFFFFFF, 1804.1021, -1917.4061, 14.5000, 13, 0);

	// set current time
	new hour, minute, second;
	gettime(hour, minute, second);
	currentServerHour = hour;
	SetWorldTime(hour);
	SetTimer("setCurretTime", 900000, true); // 15 m

	// actors
	actorsMain = CreateActor(0, 1771.9491, -1889.7499, 13.5613, 181.2052);
	Create3DTextLabel("Vvedi /actortalk chtobi porovorit", TEXT_COLOR_ORANGE, 1771.9491, -1889.7499, 14.7000, 10, 0);
	CreatePlayer3DTextLabel(1, "hello", TEXT_COLOR_ORANGE, 1771.9491, -1889.7499, 13.5613, 100.0);

	// for(new i; i < GetVehiclePoolSize(); i++)
	// {
	// 	printf("egasi: %d", car_params[i][egasi]);
	// }
	printf("Serverda mavjud mashinalar soni: %d", GetVehiclePoolSize());


	// TEST
	//========================================[Picups]===================================
    //Pickup0 = CreatePickup(1318, 1, X, Y, Z); // strelka

	//============================================[Rabota dalnaboyshik]====================================
	Fura[0] = AddStaticVehicleEx(515,12.1930,-224.1917,6.4553,90.0913,-1,-1,180); // Fura № 1
    AddStaticVehicleEx(515,12.2435,-232.4889,6.4411,89.7957,-1,-1,180); // Fura № 2
    AddStaticVehicleEx(515,12.2912,-240.7080,6.4506,89.8790,-1,-1,180); // Fura № 3
	AddStaticVehicleEx(403,12.8029,-248.9818,6.0362,90.7330,-1,-1,180); // Fura
	AddStaticVehicleEx(403,12.9481,-257.2370,6.0355,90.5530,-1,-1,180); // Fura
	AddStaticVehicleEx(403,12.8305,-265.2685,6.0354,89.7056,-1,-1,180); // Fura
	AddStaticVehicleEx(514,-18.8261,-220.4126,6.0162,175.5331,-1,-1,180); // Fura
	AddStaticVehicleEx(514,-26.6368,-219.4905,6.0159,175.7046,-1,-1,180); // Fura
	Fura[1] = AddStaticVehicleEx(514,-34.4157,-218.6096,6.0108,175.0944,-1,-1,180); // Fura
    Pricep[0] = AddStaticVehicleEx(435,-55.1299,-224.4092,6.0257,266.6206,-1,-1,180); // Pritsep № 1
    Pricep[1] = AddStaticVehicleEx(435,-23.1413,-274.3386,6.0080,180.5373,-1,-1,180); // Pritsep № 2
    Pricep[2] = AddStaticVehicleEx(435,-14.7631,-274.5206,6.0191,180.1252,-1,-1,180); // Pritsep № 3
	Pricep[3] = AddStaticVehicleEx(584,-61.6196,-321.5299,6.0160,270.4092,-1,-1,180); // Pritsep
	Pricep[4] = AddStaticVehicleEx(591,-61.4658,-307.4087,6.0192,270.4079,-1,-1,180); // Pritsep
	Pricep[5] = AddStaticVehicleEx(450,-1.2615,-339.9842,6.0233,89.0408,-1,-1,180); // Pritsep
	Pricep[6] = AddStaticVehicleEx(450,-1.2152,-322.3202,6.0038,89.9523,-1,-1,180); // Pritsep
	Pricep[7] = AddStaticVehicleEx(450,-1.1001,-301.1582,6.0088,89.6910,-1,-1,180); // Pritsep
	Pricep[8] = AddStaticVehicleEx(591,-116.4185,-322.6622,2.0134,179.6741,-1,-1,180); // Pritsep
	Pricep[9] = AddStaticVehicleEx(584,-231.7576,-190.1307,2.0194,259.2906,-1,-1,180); // Pritsep
	Pricep3dtext[0] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Amunitsiya{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[0], Pricep[0], 0.0, 0.0, 0.0);
  	Pricep3dtext[1] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Raznie napitki{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[1], Pricep[1], 0.0, 0.0, 0.0);
  	Pricep3dtext[2] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Odejda{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[2], Pricep[2], 0.0, 0.0, 0.0);
	Pricep3dtext[3] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Benzin{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[3], Pricep[3], 0.0, 0.0, 0.0);
	Pricep3dtext[4] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Zamorojennie produkti{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[4], Pricep[4], 0.0, 0.0, 0.0);
	Pricep3dtext[5] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Sheben{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[5], Pricep[5], 0.0, 0.0, 0.0);
	Pricep3dtext[6] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Pesok{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[6], Pricep[6], 0.0, 0.0, 0.0);
	Pricep3dtext[7] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Izvestnyak{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[7], Pricep[7], 0.0, 0.0, 0.0);
	Pricep3dtext[8] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Zamorojennie produkti{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[8], Pricep[8], 0.0, 0.0, 0.0);
	Pricep3dtext[9] = Create3DTextLabel("{ffa500}[Gruz: {FFFFFF}Benzin{ffa500}]", TEXT_COLOR_ORANGE, 0.0, 0.0, -100.0, 50.0, 0, 1);
	Attach3DTextLabelToVehicle(Pricep3dtext[9], Pricep[9], 0.0, 0.0, 0.0);

	//==============================[- 3D TEXT LAR- ]==============================
    Create3DTextLabel("{26ff26}Bank SF",0xFFFFFFFF, -2055.8582, 454.4940, 35.1719, 40.0, 0);
    Create3DTextLabel("{26ff26}Hokimyat LS",0xFFFFFFFF, 1481.0371, -1770.9315, 18.7958, 40.0, 0); // hokimyat ls krish
    Create3DTextLabel("{26ff26}Hokimyat LS",0xFFFFFFFF, 389.8677, 173.7724, 1008.3828, 20.0, 0); // hokimyat ls chiqish
    Create3DTextLabel("{26ff26}Bank LV",0xFFFFFFFF, 2446.1621, 2376.0876, 12.1635, 40.0, 0);
    //==============================[- PICUP LAR -]================================
    Picup_Bank_SF_krish = CreatePickup(1318, 1, -2055.8582, 454.4940, 35.1719); // Bank SF (Vhod)
    Picup_Bank_SF_chiqish = CreatePickup(1318, 1, 389.8677, 173.7724, 1008.3828); // Bank SF (Vixod)
    Picup_Hokimyat_LS_krish = CreatePickup(1318, 1, 1481.0371, -1770.9315, 18.7958); // Hokimyat LS (Vhod)
	Picup_Hokimyat_LS_chiqish = CreatePickup(1318, 1, 389.8677, 173.7724, 1008.3828); // Hokimyat LS (Vixod)
	Picup_Bank_LV_krish = CreatePickup(1318, 1, 2446.1621, 2376.0876, 12.1635); // Bank LV (Vhod)
    Picup_Bank_LV_chiqish = CreatePickup(1318, 1, 389.8677, 173.7724, 1008.3828); // Bank LV (Vixod)

    Picup_Lib_City_ins_krish = CreatePickup(1318, 1, -777.0350,505.1196,1376.5872); // Liberty city inside (Vhod)
    Picup_Lib_City_ins_chiqish = CreatePickup(1318, 1, -795.0031,489.6939,1376.1953); // Liberty city inside (Vixod)

	return 1;
}

public OnGameModeExit()
{
	DestroyActor(actorsMain);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetSpawnInfo(playerid, NO_TEAM, player_info[playerid][SKIN], 1759.4785, -1896.9556, 13.5617, 268.6882, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	SetPlayerMapIcon(playerid, 0, 1759.4785, -1896.9556, 13.5617, 52, 0, MAPICON_LOCAL);


	GetPlayerName(playerid, player_info[playerid][NAME], MAX_PLAYER_NAME);

	TogglePlayerSpectating(playerid, 1);

	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);
	if(INI == INI_OK)
	{
		showLogin(playerid);
		ini_closeFile(INI);
		return 1;
	}
	else
	{
		showRegister(playerid);
		ini_closeFile(INI);
		return 1;
	}
}


public OnPlayerDisconnect(playerid, reason)
{
	// zapisivaem poslednuyu pozitsiyu
	saveuserLastPos(playerid);
	
	// *************************************************
	// ochishaem dannie
	player_info[playerid][ID] = 0;
	player_info[playerid][NAME] = 0;
	player_info[playerid][PASSWORD] = 0;
	player_info[playerid][SKIN] = 0;
	player_info[playerid][MONEY] = 0;
	player_info[playerid][CAR] = 0;
	player_info[playerid][ADMIN] = 0;
	player_info[playerid][PRAVA] = 0;
	player_info[playerid][PHONE] = 0;
	player_info[playerid][LASTX] = 0;
	player_info[playerid][LASTY] = 0;
	player_info[playerid][LASTZ] = 0;
	player_info[playerid][LASTA] = 0;

	// rabota gruzchika
	GruzRabota[playerid] = 0;
   	GruzSkin[playerid] = 0;

	// avtomaktab
	avtoMaktabSI[playerid] = 0;
    avtoMaktabSp[playerid] = 0;

	// dalnaboyshik
	StatusRabotiDalnaboyshika[playerid] = 0;

	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	// avtomaktab
	avtoMaktabSI[playerid] = 0;
    avtoMaktabSp[playerid] = 0;

    // dalnaboyshik
	StatusRabotiDalnaboyshika[playerid] = 0;

	DisablePlayerCheckpoint(playerid);

	// killer info
	if(killerid != INVALID_PLAYER_ID)  // check valid user
    {
        new day, month, year, hour, minute, second;
        getdate(year, month, day);
        gettime(hour, minute, second);

        new killerName[MAX_PLAYER_NAME], weaponName[24], string[256];
        GetPlayerName(killerid, killerName, sizeof(killerName));
        GetWeaponName(GetPlayerWeapon(killerid), weaponName, sizeof (weaponName));

        format(string, sizeof(string), "Vas ubil {FF0000}%s[%d] {FFFFFF}s pomoshyu: {FF0000}%s. {FFFFFF}Vremya: {FF0000}%d:%d. {FFFFFF}Data: {FF0000}%d:%d:%d.", killerName, killerid, weaponName, hour, minute, day, month, year);
        return SendClientMessage(playerid, 0xFFFFFFFF, string);
    }
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(StatusRabotiDalnaboyshika[killerid] > 0)
	{
		StatusRabotiDalnaboyshika[killerid] = 0;
		if(IsTrailerAttachedToVehicle(vehicleid)) SetVehicleToRespawn(GetVehicleTrailer(vehicleid));
		SetVehicleToRespawn(vehicleid);
		DisablePlayerCheckpoint(killerid);
		SendClientMessage(killerid, -1, "Vi uvolilis s raboti dalnaboyshika");
	}

	if(car_params[vehicleid][egasi] == killerid) DestroyVehicle(vehicleid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new string[300];
	format(string, sizeof(string), "carid: %d | | egasimi: %d", 
		vehicleid,
		car_params[vehicleid][egasi] == playerid ? 1 : 0
	);
	SendClientMessage(playerid, -1, string);


	if(playerid != car_params[vehicleid][egasi])
	{
		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		car_params[vehicleid][signalizatsiya] = 1;
		if(doors == 1)
		{
			SetVehicleParamsEx(vehicleid, engine, lights, 1, doors, bonnet, boot, objective);
			if(car_params[vehicleid][egasi] != XECHKIM) SendClientMessage(car_params[vehicleid][egasi], -1, "Na vashem mashine srabotala signalizatsiya");
			return 1;
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	// tuning 
	new model = GetVehicleModel(vehicleid);
	if(model == 562)
	{
		RemoveVehicleComponent(vehicleid, 1147);
		RemoveVehicleComponent(vehicleid, 1082);
		RemoveVehicleComponent(vehicleid, 1036);
		RemoveVehicleComponent(vehicleid, 1148);
		RemoveVehicleComponent(vehicleid, 1172);
		RemoveVehicleComponent(vehicleid, 1037);
		return 1;
	}

	
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	// 3d text
	if(newstate == PLAYER_STATE_DRIVER)
	{
		if(car_params[GetPlayerVehicleID(playerid)][type] == KUCHA)
		{
			Delete3DTextLabel(avto3dTextId);
		}
	}
	// PROVERKA NA PRAVA
	proverkaNaPrava(playerid, newstate);
	// AVTO TUNING
	avtoTuning(playerid, newstate);
	return 1;
}

stock avtoTuning(playerid, newstate)
{
	if(!isAdmin(playerid)) return 1;
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new model = GetVehicleModel(GetPlayerVehicleID(playerid));
		if(model == 562)
		{
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1147); // spoyler type 2 / 1146 type 1
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1082); // diski import
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1036); // bokovoy 1 - 1036 // 2 1039
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1148); // zadniy bamper / 1 - 1148  2 - 1149
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1172); // peredniy / 1 - 1171 2 - 1172
			AddVehicleComponent(GetPlayerVehicleID(playerid), 1037); // gluitel / 1 - 1034 2 1037
			return SendClientMessage(playerid, -1, "ok!");
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	// dalnaboyshik
	if(StatusRabotiDalnaboyshika[playerid] == 1)
	{
		if(!IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)))
		{
		    SendClientMessage(playerid, TEXT_COLOR_WHITE,"{FF4500}[Informatsiya]: {00FFFF}Vi priehali bez pritsepa i uvolilis s raboti!");
		    StatusRabotiDalnaboyshika[playerid] = 0;
		    DisablePlayerCheckpoint(playerid);
		    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
		    return 1;
		}
		DisablePlayerCheckpoint(playerid);
		TogglePlayerControllable(playerid, 0);
		SendClientMessage(playerid, TEXT_COLOR_WHITE, "{FF4500}[Informatsiya]: {00FFFF}Podojdite kakoe-to vremya poka razgruzyat furu!");
		SetTimerEx("RazgruzFuri", 15000, false, "i", playerid);
	}
	else if(StatusRabotiDalnaboyshika[playerid] == 2)
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
			if(!IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)))
			{
			    SendClientMessage(playerid, TEXT_COLOR_WHITE,"{FF4500}[Informatsiya]: {00FFFF}Vi priehali bez pritsepa i uvolilis s raboti");
			    StatusRabotiDalnaboyshika[playerid] = 0;
			    DisablePlayerCheckpoint(playerid);
			    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			    return 1;
			}
			new string[256];
			new zarplata = 15000 + random(10000);
			format(string, sizeof(string), "{FF4500}[Informatsiya]: {00FFFF}Vi dostavili gruz i poluchili $%d", zarplata);
			SendClientMessage(playerid, TEXT_COLOR_ORANGE, string);
			GivePlayerMoney(playerid, zarplata);
			INI_set_userMoney(playerid, INI_get_userMoney(playerid) + zarplata);
			StatusRabotiDalnaboyshika[playerid] = 0;
		    DisablePlayerCheckpoint(playerid);
		    SetVehicleToRespawn(GetVehicleTrailer(GetPlayerVehicleID(playerid)));
		    return 1;
		}
	}

	// rabota gruzchika
	if(GruzRabota[playerid] == 1)
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Siz yukni oldingiz endi ko'rsatilgan joyga olib boring!");
        DisablePlayerCheckpoint(playerid);
        GruzRabota[playerid] = 2;
        SetPlayerCheckpoint(playerid, 1783.5756, -1926.7511, 13.3893, 1.5); // x, y, z - svoi kordinati
        return 1;
    }
    if(GruzRabota[playerid] == 2)
    {
    	new money = 50; // 50$
        INI_set_userMoney(playerid, INI_get_userMoney(playerid) + money);
        GivePlayerMoney(playerid, money);
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid, 1779.0326, -1927.2537, 13.3886, 1.5); // x, y, z - svoi kordinati
        GruzRabota[playerid] = 1;
        SendClientMessage(playerid, 0xFFFFFFFF, "Siz yukni olib keldingiz endi bsohqa yuk uchun boring!");
        return 1;
    }

    // avtoshkola
    if(avtoMaktabSp[playerid] >= 0 && avtoMaktabSp[playerid] < 10)
    {
    	new newPoz =  avtoMaktabSp[playerid]++;
    	DisablePlayerCheckpoint(playerid);
    	SetPlayerCheckpoint(playerid, avtoMaktabRoad[newPoz][pos_X], avtoMaktabRoad[newPoz][pos_Y], avtoMaktabRoad[newPoz][pos_Z], 5.0);
    	return 1;
    }
    if(avtoMaktabSp[playerid] == 10)
    {
    	DisablePlayerCheckpoint(playerid);
    	avtoMaktabSI[playerid] = 0;
    	avtoMaktabSp[playerid] = 0;

    	if(INI_set_userPrava(playerid)) return SendClientMessage(playerid, TEXT_COLOR_GREEN, "Siz muaffaqiyatli imtihondan otdingiz!");
    	else return SendClientMessage(playerid, TEXT_COLOR_RED, "Sistemada hatolik yuz berdi");
    }
    // default
    DisablePlayerCheckpoint(playerid);
	return 1;
}
// RAZGRUZ FURI
forward RazgruzFuri(playerid);
public RazgruzFuri(playerid)
{
	TogglePlayerControllable(playerid, 1);
	SendClientMessage(playerid, TEXT_COLOR_WHITE,"{FF4500}[Informatsiya]: {00FFFF}Razgruzka furi zavershena...");
    SendClientMessage(playerid, TEXT_COLOR_WHITE,"{FF4500}[Informatsiya]: {00FFFF}Vernite pritsep obrato gde vzyali, tam je vidadut vam zarplatu za reys");
 	StatusRabotiDalnaboyshika[playerid] = 2;
	SetPlayerCheckpoint(playerid, -0.8136, -249.4456, 5.0401, 8.0);
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	// ********** INTERER KRISH CHIQISH PICUP LAR **********
	if(pickupid == Picup_Bank_SF_krish) {}
	if(pickupid == Picup_Bank_SF_chiqish) {}

	if(pickupid == Picup_Hokimyat_LS_krish) {
		SetPlayerPos(playerid, 387.0583, 174.0229, 1008.3828);
		SetPlayerFacingAngle(playerid, 89.3135);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 3);
		// SetPlayerVirtualWorld(playerid, 0);
		return 1;
	}
	if(pickupid == Picup_Hokimyat_LS_chiqish) {
		SetPlayerPos(playerid, 1481.1167, -1768.6155, 18.7958);
		SetPlayerFacingAngle(playerid, 357.1170);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}

	if(pickupid == Picup_Bank_LV_krish) {}
	if(pickupid == Picup_Bank_LV_chiqish) {}

	// _______ Liberty City Inside _______
	if(pickupid == Picup_Lib_City_ins_krish) {
		SetPlayerPos(playerid, -795.1166, 491.0991, 1376.1953);
		SetPlayerFacingAngle(playerid, 351.8007);
		SetCameraBehindPlayer(playerid); // kamera yo'nalishi - o'yinchi qaysi tomonga qarab turishi
		SetPlayerInterior(playerid, 1); // ko'cha - default 0
		return 1;
	}
	if(pickupid == Picup_Lib_City_ins_chiqish) {
		SetPlayerPos(playerid, -775.4847, 504.8583, 1376.5762);
		SetPlayerFacingAngle(playerid, 260.0012);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 1);
		return 1;
	}

	// ******************** GRUZCHIK ISHI ********************
	if(pickupid == GruzPickId)
	{
	    if(GruzRabota[playerid] == 0)
	    {
	    	DestroyPickup(GruzPickId);
	    	SetTimer("toggleGruzchikPicup", 8000, 0);
	        ShowPlayerDialog(playerid, DLG_GRUZCHIK, DIALOG_STYLE_MSGBOX, "{FFFFFF}ishga joylashish", "ishga joylashishni hahlaysizmi", "ha", "bekor qilish");
	    }
	    else
	    {
	    	DestroyPickup(GruzPickId);
	    	SetTimer("toggleGruzchikPicup", 8000, 0);
	        ShowPlayerDialog(playerid, DLG_GRUZCHIK, DIALOG_STYLE_MSGBOX, "{FFFFFF}ishdan chiqish", "Ishdan qishini hahlaysizmi", "ha", "bekor qilish");
	    }
	}

	// ******************** AVTOMAKTAB ********************
	if(pickupid == avtoMaktabPicupId)
	{
		DestroyPickup(avtoMaktabPicupId);
	    SetTimer("toggleAvtomaktabPicup", 8000, 0);
	    if(INI_get_userPrava(playerid)) return SendClientMessage(playerid, TEXT_COLOR_GREEN, "Sizda avtomobil guvohnomasi bor!");
		ShowPlayerDialog(playerid, DLG_AVTOMAKTAB, DIALOG_STYLE_MSGBOX, "{FFFFFF}Pravaga topshirish", "Pravaga topshirish narxi 500$ toshirasizmi?", "ha", "bekor qilish");
		return 1;
	}

	// ******************** SHOP LAR ********************
	// <=| TELEFON |=>
	if(pickupid == shopPhonePicId)
	{
		if(player_info[playerid][PHONE]) return SendClientMessage(playerid, TEXT_COLOR_GREEN, "Sizda telefon mavjud!");
		if(player_info[playerid][MONEY] < 800) return SendClientMessage(playerid, TEXT_COLOR_RED, "Sizda yetarli summa mavjud emas!");
		if(INI_set_userPhone(playerid))
		{
			new money = GetPlayerMoney(playerid) - 800;
			ResetPlayerMoney(playerid);
			GivePlayerMoney(playerid, money);
			INI_set_userMoney(playerid, money);
			return SendClientMessage(playerid, -1, "Siz uyali aloqa sotib oldingiz!");
		}
		return 1;
	}

	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	// beskonechnaya nitro
	if( newkeys == 1 || newkeys == 9 || newkeys == 33 && oldkeys != 1 || oldkeys != 9 || oldkeys != 33)//Нитро
    {
        new Car = GetPlayerVehicleID(playerid), Model = GetVehicleModel(Car);
        switch(Model)
        {
            case 446,432,448,452,424,453,454,461,462,463,468,471,430,472,449,473,481,484,493,495,509,510,521,538,522,523,532,537,570,581,586,590,569,595,604,611: return 0;
        }
        AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
    }

    if(KeyDown(KEY_YES))
    {
    	if(IsPlayerInAnyVehicle(playerid))
	    {
	    	new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);

			if(!engine)
			{
				SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
				return SendClientMessage(playerid, -1, "engine On");
			}
			else
			{
				SetVehicleParamsEx(GetPlayerVehicleID(playerid), 0, lights, alarm, doors, bonnet, boot, objective);
				return SendClientMessage(playerid, -1, "engine Off");
			}
    	}
    	return 1;
    }

    if(KeyDown(KEY_NO))
    {
    	// esli chelovek nahoditsya za rulem
    	if(IsPlayerInAnyVehicle(playerid))
    	{
    		// i yavlyaetsya li igrok vladeltsem etoy mashini
    		if(car_params[GetPlayerVehicleID(playerid)][egasi] == playerid)
    		{
    			// status mashini
    			new engine, lights, alarm, doors, bonnet, boot, objective;
				GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);

				if(!doors)
				{
					SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, 1, bonnet, boot, objective);
					return SendClientMessage(playerid, -1, "Vi zakrili svoyu mashinu!");
				}
				else
				{
					SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, 0, bonnet, boot, objective);
					return SendClientMessage(playerid, -1, "Vi otkrili svoyu mashinu!");
				}
    		}
    		else return SendClientMessage(playerid, -1, "Vi ne mojete zakrit dveri chujoy mashini!");
    	}

    	// dalshe uje esli igrok ne naxoditsya v mashine
    	for(new i; i < MAX_VEHICLES; i++)
    	{
    		// pozitsiya mashini
    		new Float:poz1, Float:poz2, Float:poz3;
    		GetVehiclePos(i, poz1, poz2, poz3);

    		// proveryaem, nahoditsya li igrok v radiuse 2.5m ot mashini
    		if(IsPlayerInRangeOfPoint(playerid, 2.5, poz1, poz2, poz3))
    		{
    			// yavlyaetsya li igrok vladeltsem etoy mashini
    			if(car_params[i][egasi] == playerid)
    			{
    				// status mashini
	    			new engine, lights, alarm, doors, bonnet, boot, objective;
					GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);

					if(!doors)
					{
						SetVehicleParamsEx(i, engine, lights, alarm, 1, bonnet, boot, objective);
						return SendClientMessage(playerid, -1, "Vi zakrili svoyu mashinu!");
					}
					else
					{
						SetVehicleParamsEx(i, engine, lights, alarm, 0, bonnet, boot, objective);
						return SendClientMessage(playerid, -1, "Vi otkrili svoyu mashinu!");
					}
    			}
    			else return SendClientMessage(playerid, -1, "U vas net klyuchi ot etoy mashini!");
    		}
    	}

    	return SendClientMessage(playerid, -1, "V radiuse 2.5m net ryadom s vami mashini!");
	}

	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DLG_LOG:
		{
			if(response)
			{	
				if (!strcmp(player_info[playerid][PASSWORD], inputtext))
				{
					Spawn(playerid);
					return SendClientMessage(playerid, TEXT_COLOR_WHITE, "parol to'g'ri");
				}
				else
				{
					new LoginHeader[100];
					format(LoginHeader, sizeof(LoginHeader),
						"{FFFFFF}Salom %s! avtorizatsiya uchun parolni kiriting", player_info[playerid][NAME]
					);
					ShowPlayerDialog(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "Avtorizatsiya", LoginHeader, "krish", "chiqish");
					return SendClientMessage(playerid, TEXT_COLOR_RED, "parol not to'g'ri");
				}
			}
		}
		case DLG_REG:
		{
			if(!strlen(inputtext))
			{
				new RegisterHeader[100];
				format(RegisterHeader, sizeof(RegisterHeader), "Salom %s!\nSizning nikingiz kabi akkaunt bizda ro'yahatdan o'tmagan\nRo'yahtdan o'tish uchun parol kiriting!", player_info[playerid][NAME]);
				ShowPlayerDialog(playerid, DLG_REG, DIALOG_STYLE_INPUT, "Ro'yahtdan o'tish > Parol", RegisterHeader, "kegingi", "chiqish");
				return SendClientMessage(playerid, TEXT_COLOR_RED, "parol majburiy");
			}

			new fileName[MAX_PLAYER_NAME + 5];
			format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
			new INI = ini_createFile(fileName);
			ini_setInteger(INI, "id", playerid);
			ini_setString(INI, "password", inputtext);
			ini_setInteger(INI, "skin", 0);
			ini_setInteger(INI, "money", 500);
			ini_setInteger(INI, "car", 411);
			ini_setInteger(INI, "admin", 0);
			ini_setInteger(INI, "prava", 0);
			ini_setInteger(INI, "phone", 0);
			ini_setFloat(INI, "lastX", 0.0);
			ini_setFloat(INI, "lastY", 0.0);
			ini_setFloat(INI, "lastZ", 0.0);
			ini_setFloat(INI, "lastA", 0.0);
			ini_setInteger(INI, "lastVirtualWorld", 0);
			ini_setInteger(INI, "lastInterer", 0);

			ini_closeFile(INI);

			showLogin(playerid);

			return SendClientMessage(playerid, TEXT_COLOR_GREEN, "Ro'yahtdan o'tish tugatildi!");
		}
		case DLG_GPS:
		{
			if(!response) return 1;
			// SetPlayerCheckpoint(playerid, GPSCoords[listitem][pos_X], GPSCoords[listitem][pos_Y], GPSCoords[listitem][pos_Z], 5.0);
			SetPlayerPos(playerid, GPSCoords[listitem][pos_X], GPSCoords[listitem][pos_Y], GPSCoords[listitem][pos_Z]);

			// count distance
			new Float:distance = GetPlayerDistanceFromPoint(playerid, GPSCoords[listitem][pos_X], GPSCoords[listitem][pos_Y], GPSCoords[listitem][pos_Z]);

			// sound
			// PlayerPlaySound(playerid, 17805, 0.0, 0.0, 0.0); gps on
			// PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0); gps off
			new str[55];
            format(str, sizeof(str), "[%s] Joy kartada belgilandi. masofa: %.0fm.", GPSCoords[listitem][name_gps], distance);
            PlayerPlaySound(playerid, 17803, 0.0, 0.0, 0.0);
            return SendClientMessage(playerid, -1, str);
		}
		case DLG_GRUZCHIK:
		{
		    if(!response) return 1;
		    if(GruzRabota[playerid] == 0)
		    {
		        GruzRabota[playerid] = 1;
		        GruzSkin[playerid] = GetPlayerSkin(playerid);
		        SetPlayerSkin(playerid, 260);
		        SetPlayerCheckpoint(playerid, 1779.0326,-1927.2537,13.3886, 1.5); // x, y, z - svoi kordinati
		        SendClientMessage(playerid, 0xFFFF00FF, "Siz gruzchik ishiga muaffaqiyatli kirdingiz!");
		        SendClientMessage(playerid, 0xFF8000FF, "Endi yuk tashishga boring, joy kartada ko'rsatilgan!");
		        return 1;
		    }
		    else
		    {
		        GruzRabota[playerid] = 0;
		        SetPlayerSkin(playerid, GruzSkin[playerid]);
		        DisablePlayerCheckpoint(playerid);
		        SendClientMessage(playerid, 0xFF8000FF, "Siz gruzchik ishidan muaffaqiyatli chiqdingiz!");  
		        return 1;  
		    }
		}
		case DLG_AVTOMAKTAB:
		{
			if(!response) return 1;
			SetPlayerCheckpoint(playerid, avtoMaktabRoad[0][pos_X],avtoMaktabRoad[0][pos_Y],avtoMaktabRoad[0][pos_Z], 5.0);
			SendClientMessage(playerid, TEXT_COLOR_GREEN, "Siz avtomaktab imtihoniga olindingiz!");
			// pervaya metka iz 10
			avtoMaktabSI[playerid] = 1; // mashina haydashga ruhsatnoma
			avtoMaktabSp[playerid] = 0;
			return 1;
		}
		case DLG_CARS:
		{
			if(!response) return 1;
			new Float:x, Float:y, Float:z, Float:a;
		    GetPlayerPos(playerid, x, y, z);
		    GetPlayerFacingAngle(playerid, a);
		    // dell old car
		    if(IsPlayerInAnyVehicle(playerid)) DestroyVehicle(GetPlayerVehicleID(playerid));
		    // create
		    new car = CreateVehicle(carsList[listitem][id], x, y, z, a, 0, 0, 120);
    		PutPlayerInVehicle(playerid, car, 0);
    		car_params[car][egasi] = playerid;
   			car_params[car][type] = SHAXSIY;
			return 1;
		}
		case DLG_GUNS:
		{
			if(!response) return 1;
			GivePlayerWeapon(playerid, gunsList[listitem][id], gunsList[listitem][ammos]);
			return 1;
		}
		case DLG_FSTYLE:
		{
			if(!response) return 1;
			SetPlayerFightingStyle(playerid, fighting_style_info[listitem][fsID]);
			new string[70];
			format(string, sizeof(string), "Figthing style: id - %d name - %s", fighting_style_info[listitem][fsID], fighting_style_info[listitem][fsName]);
			return SendClientMessage(playerid, TEXT_COLOR_GREEN, string);
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(GetPVarInt(playerid, "maptp") == 1)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ);
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
			SetPVarInt(playerid, "maptp", 0);
			return SendClientMessage(playerid, -1, "ok!");
		}
		SetPlayerPos(playerid, fX, fY, fZ);
		SetPVarInt(playerid, "maptp", 0);
		return SendClientMessage(playerid, -1, "ok!");
	}
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	if(isAdmin(playerid))
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			if(GetPlayerVehicleSeat(playerid) == 0 ) RepairVehicle(vehicleid);
		}
	}
	return 1;
}


CMD:lcity(playerid)
{
	SetPlayerPos(playerid, -729.276000, 503.086944, 1371.971801);
	SetPlayerInterior(playerid, 1);
	return 1;
}

CMD:lcityex(playerid)
{
	SetPlayerPos(playerid, 1759.4785, -1896.9556, 13.5617);
	SetPlayerFacingAngle(playerid, 268.6882);
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 0);
	return 1;
}

CMD:fstyle(playerid)
{
    new string[300];
	for(new i; i < sizeof(fighting_style_info); i++)
	{
		new conctat[30];
		format(conctat, sizeof(conctat), "%s\n", fighting_style_info[i][fsName]);
		strcat(string, conctat);
	}
	ShowPlayerDialog(playerid, DLG_FSTYLE, DIALOG_STYLE_LIST, "Figthing styles", string, "Belgilash", "belor qilish");
	return 1;
}

CMD:gravity(playerid)
{
	SetGravity(0.00132); // gravitatsiya kak na lune
	return 1;
}

CMD:gravityoff(playerid)
{
	SetGravity(0.008000); // normal
	return 1;
}

CMD:getgravity(playerid, params[])
{
    new string[64];
    format(string, sizeof(string), "Gravity: %.06f", GetGravity());
    return SendClientMessage(playerid, -1, string);
}

CMD:shit(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Vi ne na transporte!");

	new panels, doors, lights, tires;	
	GetVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, tires);

	UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), panels, doors, lights, 15);
	// carid
	// panels - kapot
	// doors - dveri
	// lights - fari
	// tires - shina
	return SendClientMessage(playerid, -1, "ok!");
}

CMD:boost(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Vi ne na transporte!");
    // rasschitaem skorost transporta po osiyam X i Y s uchotom ego ugla povorota.
    const Float:velocity = 1.5;
    new Float:angle;
    GetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
    new Float:vx = velocity * -floatcos(angle - 90.0, degrees);
    new Float:vy = velocity * -floatsin(angle - 90.0, degrees);
    // Pridadim transportnomu sredstvu skorost (polutisya rvok na peryod).
    return SetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, 0.0);
}

CMD:tuning(playerid)
{
	// if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Vi dolji bit za rulom na v tachke Elegy");
	// if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 562) return SendClientMessage(playerid, -1, "Dlya tuninga trebuetsya elegy");
	
	new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

	new car = CreateVehicle(562, x, y, z, a, 0, 0, 60);
    PutPlayerInVehicle(playerid, car, 0);
    car_params[car][egasi] = playerid;

	AddVehicleComponent(GetPlayerVehicleID(playerid), 1147); // spoyler type 2 / 1146 type 1
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1082); // diski import
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1036); // bokovoy 1 - 1036 // 2 1039
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1148); // zadniy bamper / 1 - 1148  2 - 1149
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1172); // peredniy / 1 - 1171 2 - 1172
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1037); // gluitel / 1 - 1034 2 1037

	SendClientMessage(playerid, -1, "Ok!");
	return 1;
}

CMD:anim(playerid)
{
	// proverka naxodisya li grok v vode
	new anim = GetPlayerAnimationIndex(playerid);
	{
		if(anim == 1543 || anim == 1538 || anim == 1539 || anim == 1050 || anim == 1062 || anim == 1541)
		{
			SendClientMessage(playerid, -1, "V vode");
			return 1;
		}

		new string[50];
		format(string, sizeof(string), "animIndex: %d", anim);
		SendClientMessage(playerid, -1, string);
	}
	return 1;
}

CMD:actortalk(playerid)
{
	new Float:actorPoz_X, Float:actorPoz_Y, Float:actorPoz_Z;
	GetActorPos(actorsMain, actorPoz_X, actorPoz_Y, actorPoz_Z);

	if(IsPlayerInRangeOfPoint(playerid, 5, actorPoz_X, actorPoz_Y, actorPoz_Z))
	{
		// animAskActor(actorsMain);
		ShowPlayerDialog(playerid, DLG_ACTOR, DIALOG_STYLE_MSGBOX, "Actor message", "Hello it's work!", "ok", "");
		return 1;
	}
	else return SendClientMessage(playerid, -1, "Vi ne radiuse 5m ot aktera");
}

CMD:bigbang(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		SetVehicleHealth(GetPlayerVehicleID(playerid), 10.0);
		SendClientMessage(playerid, -1, "ok");
	}
	return 1;
}

CMD:playmusic(playerid)
{
	PlayAudioStreamForPlayer(playerid,"http://class/a.mp3"); 
	return 1;
}

CMD:stopmusic(playerid)
{
	StopAudioStreamForPlayer(playerid);
	return 1;
}

CMD:alarmon(playerid)
{	
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(car_params[i][egasi] == playerid)
		{
			// pozitsiya mashini
			new Float:carPoz_X, Float:carPoz_Y, Float:carPoz_Z;
			GetVehiclePos(i, carPoz_X, carPoz_Y, carPoz_Z);

			// yavlyaetsya li igrok v radiuse 300 metrov ot mashini
			if(IsPlayerInRangeOfPoint(playerid, 300.0, carPoz_X, carPoz_Y, carPoz_Z))
			{
				// smotrim na signalizatsiyu
				new engine, lights, alarm, doors, bonnet, boot, objective;
				GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
				if(alarm == -1 || alarm == 0)
				{
					SetVehicleParamsEx(i, engine, lights, 1, doors, bonnet, boot, objective);
					return SendClientMessage(playerid, -1, "Signalizatsiya aktivirovana!");
				}
				else return SendClientMessage(playerid, -1, "Signalizatsiya uje aktivna!");
			}
			else return SendClientMessage(playerid, -1, "Vasha mashina ne nahoditsya v radiuse 300 metrov!");
		}
	}
	return SendClientMessage(playerid, -1, "Ne nayden vash lichniy avtomobil!");
}

CMD:alarmoff(playerid)
{	
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(car_params[i][egasi] == playerid)
		{
			// pozitsiya mashini
			new Float:carPoz_X, Float:carPoz_Y, Float:carPoz_Z;
			GetVehiclePos(i, carPoz_X, carPoz_Y, carPoz_Z);

			// yavlyaetsya li igrok v radiuse 300 metrov ot mashini
			if(IsPlayerInRangeOfPoint(playerid, 300.0, carPoz_X, carPoz_Y, carPoz_Z))
			{
				new engine, lights, alarm, doors, bonnet, boot, objective;
				GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
				if(alarm == 1)
				{
					SetVehicleParamsEx(i, engine, lights, 0, doors, bonnet, boot, objective);
					return SendClientMessage(playerid, -1, "Signalizatsiya otlyuchena!");
				}
				else return SendClientMessage(playerid, -1, "Signalizatsiya ne aktivna!");
			}
			else return SendClientMessage(playerid, -1, "Vasha mashina ne nahoditsya v radiuse 300 metrov!");
		}
	}
	return SendClientMessage(playerid, -1, "Ne nayden vash lichniy avtomobil!");
}

CMD:gps(playerid)
{
	new string[100];
	for(new i; i < sizeof(GPSCoords); i++)
	{
		new conctat[30];
		format(conctat, sizeof(conctat), "%s\n", GPSCoords[i][name_gps]);
		strcat(string, conctat);
	}
	ShowPlayerDialog(playerid, DLG_GPS, DIALOG_STYLE_LIST, "Gps", string, "Belgilash", "belor qilish");
	return 1;
}

CMD:car(playerid, params[])
{
	new carId, color1, color2;
	if(sscanf(params, "ddd", carId, color1, color2)) return SendClientMessage(playerid, -1, "/car [carId][colo1][color2]");

	// foydalanuvchi pozitsiyasi
	new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    // va qaysi tomonga yuzlanib turgani
    GetPlayerFacingAngle(playerid, a);

    new car = CreateVehicle(carId, x, y, z, a, color1, color2, 60);
    PutPlayerInVehicle(playerid, car, 0);
    car_params[car][type] = SHAXSIY;
    car_params[car][egasi] = playerid;

	return 1;
}

CMD:cars(playerid)
{
    new string[300];
	for(new i; i < sizeof(carsList); i++)
	{
		new conctat[30];
		format(conctat, sizeof(conctat), "%s\n", carsList[i][cars_name]);
		strcat(string, conctat);
	}
	ShowPlayerDialog(playerid, DLG_CARS, DIALOG_STYLE_LIST, "Cars", string, "Belgilash", "belor qilish");
	return 1;
}

CMD:gun(playerid, params[])
{
	new gun, ammo;
	if(sscanf(params, "dd", gun, ammo)) return SendClientMessage(playerid, -1, "/gun [gunid] [ammo]");
	GivePlayerWeapon(playerid, gun, ammo);
    return SendClientMessage(playerid, 0xDEEE20FF, "ok!"); 
}

CMD:guns(playerid)
{
	new string[550];
	for(new i; i < sizeof(gunsList); i++)
	{
		new conctat[150];
		format(conctat, sizeof(conctat), "%s | {ff9300}%d$ \n", gunsList[i][name], gunsList[i][summa]);
		strcat(string, conctat);
	}
	ShowPlayerDialog(playerid, DLG_GUNS, DIALOG_STYLE_LIST, "Guns", string, "Belgilash", "belor qilish");
	return 1;
}

CMD:savepoz(playerid)
{
	new Float:lastX, Float:lastY, Float:lastZ, Float:lastA;
	GetPlayerPos(playerid, lastX, lastY, lastZ);
	GetPlayerFacingAngle(playerid, lastA);

	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);
	if(INI == INI_OK)
	{
		ini_setFloat(INI, "lastX", lastX);
		ini_setFloat(INI, "lastY", lastY);
		ini_setFloat(INI, "lastZ", lastZ);
		ini_setFloat(INI, "lastA", lastA);
		ini_setInteger(INI, "lastVirtualWorld", GetPlayerVirtualWorld(playerid));
		ini_setInteger(INI, "lastInterer", GetPlayerInterior(playerid));

		ini_closeFile(INI);
		return SendClientMessage(playerid, -1, "Pozitsiya dlya vxoda soxranen!");
	}

	return 1;
}

CMD:inter(playerid)
{
	new str[20];
	format(str, 20, "intererid: %d", GetPlayerInterior(playerid));
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:maptp(playerid)
{
	SetPVarInt(playerid, "maptp", 1);
	SendClientMessage(playerid, -1, "viberayte mestu na karte");
	return 1;
}

CMD:dellcar(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) {
        new mesta = GetPlayerVehicleSeat(playerid); // uznaem v kakom meste sidit igrok - (0 - voditelnoe).
        if(mesta == 0) {
            DestroyVehicle(GetPlayerVehicleID(playerid));            
            return SendClientMessage(playerid, 0xDEEE20FF, "Vi ubrali svoyu mashinu!");
        } else {
            return SendClientMessage(playerid, 0xDEEE20FF, "Vi doljni naxodisya za rulyom!");
        }
    }
    return SendClientMessage(playerid, 0xDEEE20FF, "Ispolzuyte etot komandu kogda naxodites v mashine!");
}

CMD:fix(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "ispolzuyte komandu v mashine!");

    RepairVehicle(GetPlayerVehicleID(playerid));
    return SendClientMessage(playerid, -1, "Avto otremontirovan!");
}

CMD:givemoney(playerid, params[])
{
	new pId, cash;
	if(sscanf(params, "dd", pId, cash)) return SendClientMessage(playerid, -1, "/givemoney [playerid] [summa]");
	if(!IsPlayerConnected(pId)) return SendClientMessage(playerid, -1, "Igrok ne v seti");
	GivePlayerMoney(pId, cash);
	return SendClientMessage(playerid, -1, "ok");
}

CMD:sl(playerid, params[])
{
	new playerId;
	if(sscanf(params, "d", playerId)) return SendClientMessage(playerid, -1, "/sl [playerid]");
	TogglePlayerSpectating(playerid, 1);
	PlayerSpectatePlayer(playerid, playerId, SPECTATE_MODE_NORMAL);
	return 1;
}

CMD:sloff(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	return 1;
}

CMD:slcar(playerid, params[])
{
	new carId;
	if(sscanf(params, "d", carId)) return SendClientMessage(playerid, -1, "/sl [car]");
	TogglePlayerSpectating(playerid, 1);
	PlayerSpectateVehicle(playerid, carId, SPECTATE_MODE_NORMAL);
	return 1;
}

CMD:slcaroff(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	return 1;
}

CMD:time(playerid)
{
	new hour, minute, second;
	gettime(hour, minute, second);

	new strTime[30];
	format(strTime, sizeof(strTime), "hozir: %d:%02d:%02d", hour, minute, second);
	SendClientMessage(playerid, -1, strTime);
	return 1;
}

CMD:tt(playerid)
{
	setCurretTime();
	return 1;
}

CMD:sms(playerid, params[])
{
	new userid, mess[120], msgFormat[150], playerName[MAX_PLAYER_NAME];
	if(sscanf(params, "ds", userid, mess)) return SendClientMessage(playerid, -1, "/sms [playerid][message]");
	// check tell
	if(player_info[playerid][PHONE] != 1) return SendClientMessage(playerid, -1, "Sizda uyali aloqa mavjud emas!");
	if(player_info[userid][PHONE] != 1) return SendClientMessage(playerid, -1, "Foydalanuvchida uyali aloqa mavjud emas!");
	if(!IsPlayerConnected(userid)) return SendClientMessage(playerid, -1, "Igrok ne v seti");
	GetPlayerName(playerid, playerName, sizeof(playerName));
	format(msgFormat, sizeof(msgFormat), "[sms] %s: %s", playerName, mess);
	SendClientMessage(userid, TEXT_COLOR_ORANGE, msgFormat);
	SendClientMessage(playerid, TEXT_COLOR_GREEN, "xabar yuborildi!");
	return 1;
}

CMD:hp(playerid)
{
	SetPlayerHealth(playerid, 100);
    return SendClientMessage(playerid, 0xDEEE20FF, "+hp!"); 
}

CMD:sethp(playerid, params[]) 
{
	new pId, hp;
	if(sscanf(params, "dd", pId, hp)) return SendClientMessage(playerid, -1, "/sethp [playerid] [hp]");
	if(!IsPlayerConnected(pId)) return SendClientMessage(playerid, -1, "Igrok ne v seti");
	if((hp < 20 || hp > 100) && !isAdmin(playerid)) return SendClientMessage(playerid, -1, "Hp nije chem 20 ili bolshe chem 100 mogut ustanovit tolka administratori!");
	SetPlayerHealth(pId, hp);
	return 1;
}

CMD:nitro(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) {
        AddVehicleComponent(GetPlayerVehicleID(playerid), 1010); // nitro 10x
        return SendClientMessage(playerid, 0xDEEE20FF, "ok!"); 
    }
    return SendClientMessage(playerid, 0xDEEE20FF, "Ispolzuyte etot komandu kogda naxodites v mashine!");
}

CMD:color(playerid, params[])
{
	new color1, color2;
	if(sscanf(params, "dd", color1, color2)) return SendClientMessage(playerid, -1, "/color [color1] [color2]");

	if(IsPlayerInAnyVehicle(playerid)) {
        ChangeVehicleColor(GetPlayerVehicleID(playerid), color1, color2);
        return SendClientMessage(playerid, 0xDEEE20FF, "ok!"); 
    }
    return SendClientMessage(playerid, 0xDEEE20FF, "Ispolzuyte etot komandu kogda naxodites v mashine!");
}

CMD:dlb(playerid)
{
	SetPlayerPos(playerid, -14.0372, -288.5667, 5.4297);
	// SetPlayerInterior(playerid, 0);
	// SetPlayerVirtualWorld(playerid, 0);
	return 1;
}
CMD:godl(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Vi doljni bit v fure za rulom!");

	new model = GetVehicleModel(GetPlayerVehicleID(playerid));

	if(IsPlayerInRangeOfPoint(playerid, 200.0, -75.1052, -289.7339, 6.4286))
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && model==515 || GetPlayerState(playerid) != PLAYER_STATE_DRIVER && model==514 || GetPlayerState(playerid) != PLAYER_STATE_DRIVER && model==403)
   		{
   			SendClientMessage(playerid, TEXT_COLOR_WHITE, "{FF4500}[Server]: {00FFFF}Vi doljni bit v fure za rulom!");
   			return 1;
   		}
   		if(!IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)))
   		{
   			SendClientMessage(playerid, TEXT_COLOR_WHITE, "{FF4500}[Server]: {00FFFF}Vi ne podtsepili pritsep");
   			return 1;
   		}
   		DisablePlayerCheckpoint(playerid);
   		GameTextForPlayer(playerid, "~r~Napravlyaytes k markeru!", 2500, 1);
   		StatusRabotiDalnaboyshika[playerid] = 1;

   		new traileid = GetVehicleTrailer(GetPlayerVehicleID(playerid));
   		if(traileid == Pricep[5] || traileid == Pricep[6] || traileid == Pricep[7]) // Stroyki
   		{
   			new rand = random(4);
   			switch (rand)
   			{
   				case 0: SetPlayerCheckpoint(playerid, -2101.1555, 208.4684, 34.8973, 8.0);
   				case 1: SetPlayerCheckpoint(playerid, 2801.4639, -2436.1069, 13.2421, 8.0);
   				case 2: SetPlayerCheckpoint(playerid, 2619.9587, 833.6466, 4.9254, 8.0);
   				case 3: SetPlayerCheckpoint(playerid, 680.4613, 896.6621, -40.3721, 8.0);
   			}
   		}

   		if(traileid == Pricep[8] || traileid == Pricep[4]) // ne znayu
   		{
   			new rand = random(4);
   			switch (rand)
   			{
   				case 0:SetPlayerCheckpoint(playerid,2193.5149,2476.3335,10.8203,8.0);
   				case 1:SetPlayerCheckpoint(playerid,-2442.1062,953.0255,45.2969,8.0);
   				case 2:SetPlayerCheckpoint(playerid,-1624.4644,-2697.6082,48.5391,8.0);
   				case 3:SetPlayerCheckpoint(playerid,1918.5468,-1792.2303,13.3828,8.0);
   			}
   		}

   		if(traileid == Pricep[8] || traileid == Pricep[4]) // Producti
   		{
   			new rand = random(4);
   			switch (rand)
   			{
   				case 0:SetPlayerCheckpoint(playerid,2119.4260,-1826.5001,13.5549,8.0);
   				case 1:SetPlayerCheckpoint(playerid,2073.7229,2225.8416,10.8203,8.0);
   				case 2:SetPlayerCheckpoint(playerid,1383.9170,264.0096,19.5669,8.0);
   				case 3:SetPlayerCheckpoint(playerid,-1802.8058,960.6457,24.8906,8.0);
   			}
   		}

   		if(traileid == Pricep[2]) // Odejda
   		{
   			new rand = random(4);
   			switch (rand)
   			{
   				case 0:SetPlayerCheckpoint(playerid,505.3549,-1366.4999,16.1252,8.0);
   				case 1:SetPlayerCheckpoint(playerid,2247.9878,-1663.3557,15.4690,8.0);
   				case 2:SetPlayerCheckpoint(playerid,2105.0955,2248.5913,11.0234,8.0);
   				case 3:SetPlayerCheckpoint(playerid,-1889.1820,874.3929,35.1719,8.0);
   			}
   		}

   		if(traileid == Pricep[1]) // Raznie napitki
   		{
   			new rand = random(4);
   			switch (rand)
   			{
   				case 0:SetPlayerCheckpoint(playerid,2303.3145,-1635.1567,14.1720,8.0);
   				case 1:SetPlayerCheckpoint(playerid,1830.3245,-1682.8469,13.1551,8.0);
   				case 2:SetPlayerCheckpoint(playerid,-2244.7861,-87.9356,34.9299,8.0);
   				case 3:SetPlayerCheckpoint(playerid,-2555.2585,191.8923,5.7216,8.0);
   			}
   		}

   		if(traileid == Pricep[0]) // Anunitsiya
   		{
   			new rand = random(4);
   			switch (rand)
   			{
   				case 0:SetPlayerCheckpoint(playerid,1363.6267,-1282.4384,13.5469,8.0);
   				case 1:SetPlayerCheckpoint(playerid,2394.5999,-1978.2787,13.1115,8.0);
   				case 2:SetPlayerCheckpoint(playerid,2156.1287,940.5781,10.4309,8.0);
   				case 3:SetPlayerCheckpoint(playerid,-2626.6106,211.0776,4.2099,8.0);
   			}
   		}
   	}
   	else return SendClientMessage(playerid, TEXT_COLOR_WHITE, "{FF4500}[Server]: {00FFFF}Vi ne na dalnaboyoe");
	return 1;
}


// ********************* [ STOCKS ] *********************

// LOGIN
stock showLogin(playerid)
{
	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);

	ini_getInteger(INI, "id", player_info[playerid][ID]);
	ini_getString(INI, "password", player_info[playerid][PASSWORD]);
	ini_getInteger(INI, "skin", player_info[playerid][SKIN]);
	ini_getInteger(INI, "money", player_info[playerid][MONEY]);
	ini_getInteger(INI, "car", player_info[playerid][CAR]);
	ini_getInteger(INI, "admin", player_info[playerid][ADMIN]);
	ini_getInteger(INI, "prava", player_info[playerid][PRAVA]);
	ini_getInteger(INI, "phone", player_info[playerid][PHONE]);
	ini_getFloat(INI, "lastX", player_info[playerid][LASTX]);
	ini_getFloat(INI, "lastY", player_info[playerid][LASTY]);
	ini_getFloat(INI, "lastZ", player_info[playerid][LASTZ]);
	ini_getFloat(INI, "lastA", player_info[playerid][LASTA]);
	ini_getInteger(INI, "lastVirtualWorld", player_info[playerid][LASTVIRTUALWORLD]);
	ini_getInteger(INI, "lastInterer", player_info[playerid][LASTINTERER]);

	ini_closeFile(INI);

	new LoginHeader[100];
	format(LoginHeader, sizeof(LoginHeader),
		"{FFFFFF}Salom %s! avtorizatsiya uchun parolni kiriting", player_info[playerid][NAME]
	);
	ShowPlayerDialog(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "Avtorizatsiya", LoginHeader, "krish", "belor qilish");
	return 1;
}

// REGISTER
stock showRegister(playerid)
{
	new RegisterHeader[100];
	format(RegisterHeader, sizeof(RegisterHeader), "Salom %s!\nSizning nikingiz kabi akkaunt bizda ro'yahatdan o'tmagan\nRo'yahtdan o'tish uchun parol kiriting!", player_info[playerid][NAME]);
	ShowPlayerDialog(playerid, DLG_REG, DIALOG_STYLE_INPUT, "Ro'yahtdan o'tish > Parol", RegisterHeader, "kegingi", "chiqish");
	return 1;
}

// SAVE LAST POSITION
stock saveuserLastPos(playerid)
{
	new Float:lastX, Float:lastY, Float:lastZ, Float:lastA;
	GetPlayerPos(playerid, lastX, lastY, lastZ);
	GetPlayerFacingAngle(playerid, lastA);

	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);
	if(INI == INI_OK)
	{
		ini_setFloat(INI, "lastX", lastX);
		ini_setFloat(INI, "lastY", lastY);
		ini_setFloat(INI, "lastZ", lastZ);
		ini_setFloat(INI, "lastA", lastA);
		ini_setInteger(INI, "lastVirtualWorld", GetPlayerVirtualWorld(playerid));
		ini_setInteger(INI, "lastInterer", GetPlayerInterior(playerid));

		ini_closeFile(INI);
		return 1;
	}
	return 0;
}

// PROVERKA NA PRAVA
stock proverkaNaPrava(playerid, newstate)
{
	if (newstate == PLAYER_STATE_DRIVER)  // PLAYER_STATE_DRIVER = 2 
    {
    	if(player_info[playerid][PRAVA] != 1 && avtoMaktabSI[playerid] != 1)
    	{
    		SendClientMessage(playerid, -1, "Avtomobilni boshqarish uchun sizga haydovchilik guvohnomasi kerak");
    		return RemovePlayerFromVehicle(playerid);
    	}
    }
    return 1;
}

// CHECK ADMIN
stock isAdmin(playerid)
{
	return player_info[playerid][ADMIN];
}

// SPAWN
stock Spawn(playerid)
{
	TogglePlayerSpectating(playerid, 0);

	SetPVarInt(playerid, "logged", 1);

	GivePlayerMoney(playerid, player_info[playerid][MONEY]);

	if(player_info[playerid][LASTX])
	{
		SetSpawnInfo(playerid, NO_TEAM, player_info[playerid][SKIN], player_info[playerid][LASTX], player_info[playerid][LASTY], player_info[playerid][LASTZ], player_info[playerid][LASTA], 0, 0, 0, 0, 0, 0);
		SetPlayerVirtualWorld(playerid, player_info[playerid][LASTVIRTUALWORLD]);
		SetPlayerInterior(playerid, player_info[playerid][LASTINTERER]);
		SpawnPlayer(playerid);
		return 1;
	}

	SetSpawnInfo(playerid, NO_TEAM, player_info[playerid][SKIN], 1759.4785, -1896.9556, 13.5617, 268.6882, 0, 0, 0, 0, 0, 0);
	// playerid - ID igroka.
	// team - ID komandi, k kotoroy budet otnositssya igrok. 
	// igroki v odnom komande ne mogut nanesti uron drug druga daje na mashinu
	// skinid - (0-73, 75-311).
	// Float:x, Float:x, Float:z - Kordinati.
	// Float:rotation - Ugol porovota.
	// weapon1 - ID gun 1.
	// weapon1_ammo	- potroni.
	// weapon2
	// weapon2_ammo
	// weapon3
	// weapon3_ammo

	SpawnPlayer(playerid);
	return 1;
}

// **************************************
// CARS HELPERS

// ENGINE
stock engineOn(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	return SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
}

stock engineOff(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	return SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
}

stock engineToggle(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	if(!engine) return SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
	else return SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
}

// LIGHTS
stock lightsOn(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(carId, engine, lights, alarm, doors, bonnet, boot, objective);
	return SetVehicleParamsEx(carId, engine, 1, alarm, doors, bonnet, boot, objective);
}

stock lightsOff(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(carId, engine, lights, alarm, doors, bonnet, boot, objective);
	return SetVehicleParamsEx(carId, engine, 0, alarm, doors, bonnet, boot, objective);
}

stock lightsToggle(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(carId, engine, lights, alarm, doors, bonnet, boot, objective);

	if(!lights) return SetVehicleParamsEx(carId, engine, 1, alarm, doors, bonnet, boot, objective);
	else return SetVehicleParamsEx(carId, engine, 0, alarm, doors, bonnet, boot, objective);
}

// ALARM - SIGNALIZATSIYA
stock alarmOn(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	return SetVehicleParamsEx(vehicleid, engine, lights, 1, doors, bonnet, boot, objective);
}

stock alarmOff(vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	return SetVehicleParamsEx(vehicleid, engine, lights, 0, doors, bonnet, boot, objective);
}

// VALID CAR
stock validCar(vehicleid)
{
	new model = GetVehicleModel(vehicleid);
	if(model == 481 || model == 509 || model == 510) return 1;
	return 0;
}


// **************************************
// GETTRI AND SETTERI

// Avtomaktab
stock INI_get_userPrava(playerid)
{
	return player_info[playerid][PRAVA];
}

// Avtomaktab
stock INI_set_userPrava(playerid)
{
	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);
	if(INI == INI_OK)
	{
		player_info[playerid][PRAVA] = 1;
		ini_setInteger(INI, "prava", 1);
		ini_closeFile(INI);
		return 1;
	}
	return 0;
}

// money
stock INI_get_userMoney(playerid)
{
	return player_info[playerid][MONEY];
}

// money
stock INI_set_userMoney(playerid, cash)
{
	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);
	if(INI == INI_OK)
	{
		player_info[playerid][MONEY] = cash;
		ini_setInteger(INI, "money", cash);
		ini_closeFile(INI);
		return 1;
	}
	return 0;
}

// phone
stock INI_get_userPhone(playerid)
{
	return player_info[playerid][PHONE];
}

// phone
stock INI_set_userPhone(playerid)
{
	new fileName[MAX_PLAYER_NAME + 5];
	format(fileName, sizeof(fileName), "%s.ini", player_info[playerid][NAME]);
	new INI = ini_openFile(fileName);
	if(INI == INI_OK)
	{
		player_info[playerid][PHONE] = 1;
		ini_setInteger(INI, "phone", 1);
		ini_closeFile(INI);
		return 1;
	}
	return 0;
}

// ********************* [ PUBLIC - FUNCTIONS ] *********************


// SET CURRENT TIME [h] FOR SERVER / TIMEOUT
public setCurretTime()
{
	new hour, minute, second;
	gettime(hour, minute, second);

	if(hour > currentServerHour)
	{
		SetWorldTime(hour);
		new strTime[35];
		format(strTime, sizeof(strTime), "[set] Ayni damda soat: %d:%02d:%02d!", hour, minute, second);
		return SendClientMessageToAll(-1, strTime);
	}
	new strTime[35];
	format(strTime, sizeof(strTime), "[get] Ayni damda soat: %d:%02d:%02d!", hour, minute, second);
	return SendClientMessageToAll(-1, strTime);
}

// RABOTA GRUZCHIKA / setTimer
public toggleGruzchikPicup()
{
	GruzPickId = CreatePickup(1275, 23, 1779.5306, -1916.7925, 13.3890); //mesta ustroystva na rabotu x, y, z - svoi sordinati
	return 1;
}

// AVTOMAKTAB / setTimer
public toggleAvtomaktabPicup()
{
	avtoMaktabPicupId = CreatePickup(1581, 23, -2031.5508,-117.4373,1035.1719); // prava
	return 1;
}

stock animAskActor(actorid)
{
	static const talk_anims[][] = {
       "prtial_gngtlkA", "prtial_gngtlkB", "prtial_gngtlkC", "prtial_gngtlkD",
       "prtial_gngtlkE", "prtial_gngtlkF", "prtial_gngtlkG", "prtial_gngtlkH"
    };
    ApplyActorAnimation(actorid, "GANGS", talk_anims[random(sizeof(talk_anims))], 4.0, 1, 1, 1, 1, 1);
    SetTimerEx("ActorTalkHandsOff", 2000, 0, "d", actorid);
    return 1;
}

public ActorTalkHandsOff(actorid)
{
	ApplyActorAnimation(actorid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 0);
	return 1;
}


public TalkHandsOff(playerid)
{
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 0);
    return 1;
}