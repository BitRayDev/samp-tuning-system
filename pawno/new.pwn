#include <a_samp>
#include <dc_cmd>
#include <foreach>
#include <sscanf2>
#include <streamer>

#define PRESSED(%0) (((newkeys & (%0))== (%0)) && ((oldkeys & (%0)) != (%0)))
#define function%0(%1) forward %0(%1); public %0(%1)
#define format:%0( %0[0] = EOS,format(%0,sizeof(%0),
//#define IsPlayerLogged(%0) (GetPVarInt(%0, "gLogged") && uInfo[%0][uID])

#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_PURPLE 0x800080FF
#define COLOR_RED 0xAA3333AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_BLUE 0x0000BBAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_RED 0xAA3333AA
#define COLOR_LIME 0x10F441AA
#define COLOR_MAGENTA 0xFF00FFFF
#define COLOR_NAVY 0x000080AA
#define COLOR_AQUA 0xF0F8FFAA
#define COLOR_CRIMSON 0xDC143CAA
#define COLOR_FLBLUE 0x6495EDAA
#define COLOR_BISQUE 0xFFE4C4AA
#define COLOR_BLACK 0x000000AA
#define COLOR_CHARTREUSE 0x7FFF00AA
#define COLOR_BROWN 0XA52A2AAA
#define COLOR_CORAL 0xFF7F50AA
#define COLOR_GOLD 0xB8860BAA
#define COLOR_GREENYELLOW 0xADFF2FAA
#define COLOR_INDIGO 0x4B00B0AA
#define COLOR_IVORY 0xFFFF82AA
#define COLOR_LAWNGREEN 0x7CFC00AA
#define COLOR_SEAGREEN 0x20B2AAAA
#define COLOR_LIMEGREEN 0x32CD32AA //<--- Dark lime
#define COLOR_MIDNIGHTBLUE 0X191970AA
#define COLOR_MAROON 0x800000AA
#define COLOR_OLIVE 0x808000AA
#define C_PODSKAZ 0x8F8F8FAA

#define dEmpty 9999

new debug_mode = 1;

new
	g_str_least[32],
	g_str_small[256],
	g_str_big[512];

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	SetGameModeText("Blank Script");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
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
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}



//============================================DEBUG=========================
CMD:setskin(playerid, params[])
{
	if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, COLOR_RED, "/setskin [ID] [Skin]");
	if(IsPlayerConnected(params[0]))
		SetPlayerSkin(params[0], params[1]);
	return 1;
}
CMD:veh(playerid,params[])
{
    new string[145];
    new Float:pX,Float:pY,Float:pZ;
    if(sscanf(params, "ddd", params[0],params[1],params[2])) return SendClientMessage(playerid, -1, "{BEBEBE}Использование: /veh [id машины] {цвет 1} {цвет 2}");
    {
        if(params[1] > 126 || params[1] < 0 || params[2] > 126 || params[2] < 0) return SendClientMessage(playerid, -1, "ID цвета от 0 до 126!");
        GetPlayerPos(playerid,pX,pY,pZ);
        new vehid = CreateVehicle(params[0],pX+2,pY,pZ,0.0,params[1],params[2],0,0);
        LinkVehicleToInterior(vehid, GetPlayerInterior(playerid));
        SetVehicleVirtualWorld(vehid, GetPlayerVirtualWorld(playerid));
        PutPlayerInVehicle(playerid, vehid, 0);
        format(string,sizeof(string),"{696969}[!] {1E90FF}Вы создали автомобиль №%d",params[0]);
        SendClientMessage(playerid,-1,string);
    }
    return 1;
}
CMD:restart(playerid)
{
	SendRconCommand("gmx");
}
