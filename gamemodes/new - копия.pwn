#include <a_samp>
#include <dc_cmd>
#include <foreach>
#include <sscanf2>
#include <streamer>
#include <acuf>

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

#define TUNING_CATEGORIE_PAINTJOB 0
#define TUNING_CATEGORIE_COLOR 1
#define TUNING_CATEGORIE_WHEELS 2
#define TUNING_CATEGORIE_NITRO 3
#define TUNING_CATEGORIE_FRONT_BUMPER 4
#define TUNING_CATEGORIE_REAR_BUMPER 5
#define TUNING_CATEGORIE_SPOILER 6
#define TUNING_CATEGORIE_LAMPS 7
#define TUNING_CATEGORIE_ROOF 8
#define TUNING_CATEGORIE_HOOD 9
#define TUNING_CATEGORIE_VENTS 10
#define TUNING_CATEGORIE_EXHAUST 11
#define TUNING_CATEGORIE_SIDESKIRTS 12
#define TUNING_CATEGORIE_TIRES 13
#define TUNING_CATEGORIE_NEON 14
#define TUNING_CATEGORIE_STYLING 15

#define INVALID_TUNING_ORDER -1

#define MAX_TUNING_CATEGORIES 16

#define dEmpty 9999
#define dTuneMechanic 285
#define dTuningOrder 300

#define MAX_TUNING_ORDERS MAX_TUNING_CATEGORIES

new debug_mode = 1;

new
	g_str_least[32],
	g_str_small[256],
	g_str_big[512],
	g_str_cmd[2048];
	
enum E_PLAYER
{
    uID,
	uName[MAX_PLAYER_NAME],
	uMoney,
	uTuningMechanicLevel,
	uTuningMechanicOrders
}
new uInfo[MAX_PLAYERS][E_PLAYER];

new Text:TuningTitleTD[10];
new PlayerText:TuningItemTD[MAX_PLAYERS][9][2];

enum E_TEMP
{
	temp_selected_items_array_size,
	temp_selected_td_item,
	temp_selected_categorie,
	temp_selected_items[9],
	temp_selected_categories[9],
	temp_selected_tuning_elements[MAX_TUNING_CATEGORIES],
	temp_tuning_order_id
}
new TempInfo[MAX_PLAYERS][E_TEMP];

enum E_VEHICLE
{
    vehicle_tuning_elements[MAX_TUNING_CATEGORIES]
}
new VehicleInfo[MAX_VEHICLES][E_VEHICLE];

enum E_TUNING_MECHANIC_LEVELS
{
	tuning_mechanic_execution_time,
	tuning_mechanic_skin_id,
	tuning_mechanic_pay_percent,
	tuning_mechanic_orders_needed
}

new const TuningMechanicLevels[][E_TUNING_MECHANIC_LEVELS] =
{
	{0, 0, 0, 0},
	{15, 268, 20, 1},
	{15, 268, 23, 2},
	{15, 268, 26, 3},
	{12, 42, 30, 4},
	{12, 42, 33, 5},
	{12, 42, 36, 6},
	{8, 8, 40, 7},
	{6, 8, 43},
	{5, 8, 46},
	{3, 50, 50, 0}
};

/*new const TuningMechanicLevels[][E_TUNING_MECHANIC_LEVELS] =
{
	{0, 0, 0, 0},
	{15, 268, 6, 25},
	{15, 268, 7, 75},
	{15, 268, 8, 100},
	{12, 42, 9, 125},
	{12, 42, 10, 150},
	{12, 42, 11, 180},
	{8, 8, 12, 220},
	{6, 8, 260},
	{5, 8, 300},
	{3, 50, 15, 0}
};*/

enum E_TUNING_CATEGORIES
{
	tuning_categorie_name[32],
	tuning_categorie_name_rus[32]
}
new TuningCategories[MAX_TUNING_CATEGORIES][E_TUNING_CATEGORIES] =
{
	{"Paint Job", "Покрасочные работы"}, // 0
	{"Color", "Покраска"}, // 1
	{"Wheels", "Колеса"}, // 2
	{"Nitro", "Нитро"}, // 3
	{"Front Bumper", "Передний бампер"}, // 4
	{"Rear Bumper", "Задний бампер"}, // 5
	{"Spoiler", "Спойлер"}, // 6
	{"Lamps", "Фары"}, // 7
	{"Roof", "Крыша"}, // 8
	{"Hood", "Капот"}, // 9
	{"Vents", "Вентиляция"}, // 10
	{"Exhaust", "Выхлопную трубу"}, // 11
	{"Sideskirts", "Боковые юбки"}, // 12
	{"Tires", "Шины"}, // 13
	{"Neon", "Неон"}, // 14
	{"Other", "Стайлинг"} // 15
};

new Float:GetInterpolateCameraPos[MAX_PLAYERS][3];
new Float:GetInterpolateCameraLookAt[MAX_PLAYERS][3];

enum E_TUNING_ELEMENTS
{
    tuning_element_id,
    tuning_element_categorie_id,
	tuning_element_name[32],
	tuning_element_price
}
new TuningElements[][E_TUNING_ELEMENTS] =
{
	//{999, 25, "Standart", 0},
	{-1, -1, "", -1},

	{0, TUNING_CATEGORIE_PAINTJOB, "No PaintJob", 500},
	{1, TUNING_CATEGORIE_PAINTJOB, "PaintJob 1", 2000},
	{2, TUNING_CATEGORIE_PAINTJOB, "PaintJob 2", 2000},
	{3, TUNING_CATEGORIE_PAINTJOB, "PaintJob 3", 2000},
	
	{0, TUNING_CATEGORIE_COLOR, "Black", 500},
	{1, TUNING_CATEGORIE_COLOR, "White", 500},
	{2, TUNING_CATEGORIE_COLOR, "Lime Green", 500},
	{3, TUNING_CATEGORIE_COLOR, "Red", 500},
	{4, TUNING_CATEGORIE_COLOR, "Dark Grey", 500},
	{5, TUNING_CATEGORIE_COLOR, "Dark Pink", 500},
	{6, TUNING_CATEGORIE_COLOR, "Orange", 500},
	{7, TUNING_CATEGORIE_COLOR, "Light Blue", 500},
	{8, TUNING_CATEGORIE_COLOR, "Light Grey", 500},
	{9, TUNING_CATEGORIE_COLOR, "Beige", 500},
	{16, TUNING_CATEGORIE_COLOR, "Green", 500},
	{17, TUNING_CATEGORIE_COLOR, "Dark Red", 500},
	{32, TUNING_CATEGORIE_COLOR, "Silver", 500},
	{126, TUNING_CATEGORIE_COLOR, "Pink", 500},
	
	{0, TUNING_CATEGORIE_NITRO, "Standart", 500},
	{1008, TUNING_CATEGORIE_NITRO, "Nitro 5x", 7500},
	{1009, TUNING_CATEGORIE_NITRO, "Nitro 2x", 15000},
	{1010, TUNING_CATEGORIE_NITRO, "Nitro 10x", 20000},
	
	{0, TUNING_CATEGORIE_WHEELS, "Standart Wheel", 250},
	{1073, TUNING_CATEGORIE_WHEELS, "Shadow", 1500},
	{1074, TUNING_CATEGORIE_WHEELS, "Mega", 2500},
	{1075, TUNING_CATEGORIE_WHEELS, "Rimshine", 2500},
	{1076, TUNING_CATEGORIE_WHEELS, "Wires", 3000},
	{1077, TUNING_CATEGORIE_WHEELS, "Classic", 3000},
	{1078, TUNING_CATEGORIE_WHEELS, "Twist", 5000},
	{1079, TUNING_CATEGORIE_WHEELS, "Cutter", 5000},
	{1080, TUNING_CATEGORIE_WHEELS, "Switch", 8000},
	{1081, TUNING_CATEGORIE_WHEELS, "Grove", 6500},
	{1082, TUNING_CATEGORIE_WHEELS, "Import", 6500},
	{1083, TUNING_CATEGORIE_WHEELS, "Dollar", 100000},
	{1084, TUNING_CATEGORIE_WHEELS, "Trance", 85000},
	{1085, TUNING_CATEGORIE_WHEELS, "Atomic", 12000},
	{1025, TUNING_CATEGORIE_WHEELS, "Offroad", 500},
	{1096, TUNING_CATEGORIE_WHEELS, "Ahab", 1000},
	{1097, TUNING_CATEGORIE_WHEELS, "Virtual", 2500},
	{1098, TUNING_CATEGORIE_WHEELS, "Access", 1000},
	
	/*
	{1086,    "Stero","Sony", 500},
	{1087,    "Hydraulics","Гидравлика", 15000},
	*/
	
	{0, TUNING_CATEGORIE_SPOILER, "Standart", 250},
	{1000, TUNING_CATEGORIE_SPOILER, "Pro", 5000},
	{1001, TUNING_CATEGORIE_SPOILER, "Win", 5000},
	{1002, TUNING_CATEGORIE_SPOILER, "Drag", 5000},
	{1003, TUNING_CATEGORIE_SPOILER, "Alpha", 6000},
	{1014, TUNING_CATEGORIE_SPOILER, "Champ" , 6000},
	{1015, TUNING_CATEGORIE_SPOILER, "Race", 6000},
	{1016, TUNING_CATEGORIE_SPOILER, "Worx", 6000},
	{1049, TUNING_CATEGORIE_SPOILER, "Alien", 12000},
	{1050, TUNING_CATEGORIE_SPOILER, "X-Flow", 12000},
	{1058, TUNING_CATEGORIE_SPOILER, "Alien", 12000},
	{1023, TUNING_CATEGORIE_SPOILER, "Fury", 12000},
	{1158, TUNING_CATEGORIE_SPOILER, "X-Flow", 12000},
	{1146, TUNING_CATEGORIE_SPOILER, "X-Flow", 12000},
	{1147, TUNING_CATEGORIE_SPOILER, "Alien", 12000},
	{1138, TUNING_CATEGORIE_SPOILER, "Alien", 12000},
	{1139, TUNING_CATEGORIE_SPOILER, "X-Flow", 12000},
	{1060, TUNING_CATEGORIE_SPOILER, "X-Flow", 12000},
	{1162, TUNING_CATEGORIE_SPOILER, "Alien", 12000},
	{1163, TUNING_CATEGORIE_SPOILER, "X-Flow", 12000},
	{1164, TUNING_CATEGORIE_SPOILER, "Alien", 12000},
	
	{0, TUNING_CATEGORIE_HOOD, "Standart", 250},
	{1004, TUNING_CATEGORIE_HOOD, "Champ Scoop", 1000},
	{1005, TUNING_CATEGORIE_HOOD, "Fury Scoop", 1000},
	{1011, TUNING_CATEGORIE_HOOD, "Race Scoop", 1000},
	{1012, TUNING_CATEGORIE_HOOD, "Worx Scoop", 1000},
	
	/*
	{1100,    "Bullbars","Chrome Grill", 5000},
	{1123,    "Bullbars","Chrome Bars", 5000},
	{1125,    "Bullbars","Chrome Lights", 5000},
	*/
	
	{0, TUNING_CATEGORIE_FRONT_BUMPER, "Standart", 250},
	{1117, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	{1152, TUNING_CATEGORIE_FRONT_BUMPER, "X-Flow", 7500},
	{1153, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1155, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1157, TUNING_CATEGORIE_FRONT_BUMPER, "X-Flow", 7500},
	{1160, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1160, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1165, TUNING_CATEGORIE_FRONT_BUMPER, "X-Flow", 7500},
	{1166, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1169, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1170, TUNING_CATEGORIE_FRONT_BUMPER, "X-Flow", 7500},
	{1171, TUNING_CATEGORIE_FRONT_BUMPER, "Alien", 7500},
	{1172, TUNING_CATEGORIE_FRONT_BUMPER, "X-Flow", 7500},
	{1173, TUNING_CATEGORIE_FRONT_BUMPER, "X-Flow", 7500},
	{1174, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	{1176, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	{1179, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	{1181, TUNING_CATEGORIE_FRONT_BUMPER, "Slamin", 5000},
	{1182, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	{1185, TUNING_CATEGORIE_FRONT_BUMPER, "Slamin", 5000},
	{1188, TUNING_CATEGORIE_FRONT_BUMPER, "Slamin", 5000},
	{1189, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	{1190, TUNING_CATEGORIE_FRONT_BUMPER, "Slamin", 5000},
	{1191, TUNING_CATEGORIE_FRONT_BUMPER, "Chrome", 5000},
	
	{0, TUNING_CATEGORIE_REAR_BUMPER, "Standart", 250},
	{1140, TUNING_CATEGORIE_REAR_BUMPER, "X-Flow", 7500},
	{1141, TUNING_CATEGORIE_REAR_BUMPER, "Alien", 7500},
	{1148, TUNING_CATEGORIE_REAR_BUMPER, "X-Flow", 7500},
	{1149, TUNING_CATEGORIE_REAR_BUMPER, "Alien", 7500},
	{1150, TUNING_CATEGORIE_REAR_BUMPER, "Alien", 7500},
	{1151, TUNING_CATEGORIE_REAR_BUMPER, "X-Flow", 7500},
	{1154, TUNING_CATEGORIE_REAR_BUMPER, "Alien", 7500},
	{1156, TUNING_CATEGORIE_REAR_BUMPER, "X-Flow", 7500},
	{1159, TUNING_CATEGORIE_REAR_BUMPER, "Alien", 7500},
	{1161, TUNING_CATEGORIE_REAR_BUMPER, "X-Flow", 7500},
	{1167, TUNING_CATEGORIE_REAR_BUMPER, "X-Flow", 7500},
	{1168, TUNING_CATEGORIE_REAR_BUMPER, "Alien", 7500},
	{1175, TUNING_CATEGORIE_REAR_BUMPER, "Slamin", 5000},
	{1177, TUNING_CATEGORIE_REAR_BUMPER, "Slamin", 5000},
	{1178, TUNING_CATEGORIE_REAR_BUMPER, "Slamin", 5000},
	{1180, TUNING_CATEGORIE_REAR_BUMPER, "Chrome", 5000},
	{1183, TUNING_CATEGORIE_REAR_BUMPER, "Slamin", 5000},
	{1184, TUNING_CATEGORIE_REAR_BUMPER, "Chrome", 5000},
	{1186, TUNING_CATEGORIE_REAR_BUMPER, "Slamin", 5000},
	{1187, TUNING_CATEGORIE_REAR_BUMPER, "Chrome", 5000},
	{1192, TUNING_CATEGORIE_REAR_BUMPER, "Chrome", 5000},
	{1193, TUNING_CATEGORIE_REAR_BUMPER, "Slamin", 5000},
	
	{0, TUNING_CATEGORIE_VENTS, "Standart", 250},
	{1143, TUNING_CATEGORIE_VENTS, "Oval", 1000},
	{1145, TUNING_CATEGORIE_VENTS, "Square", 1000},
	
	{0, TUNING_CATEGORIE_ROOF, "Standart", 250},
	{1032, TUNING_CATEGORIE_ROOF, "Alien", 10000},
	{1006, TUNING_CATEGORIE_ROOF, "Scoop", 10000},
	{1038, TUNING_CATEGORIE_ROOF, "Alien", 10000},
	{1035, TUNING_CATEGORIE_ROOF, "X-Flow", 10000},
	{1033, TUNING_CATEGORIE_ROOF, "X-Flow", 10000},
	{1053, TUNING_CATEGORIE_ROOF, "X-Flow", 10000},
	{1054, TUNING_CATEGORIE_ROOF, "Alien", 10000},
	{1055, TUNING_CATEGORIE_ROOF, "Alien", 10000},
	{1061, TUNING_CATEGORIE_ROOF, "X-Flow", 10000},
	{1067, TUNING_CATEGORIE_ROOF, "Alien", 10000},
	{1068, TUNING_CATEGORIE_ROOF, "X-Flow", 10000},
	{1088, TUNING_CATEGORIE_ROOF, "Alien", 10000},
	{1091, TUNING_CATEGORIE_ROOF, "X-Flow", 10000},
	{1103, TUNING_CATEGORIE_ROOF, "Covertible", 10000},
	{1128, TUNING_CATEGORIE_ROOF, "Vinyl Hardtop", 10000},
	{1130, TUNING_CATEGORIE_ROOF, "Hardtop", 10000},
	{1131, TUNING_CATEGORIE_ROOF, "Softtop", 10000},
	
	{0, TUNING_CATEGORIE_LAMPS, "Standart", 250},
	{1013, TUNING_CATEGORIE_LAMPS, "Round Fog", 500},
	{1024, TUNING_CATEGORIE_LAMPS, "Square Fog", 500},
	
	/*
	{1109,    "Rear Bullbars", "Chrome", 5000},
	{1110,    "Rear Bullbars", "Slamin", 5000},
	{1115,    "Front Bullbars", "Chrome", 5000},
	{1116,    "Front Bullbars", "Slamin", 5000},
	*/
	
	{0, TUNING_CATEGORIE_EXHAUST, "Standart", 250},
	{1018, TUNING_CATEGORIE_EXHAUST, "Upswept", 800},
	{1019, TUNING_CATEGORIE_EXHAUST, "Twin",1000},
	{1020, TUNING_CATEGORIE_EXHAUST, "Large", 800},
	{1021, TUNING_CATEGORIE_EXHAUST, "Medium", 800},
	{1022, TUNING_CATEGORIE_EXHAUST, "Small", 800},
	{1028, TUNING_CATEGORIE_EXHAUST, "Alien", 800},
	{1029, TUNING_CATEGORIE_EXHAUST, "X-Flow", 800},
	{1034, TUNING_CATEGORIE_EXHAUST, "Alien", 800},
	{1037, TUNING_CATEGORIE_EXHAUST, "X-Flow", 800},
	{1043, TUNING_CATEGORIE_EXHAUST, "Slamin", 800},
	{1044, TUNING_CATEGORIE_EXHAUST, "Chrome", 800},
	{1045, TUNING_CATEGORIE_EXHAUST, "X-Flow", 800},
	{1046, TUNING_CATEGORIE_EXHAUST, "Alien", 800},
	{1059, TUNING_CATEGORIE_EXHAUST, "X-Flow", 800},
	{1064, TUNING_CATEGORIE_EXHAUST, "Alien", 800},
	{1065, TUNING_CATEGORIE_EXHAUST, "Alien", 800},
	{1066, TUNING_CATEGORIE_EXHAUST, "X-Flow", 800},
	{1092, TUNING_CATEGORIE_EXHAUST, "Alien", 800},
	{1089, TUNING_CATEGORIE_EXHAUST, "X-Flow", 800},
	{1126, TUNING_CATEGORIE_EXHAUST, "Chrome", 800},
	{1127, TUNING_CATEGORIE_EXHAUST, "Slamin", 800},
	{1129, TUNING_CATEGORIE_EXHAUST, "Chrome", 800},
	{1113, TUNING_CATEGORIE_EXHAUST, "Chrome", 800},
	{1114, TUNING_CATEGORIE_EXHAUST, "Slamin", 800},
	{1104, TUNING_CATEGORIE_EXHAUST, "Chrome", 800},
	{1105, TUNING_CATEGORIE_EXHAUST, "Slamin", 800},
	{1132, TUNING_CATEGORIE_EXHAUST, "Slamin", 800},
	{1135, TUNING_CATEGORIE_EXHAUST, "Slamin", 800},
	{1136, TUNING_CATEGORIE_EXHAUST, "Chrome", 800},
	
	{0, TUNING_CATEGORIE_SIDESKIRTS, "Standart", 250},
	{1007, TUNING_CATEGORIE_SIDESKIRTS, "Sideskirt", 750},
	{1026, TUNING_CATEGORIE_SIDESKIRTS, "Alien", 1000},
	{1031, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1036, TUNING_CATEGORIE_SIDESKIRTS, "Alien", 1000},
	{1039, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1041, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1042, TUNING_CATEGORIE_SIDESKIRTS, "Chrome", 750},
	{1047, TUNING_CATEGORIE_SIDESKIRTS, "Alien", 1000},
	{1048, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1056, TUNING_CATEGORIE_SIDESKIRTS, "Alien", 1000},
	{1057, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1069, TUNING_CATEGORIE_SIDESKIRTS, "Alien", 1000},
	{1070, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1090, TUNING_CATEGORIE_SIDESKIRTS, "Alien", 1000},
	{1093, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1095, TUNING_CATEGORIE_SIDESKIRTS, "X-Flow", 1000},
	{1106, TUNING_CATEGORIE_SIDESKIRTS, "Chrome Arches", 750},
	{1108, TUNING_CATEGORIE_SIDESKIRTS, "Chrome Strip", 750},
	{1118, TUNING_CATEGORIE_SIDESKIRTS, "Chrome Trim", 750},
	{1119, TUNING_CATEGORIE_SIDESKIRTS, "Wheelcovers", 750},
	{1122, TUNING_CATEGORIE_SIDESKIRTS, "Chrome Flames", 750},
	{1133, TUNING_CATEGORIE_SIDESKIRTS, "Chrome Strip", 750},
	{1134, TUNING_CATEGORIE_SIDESKIRTS, "Chrome Strip", 750},
	
	{0, TUNING_CATEGORIE_TIRES, "Standart", 250},
	{1200, TUNING_CATEGORIE_TIRES, "Bullet-Proof Tires", 5000}
};

enum E_TUNING_ORDER
{
	tuning_order_active,
	tuning_order_mechanic_id,
	tuning_order_component_id,
	tuning_order_activity_timer,
	tuning_order_install_progress,
	tuning_order_done
}
new TuningOrders[MAX_TUNING_ORDERS][E_TUNING_ORDER];

enum E_TUNING_CUSTOMER
{
    tuning_customer_id,
	tuning_vehicle_id
}
new TuningCustomerInfo[E_TUNING_CUSTOMER];

stock ChangeVehiclePaintjobEx(vehicleid, paintjobid)
{
	new pjid;
	switch(paintjobid)
	{
	    case 0: pjid = 3;
	    case 1..3: pjid = paintjobid-1;
	    default: return 0;
	}
    ChangeVehiclePaintjob(vehicleid, pjid);
    return 1;
}

stock InstallTuningElement(vehicleid, elementid)
{
	new categorie = TuningElements[elementid][tuning_element_categorie_id];
    if(IsAUniversalTuningElement(elementid))
	{
		if(TuningElements[elementid][tuning_element_categorie_id] == TUNING_CATEGORIE_COLOR)
		{
			ChangeVehicleColor(vehicleid, TuningElements[elementid][tuning_element_id], 0);
		}
	}
	else
	{
    	//AddVehicleComponent(vehicle_id, TuningElements[element_id][tuning_element_id]);
    	if(TuningElements[elementid][tuning_element_categorie_id] == TUNING_CATEGORIE_PAINTJOB)
    	{
			ChangeVehiclePaintjobEx(vehicleid, TuningElements[elementid][tuning_element_id]);
    	}
    	else
    	{
        	if(!TuningElements[elementid][tuning_element_id])
		        RemoveVehicleComponent(vehicleid, VehicleInfo[vehicleid][vehicle_tuning_elements][TuningElements[elementid][tuning_element_categorie_id]]);
			else
			{
   				if(categorie == TUNING_CATEGORIE_SPOILER)
			    {
			        switch(GetVehicleModel(vehicleid))
			        {
			            case 411: return 1;
			            case 541: return 1;
			        }
			    }
			    else if(categorie == TUNING_CATEGORIE_NEON)
			    {
			        switch(GetVehicleModel(vehicleid))
			        {
			            case 411: return 1;
			            case 541: return 1;
			            case 560: return 1;
			        }
			    }
			    else if(categorie == TUNING_CATEGORIE_STYLING)
			    {
			        switch(GetVehicleModel(vehicleid))
			        {
			            case 411: return 1;
			            case 541: return 1;
			            case 560: return 1;
			        }
			    }
			    
				AddVehicleComponent(vehicleid, TuningElements[elementid][tuning_element_id]);
			}
		}
    }
    return 1;
}

function SecondTimer()
{
	for(new i; i<MAX_TUNING_ORDERS; i++)
	{
	    if(!TuningOrders[i][tuning_order_active]) continue;
	    if(TuningOrders[i][tuning_order_done]) continue;
	    if(TuningOrders[i][tuning_order_mechanic_id] == -1 || !IsPlayerConnected(TuningOrders[i][tuning_order_mechanic_id])) continue;
	    
	    if(TuningOrders[i][tuning_order_install_progress] > 0)
	    {
            TuningOrders[i][tuning_order_install_progress]--;
            if(TuningOrders[i][tuning_order_install_progress] <= 0)
            {
                new
					vehicle_id = TuningCustomerInfo[tuning_vehicle_id],
					customer_id = TuningCustomerInfo[tuning_customer_id],
					mechanic_id = TuningOrders[i][tuning_order_mechanic_id],
					element_id = TuningOrders[i][tuning_order_component_id];
					
				InstallTuningElement(vehicle_id, element_id);
                
                VehicleInfo[vehicle_id][vehicle_tuning_elements][TuningElements[element_id][tuning_element_categorie_id]] = TuningElements[element_id][tuning_element_id];
                PlayerPlaySound(mechanic_id, 1133, 0.0, 0.0, 0.0);
                
                TuningOrders[i][tuning_order_done] = 1;
                
                //ApplyAnimation
                
                TogglePlayerControllable(mechanic_id, 1);
                
                TempInfo[mechanic_id][temp_tuning_order_id] = INVALID_TUNING_ORDER;
                
                new
					level = uInfo[mechanic_id][uTuningMechanicLevel],
					payment = floatround((TuningElements[element_id][tuning_element_price]/100)*TuningMechanicLevels[level][tuning_mechanic_pay_percent], floatround_round);
                
                GiveMoney(mechanic_id, payment);
                
				uInfo[mechanic_id][uTuningMechanicOrders]++;
                TuningMechanicCheckLevel(mechanic_id);
                
				ClearAnimations(mechanic_id);
                
                format:g_str_least("~g~+%d", payment);
                GameTextForPlayer(mechanic_id, g_str_least, 2500, 6);
                
                new element_count;
                for(new o; o<MAX_TUNING_ORDERS; o++)
                {
                    if(!TuningOrders[o][tuning_order_active]) continue;
                    if(TuningOrders[o][tuning_order_done]) continue;
                    element_count++;
                }

				if(element_count)
				{
				    format:g_str_small("[Tuning]: Механик {ffffff}%s[%d] {33AA33}установил {ffffff}'%s %s' {33AA33}на ваш автомобиль", uInfo[mechanic_id][uName], mechanic_id, TuningCategories[TuningElements[element_id][tuning_element_categorie_id]][tuning_categorie_name_rus], TuningElements[element_id][tuning_element_name]);
                	SendClientMessage(customer_id, COLOR_GREEN, g_str_small);
                	
                	SendClientMessage(mechanic_id, COLOR_GREEN, "[Tuning]: Элемент установлен. Возьмите следующий заказ.");
				}
                else
				{
				    PutPlayerInVehicle(customer_id, vehicle_id);
				    
					SetPlayerInterior(customer_id, 0);
					SetPlayerVirtualWorld(customer_id, 0);
					SetVehiclePos(vehicle_id, 972.6981,-1263.9279,15.9363);
					SetVehicleZAngle(vehicle_id, 180.0);
					LinkVehicleToInterior(vehicle_id, GetPlayerInterior(playerid));
					SetVehicleVirtualWorld(vehicle_id, GetPlayerVirtualWorld(playerid));

					SetCameraBehindPlayer(playerid);
					
					ClearTuningOrderData();
				
                    format:g_str_small("[Tuning]: Механик {ffffff}%s[%d]{33AA33} установил {ffffff}'%s %s' {33AA33}на ваш автомобиль. Ваш заказ выполнен.", uInfo[mechanic_id][uName], mechanic_id, TuningCategories[TuningElements[element_id][tuning_element_categorie_id]][tuning_categorie_name_rus], TuningElements[element_id][tuning_element_name]);
                	SendClientMessage(customer_id, COLOR_GREEN, g_str_small);

                	SendClientMessage(mechanic_id, COLOR_GREEN, "[Tuning]: Элемент установлен. Заказ клиента выполнен.");
				}
                
            }
	    }
	}
}

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	
	LoadMap();
	LoadTD();
	
	CreatePickup(1275, 23, 434.8695,-864.2725,2739.4128, -1);
	Create3DTextLabel("Работа тюнинг-механика\nНажмите 'ALT'", 0xFFFFFFFF, 434.8695,-864.2725,2739.4128, 10.0, 0, 1);
	
	Create3DTextLabel("Тюнинг\nПосигнальте ('H')", 0xFFFFFFFF, -1255.9907,16.9513,357.4799, 10.0, 0, 1);
	
	CreatePickup(1318, 23, 426.4958,-862.5667,2735.6948, -1);
	Create3DTextLabel("Склад\nНажмите 'ALT'", 0xFFFFFFFF, 426.4958,-862.5667,2735.6948, 10.0, 0, 1);
	
	CreatePickup(1318, 23, 491.1347,-865.1960,2738.5400, -1);
	Create3DTextLabel("Нажмите 'ALT'", 0xFFFFFFFF, 491.1347,-865.1960,2738.5400, 10.0, 0, 1);
	
	CreatePickup(19832, 23, 502.6337,-865.2659,2738.5400, -1);
	Create3DTextLabel("Нажмите 'ALT'", 0xFFFFFFFF, 502.6337,-865.2659,2738.5400, 10.0, 0, 1);
	
	SetTimer("SecondTimer", 1000, true);
	
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
	GetPlayerName(playerid, uInfo[playerid][uName], MAX_PLAYER_NAME);

	GiveMoney(playerid, 50_000);

	LoadPlayerTD(playerid);
	return 1;
}

/*public OnPlayerDisconnect(playerid, reason)
{
	if(TuningCustomerInfo[tuning_customer_id] == playerid)
	{
		DestroyVehicle(TuningCustomerInfo[tuning_customer_id]);
		for(new i; i<MAX_TUNING_ORDERS; i++)
		{
		    if(!TuningOrders[i][tuning_order_active]) continue;
		    if(TuningOrders[i][tuning_order_done]) continue;
		    
		    new
				vehicle_id = TuningCustomerInfo[tuning_vehicle_id],
				customer_id = TuningCustomerInfo[tuning_customer_id],
				mechanic_id = TuningOrders[i][tuning_order_mechanic_id],
				element_id = TuningOrders[i][tuning_order_component_id];
		    
		    if(TuningOrders[i][tuning_order_install_progress])
		    {
		        TogglePlayerControllable(mechanic_id, 1);
		        TempInfo[mechanic_id][temp_tuning_order_id] = INVALID_TUNING_ORDER;

				ClearAnimations(mechanic_id);
		    }
		    
		    GiveMoney(playerid, TuningElements[element_id][tuning_element_price]);
		}
	}
	if(GetPVarInt(playerid, "TuneMechanic:Active"))
	{
	    new
	        customer_id = TuningCustomerInfo[tuning_customer_id],
			order_id = TempInfo[playerid][temp_tuning_order_id],
			mechanics, cashback;
			
		if(order_id != INVALID_TUNING_ORDER)
		{
		    TuningOrders[order_id][tuning_order_install_progress] = 0;
            TuningOrders[order_id][tuning_order_mechanic_id] = -1;
		}
		
		foreach(new Player:i)
		{
		    if(GetPVarInt(i, "TuneMechanic:Active"))
		    {
		        mechanics++;
		    }
		}
		
		if(!mechanics)
		{

            for(new i; i<MAX_TUNING_ORDERS; i++)
			{
			    if(!TuningOrders[i][tuning_order_active]) continue;
			    if(TuningOrders[i][tuning_order_done]) continue;

			    new
					element_id = TuningOrders[i][tuning_order_component_id];

			    cashback += TuningElements[element_id][tuning_element_price];
			}

            GiveMoney(playerid, cashback);
            
            PutPlayerInVehicle(customer_id, vehicle_id);

			SetPlayerInterior(customer_id, 0);
			SetPlayerVirtualWorld(customer_id, 0);
			SetVehiclePos(vehicle_id, 972.6981,-1263.9279,15.9363);
			SetVehicleZAngle(vehicle_id, 180.0);
			LinkVehicleToInterior(vehicle_id, GetPlayerInterior(playerid));
			SetVehicleVirtualWorld(vehicle_id, GetPlayerVirtualWorld(playerid));

			SetCameraBehindPlayer(playerid);

			SendClientMessage(customer_id, COLOR_RED, "[Tuning]: В гараже отсутсвуют механики, которые могут выполнить ваш заказ.");
			format:g_str_small("[Tuning]: Вам вернули деньги за все неустановленные элементы. Сумма возврата: %d$", cashback);
			SendClientMessage(customer_id, COLOR_RED, g_str_small);
			
			ClearTuningOrderData();
		}
	}
	return 1;
}*/

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

/*public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(GetPVarInt(playerid, "TuneMechanic:Active"))
	{
		if(vehicleid == TuningCustomerInfo[tuning_vehicle_id])
		{
		    RemovePlayerFromVehicle(playerid);
			SendClientMessage(playerid, COLOR_RED, "[Tuning]: Вы не можете садиться в машину клиента");
		}
	}
	return 1;
}*/

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
	DisablePlayerCheckpoint(playerid);
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
	if(PRESSED(KEY_WALK))
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 434.8695,-864.2725,2739.4128))
		{
		    if(GetPVarInt(playerid, "TuneMechanic:Active"))
		        return ShowPlayerDialog(playerid, dTuneMechanic+1, DIALOG_STYLE_MSGBOX, "Работа", "Вы желаете уволиться с работы тюнинг-механика?", "Да", "Нет");
		    else
		        return ShowPlayerDialog(playerid, dTuneMechanic, DIALOG_STYLE_MSGBOX, "Работа", "Вы желаете устроиться на работу тюнинг-механика?", "Да", "Нет");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.5, 434.8695,-864.2725,2739.4128))
		{
		    if(GetPVarInt(playerid, "TuneMechanic:Active"))
		        return ShowPlayerDialog(playerid, dTuneMechanic+1, DIALOG_STYLE_MSGBOX, "Работа", "Вы желаете уволиться с работы тюнинг-механика?", "Да", "Нет");
		    else
		        return ShowPlayerDialog(playerid, dTuneMechanic, DIALOG_STYLE_MSGBOX, "Работа", "Вы желаете устроиться на работу тюнинг-механика?", "Да", "Нет");
		}
		if(GetPVarInt(playerid, "TuneMechanic:Active"))
  		{
			if(IsPlayerInRangeOfPoint(playerid, 1.5, 435.3391,-861.4870,2739.4128))
			{
			    if(TempInfo[playerid][temp_tuning_order_id] == INVALID_TUNING_ORDER)
			    {
					
			    }
			}
			if(IsPlayerInRangeOfPoint(playerid, 1.5, 502.6337,-865.2659,2738.5400))
			{
			    if(TempInfo[playerid][temp_tuning_order_id] == INVALID_TUNING_ORDER)
			    {
			        for(new i; i<MAX_TUNING_ORDERS; i++)
				    {
				        if(!TuningOrders[i][tuning_order_active]) continue;
            			if(TuningOrders[i][tuning_order_done]) continue;
            			if(TuningOrders[i][tuning_order_mechanic_id] != -1) continue;

						new
							element_id = TuningOrders[i][tuning_order_component_id],
							vehicle_id = TuningCustomerInfo[tuning_vehicle_id],
							Float:vPos[3];

		                TuningOrders[i][tuning_order_mechanic_id] = playerid;

		                TempInfo[playerid][temp_tuning_order_id] = i;

						GetVehiclePos(vehicle_id, vPos[0], vPos[1], vPos[2]);
					    SetPlayerCheckpoint(playerid, vPos[0], vPos[1], vPos[2], 3.0);
					    
					    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
					    SetPlayerAttachedObject(playerid, 0, 19832, 3, 0.4329, -0.4319, -0.1679, 0.0000, -90.1999, 17.7000, 1.0000, 1.0000, 1.0000, 0, 0);

						format:g_str_small("[Tuning]: Вы взяли {ffffff}'%s %s'{33AA33}. Теперь установите его на автомобиль на автомобиль.", TuningCategories[TuningElements[element_id][tuning_element_categorie_id]][tuning_categorie_name_rus], TuningElements[element_id][tuning_element_name]);
						SendClientMessage(playerid, COLOR_GREEN, g_str_small);
						return 1;
				        //format(g_str_big, sizeof(g_str_big), "%s%s\t%s\n", g_str_big, TuningElements[element_id][tuning_element_name], uInfo[customer_id][uName]);
				    }
			    }
			}
			if(IsPlayerInRangeOfPoint(playerid, 1.5, 426.4958,-862.5667,2735.6948))
			{
			    SetPlayerPos(playerid, 492.9628,-865.2958,2738.5400);
			    SetPlayerFacingAngle(playerid, 270.0);
			    return 1;
			}
			if(IsPlayerInRangeOfPoint(playerid, 1.5, 491.1347,-865.1960,2738.5400))
			{
			    SetPlayerPos(playerid, 425.2935,-863.9637,2735.6948);
			    SetPlayerFacingAngle(playerid, 270.0);
                return 1;
			}
			if(TempInfo[playerid][temp_tuning_order_id] != INVALID_TUNING_ORDER)
		    {
        		new
					order_id = TempInfo[playerid][temp_tuning_order_id],
					vehicle_id = TuningCustomerInfo[tuning_vehicle_id],
					customer_id = TuningCustomerInfo[tuning_customer_id],
					element_id = TuningOrders[order_id][tuning_order_component_id],
					level = uInfo[playerid][uTuningMechanicLevel],
					Float:vPos[3];
					
                if(TuningOrders[order_id][tuning_order_install_progress] > 0) return 1;
					
				GetVehiclePos(vehicle_id, vPos[0], vPos[1], vPos[2]);
				if(IsPlayerInRangeOfPoint(playerid, 3.0, vPos[0], vPos[1], vPos[2]))
				{
				    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
					RemovePlayerAttachedObject(playerid, 0);
				    ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_LOOP", 4.1, true, false, false, false, 0, false);
				
					TogglePlayerControllable(playerid, 0);
					TuningOrders[order_id][tuning_order_install_progress] = TuningMechanicLevels[level][tuning_mechanic_execution_time];
					
				    format:g_str_small("[Tuning]: Механик {ffffff}%s[%d] {33AA33}начал установку {ffffff}'%s %s' {33AA33}на ваш автомобиль", uInfo[playerid][uName], playerid, TuningCategories[TuningElements[element_id][tuning_element_categorie_id]][tuning_categorie_name_rus], TuningElements[element_id][tuning_element_name]);
				    SendClientMessage(customer_id, COLOR_GREEN, g_str_small);
				    SendClientMessage(playerid, COLOR_GREEN, "[Tuning]: Элемент устанавливается");
				}
			}
		}
	}
	if(PRESSED(KEY_CTRL_BACK))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if()
	    }
	}
	if(PRESSED(KEY_FIRE))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetPVarInt(playerid, "Tuning:Active") == 1)
	        {
	            g_str_cmd = "{ffffff}Выбранные вами элементы тюнинга будут установлены механиком\n\nСписок предметов:\n";
	            
	            new final_price;
	            
         		for(new i; i<MAX_TUNING_CATEGORIES; i++)
         		    if(TempInfo[playerid][temp_selected_tuning_elements][i] != 0)
         		    {
         		        if(TempInfo[playerid][temp_selected_tuning_elements][i] != VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][i])
         		        {
         		        	format(g_str_cmd, sizeof(g_str_cmd), "%s{ffffff}{2451FF} > {FFFFFF}%s '%s' - {008000}%d$\n", g_str_cmd,
				 			TuningCategories[TuningElements[TempInfo[playerid][temp_selected_tuning_elements][i]][tuning_element_categorie_id]][tuning_categorie_name_rus],
				 			TuningElements[TempInfo[playerid][temp_selected_tuning_elements][i]][tuning_element_name],
				 			TuningElements[TempInfo[playerid][temp_selected_tuning_elements][i]][tuning_element_price]);
				 			
				 			final_price += TuningElements[TempInfo[playerid][temp_selected_tuning_elements][i]][tuning_element_price];
         		        }
         		    }
                format(g_str_cmd, sizeof(g_str_cmd), "%s\n{ffffff}Общая стоимость: {008000}%d$\n", g_str_cmd, final_price);

				strcat(g_str_cmd, "{ffffff}Желаете подтвердить заказ?");
				
				SetPVarInt(playerid, "Tuning:Price", final_price);
				
	        	ShowPlayerDialog(playerid, dTuningOrder, DIALOG_STYLE_MSGBOX, "Заказ тюнинга", g_str_cmd, "Да", "Нет");
	        }
	    }
	}
	if(PRESSED(KEY_SPRINT))
	{
	    if(IsPlayerInAnyVehicle(playerid) )
	    {
	        /*if(GetPVarInt(playerid, "Tuning:Active") == 1)
	        {
	            TogglePlayerControllable(playerid, 1);

				new veh = GetPlayerVehicleID(playerid);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				SetVehiclePos(veh, 1743.4945,1860.7477,10.6003);
				SetVehicleZAngle(veh, 0.0);
				LinkVehicleToInterior(veh, GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(veh, GetPlayerVirtualWorld(playerid));

				SetCameraBehindPlayer(playerid);

			    HideTuning(playerid);

				SetPVarInt(playerid, "Tuning:Active", 0);
	        }*/
	        else if(GetPVarInt(playerid, "Tuning:Active") == 2)
	        {
	            GetPlayerCameraPos(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2]);
				InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 417.032958, -872.375427, 2737.866943, 2000);
				InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 421.777221, -872.895935, 2736.376708, 2000);

				SetPVarInt(playerid, "Tuning:Active", 1);
				
				ShowTuningCategories(playerid);
			}
		}
	}
	if(PRESSED(KEY_NO))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetPVarInt(playerid, "Tuning:Active") == 1)
	        	ShowNextCategorie(playerid);
			else if(GetPVarInt(playerid, "Tuning:Active") == 2)
			    ShowNextElement(playerid);
	    }
	}
	if(PRESSED(KEY_YES))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetPVarInt(playerid, "Tuning:Active") == 1)
	        	ShowPreviousCategorie(playerid);
			else if(GetPVarInt(playerid, "Tuning:Active") == 2)
			    ShowPreviousElement(playerid);
	    }
	}
	if(PRESSED(KEY_SECONDARY_ATTACK))
	{
	    if(IsPlayerInAnyVehicle(playerid))
	    {
			if(GetPVarInt(playerid, "Tuning:Active") == 1)
			{
				//показываем список элементов тюнинга
				new item = TempInfo[playerid][temp_selected_td_item];
				TempInfo[playerid][temp_selected_categorie] = TempInfo[playerid][temp_selected_categories][item];
				
                TuningReCamera(playerid);

                SetPVarInt(playerid, "Tuning:Active", 2);
				new categorie = TempInfo[playerid][temp_selected_categories][item];
				
                ShowTuningElements(playerid, categorie);
                
                return 1;
			}
			else if(GetPVarInt(playerid, "Tuning:Active") == 2)
			{
			    //предлагаем ему купить элемент
				new
					item = TempInfo[playerid][temp_selected_categories][TempInfo[playerid][temp_selected_td_item]],
					veh = GetPlayerVehicleID(playerid);
					
				if(TempInfo[playerid][temp_selected_tuning_elements][TuningElements[item][tuning_element_categorie_id]] == item)
				{
					/*if(!IsAUniversalTuningElement(item))
					{
						RemoveVehicleComponent(GetPlayerVehicleID(playerid), TuningElements[item][tuning_element_id]);
						if(VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][TuningElements[item][tuning_element_categorie_id]] != 0)
						{
						    AddVehicleComponent(GetPlayerVehicleID(playerid), VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][TuningElements[item][tuning_element_categorie_id]]);
						}
					}
					else
					{
						if(TuningElements[item][tuning_element_categorie_id] == 1)
						{
							ChangeVehicleColor(GetPlayerVehicleID(playerid), VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][TuningElements[item][tuning_element_categorie_id]], 0);
						}
					}

					format:g_str_least("%d$", TuningElements[item][tuning_element_price]);
					PlayerTextDrawSetString(playerid, TuningItemTD[playerid][TempInfo[playerid][temp_selected_td_item]][1], g_str_least);
								
					PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					TempInfo[playerid][temp_selected_tuning_elements][TuningElements[item][tuning_element_categorie_id]] = 0;*/
				}
				else
				{
				    new categorie = TuningElements[item][tuning_element_categorie_id];
				    
                    InstallTuningElement(veh, item);
                    
					for(new i; i<TempInfo[playerid][temp_selected_items_array_size]; i++)
					{
					    format:g_str_least("%d$", TuningElements[TempInfo[playerid][temp_selected_categories][i]][tuning_element_price]);
						PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][1], g_str_least);
					}

					PlayerTextDrawSetString(playerid, TuningItemTD[playerid][TempInfo[playerid][temp_selected_td_item]][1], "X");

     				PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
					/*if(categorie == TUNING_CATEGORIE_PAINTJOB)
					    TempInfo[playerid][temp_selected_tuning_elements][TUNING_CATEGORIE_COLOR] = 0;*/
					TempInfo[playerid][temp_selected_tuning_elements][categorie] = item;
				}
			}
	    }
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
	    case dTuningOrder:
	    {
	        new final_price = GetPVarInt(playerid, "Tuning:Price");
	        DeletePVar(playerid, "Tuning:Price");
	        if(!response) return 1;
	        if(GetMoney(playerid) < final_price) return SendClientMessage(playerid, COLOR_RED, "[TUNING]: Ошибка. У вас недостаточно наличных.");
	        
			TuningCustomerInfo[tuning_customer_id] = playerid;
			TuningCustomerInfo[tuning_vehicle_id] = GetPlayerVehicleID(playerid);
	        
	        for(new i, e; i<MAX_TUNING_ORDERS; i++)
			{
	            while(TempInfo[playerid][temp_selected_tuning_elements][e] == 0
				|| TempInfo[playerid][temp_selected_tuning_elements][e] == VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][e])
					if(e+1 < MAX_TUNING_CATEGORIES)
						e++;
					else goto Next;
						
	            if(!TuningOrders[i][tuning_order_active])
	            {
                    TuningOrders[i][tuning_order_component_id] = TempInfo[playerid][temp_selected_tuning_elements][e];
                    TuningOrders[i][tuning_order_mechanic_id] = -1;
                    TuningOrders[i][tuning_order_activity_timer] = 0;
                    TuningOrders[i][tuning_order_install_progress] = 0;
                    TuningOrders[i][tuning_order_active] = 1;
                    TuningOrders[i][tuning_order_done] = 0;
                    
                    RemoveVehicleComponent(TuningCustomerInfo[tuning_vehicle_id], TuningElements[TempInfo[playerid][temp_selected_tuning_elements][e]][tuning_element_id]);
                    
                    if(e+1 < MAX_TUNING_CATEGORIES)
						e++;
					else break;
	            }
	        }
	        Next:
	        SendClientMessage(playerid, COLOR_GREEN, "Ваш заказ успешно оформлен. Механик приступит к нему в ближайшее время");
	        
	        SetVehicleParamsEx(GetPlayerVehicleID(playerid), VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);
	        ChangeVehicleColor(GetPlayerVehicleID(playerid), TuningElements[VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][TUNING_CATEGORIE_COLOR]][tuning_element_id], 0);
	        ChangeVehiclePaintjobEx(GetPlayerVehicleID(playerid), TuningElements[VehicleInfo[GetPlayerVehicleID(playerid)][vehicle_tuning_elements][TUNING_CATEGORIE_PAINTJOB]][tuning_element_id]);
	        
	        GiveMoney(playerid, -final_price);
	        
	        SetPlayerPos(playerid, 436.8789,-870.8163,2739.4070);
	        SetPlayerFacingAngle(playerid, 93.0);
	        SetCameraBehindPlayer(playerid);
	        HideTuning(playerid);
	        
	        TogglePlayerControllable(playerid, 1);

			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);

			SetPVarInt(playerid, "Tuning:Active", 0);
	        
	    }
	    case dTuneMechanic:
	    {
	        if(!response) return 1;
				
			if(!uInfo[playerid][uTuningMechanicLevel])
			    uInfo[playerid][uTuningMechanicLevel] = 1;
			    
            new
				level = uInfo[playerid][uTuningMechanicLevel];
					
			SetPlayerSkin(playerid, TuningMechanicLevels[level][tuning_mechanic_skin_id]);
			SetPVarInt(playerid, "TuneMechanic:Active", 1);
			TempInfo[playerid][temp_tuning_order_id] = INVALID_TUNING_ORDER;
	    }
	    case dTuneMechanic+1:
	    {
	        if(!response) return 1;
			SetPlayerSkin(playerid, 0);
			SetPVarInt(playerid, "TuneMechanic:Active", 0);
			TempInfo[playerid][temp_tuning_order_id] = INVALID_TUNING_ORDER;
	    }
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	if(VehicleInfo[vehicleid][vehicle_tuning_elements][13] == 1200)
	{
		new
		    panels,
			doors,
			lights,
			tires;

	    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	    tires = 0;

	    UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
    }
}

stock GetMoney(playerid)
{
	if(IsPlayerConnected(playerid))
	return uInfo[playerid][uMoney];
	
	return 0;
}
stock GiveMoney(playerid, money)
{
    if(IsPlayerConnected(playerid))
    {
        uInfo[playerid][uMoney] += money;
        ResetPlayerMoney(playerid);
  		GivePlayerMoney(playerid, uInfo[playerid][uMoney]);
		return 1;
	}
	
	return 0;
}

stock LoadMap()
{
    //Map Exported with Texture Studio By: [uL]Pottus////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//Objects////////////////////////////////////////////////////////////////////////////////////////////////////////
	new tmpobjid;
	tmpobjid = CreateDynamicObject(19379,426.844,-864.930,2734.609,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,426.844,-874.561,2734.609,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,432.167,-864.994,2736.656,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,432.147,-861.718,2738.320,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,437.337,-864.947,2738.321,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,426.844,-864.930,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,432.167,-864.994,2733.163,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,432.169,-874.624,2733.163,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,426.966,-861.724,2733.163,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,431.696,-866.454,2733.163,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,427.266,-879.794,2736.216,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(11319,432.126,-874.508,2735.084,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16093, "a51_ext", "alleydoor9b", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,432.167,-882.943,2736.256,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,432.167,-881.873,2739.756,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,432.204,-881.077,2736.717,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,432.167,-881.873,2743.237,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,432.203,-881.078,2741.810,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,432.169,-874.624,2736.656,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,431.835,-872.147,2738.323,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,431.835,-875.347,2738.323,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,436.906,-877.144,2739.717,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19379,426.844,-874.560,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,427.266,-879.794,2739.717,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,427.266,-879.794,2743.229,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19379,426.844,-884.191,2734.609,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,426.844,-884.191,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,417.637,-879.794,2736.216,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,417.637,-879.794,2739.717,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,417.637,-879.794,2743.229,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,420.682,-874.282,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,420.682,-874.272,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(10282,428.693,-875.830,2734.795,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 3, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 4, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 5, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 6, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 7, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 8, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 9, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 10, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 11, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 12, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 13, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 14, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 15, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,427.266,-860.044,2736.216,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,427.266,-860.044,2739.707,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,427.266,-860.044,2743.199,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,417.637,-860.044,2736.216,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,417.637,-860.044,2739.707,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,417.637,-860.044,2743.199,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-864.930,2734.609,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-874.561,2734.609,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-884.191,2734.609,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,416.254,-861.750,2736.256,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,416.254,-861.750,2739.756,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,416.254,-861.750,2743.237,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.217,-859.896,2736.717,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.216,-863.616,2736.717,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.217,-863.616,2741.810,0.000,179.999,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.216,-859.896,2741.810,0.000,179.999,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,416.254,-874.951,2736.256,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,416.254,-874.951,2739.756,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,416.254,-874.951,2743.237,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10398, "countryclub_sfs", "hc_wall2", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.217,-873.097,2736.717,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.216,-876.817,2736.717,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.217,-876.817,2741.810,0.000,179.999,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,416.216,-873.097,2741.810,0.000,179.999,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-864.930,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-874.560,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,416.407,-868.534,2736.436,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19359,416.408,-868.164,2736.436,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19359,416.407,-868.534,2739.937,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19359,416.408,-868.164,2739.937,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19359,416.407,-868.534,2743.431,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19359,416.408,-868.164,2743.431,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19359,416.417,-868.374,2740.158,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 5069, "ctscene_las", "cleargraf02_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(18880,416.472,-879.562,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-879.552,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,426.742,-860.260,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,426.742,-860.250,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-860.260,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-860.250,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-866.452,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-866.442,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-870.262,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,416.472,-870.252,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,438.796,-872.364,2739.717,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,438.796,-862.734,2739.717,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,431.952,-878.252,2738.996,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,431.952,-878.242,2738.996,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19379,416.344,-884.190,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,426.966,-861.724,2736.656,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,431.696,-866.454,2736.656,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19940,427.729,-867.535,2734.714,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,428.009,-867.535,2734.914,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,428.279,-867.535,2735.124,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,428.569,-867.535,2735.334,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,428.849,-867.535,2735.554,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,429.149,-867.535,2735.775,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,429.399,-867.535,2735.995,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,429.679,-867.535,2736.215,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,429.999,-867.535,2736.435,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,431.051,-867.487,2736.681,-89.999,89.999,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,431.691,-867.487,2736.682,-89.999,89.999,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,431.051,-867.447,2736.612,89.999,84.355,-84.355,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,431.691,-867.447,2736.611,89.999,84.355,-84.355,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,431.808,-867.727,2736.616,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19427,431.808,-867.336,2736.616,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-868.595,2736.886,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-868.895,2737.096,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-869.165,2737.316,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-869.444,2737.536,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-869.724,2737.757,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-870.024,2737.967,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19940,431.089,-870.325,2738.137,0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,441.296,-860.053,2739.717,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,431.666,-860.053,2739.717,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,431.666,-860.053,2743.218,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19464,419.516,-860.006,2736.717,0.000,0.000,449.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,423.696,-860.007,2736.717,0.000,0.000,449.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,419.516,-860.007,2741.799,0.000,-179.999,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19464,423.696,-860.006,2741.799,0.000,-179.999,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 12846, "coe_offtrackshop", "des_pylon1", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,437.337,-874.577,2738.321,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,431.836,-875.447,2738.324,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(18880,430.212,-870.672,2738.406,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19379,437.343,-864.930,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,437.343,-874.560,2743.494,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,436.906,-877.144,2743.218,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,438.796,-872.364,2743.218,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,438.796,-862.734,2743.218,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19447,441.296,-860.053,2743.218,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18880,430.192,-868.392,2736.653,0.000,179.999,-179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(1319,427.588,-868.439,2735.205,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,430.138,-868.439,2737.167,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,430.138,-870.629,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,430.138,-876.978,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,427.655,-868.444,2735.619,0.000,51.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,428.044,-868.443,2735.936,0.000,51.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,427.655,-868.444,2735.289,0.000,51.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,428.044,-868.443,2735.605,0.000,51.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.129,-868.420,2737.551,-0.000,51.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.130,-868.544,2737.652,-0.000,51.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.129,-868.420,2737.221,-0.000,51.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.130,-868.591,2737.360,-0.000,51.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.139,-870.677,2739.288,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.139,-873.347,2739.288,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.140,-874.227,2739.289,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.139,-870.677,2738.988,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.139,-873.347,2738.988,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.140,-874.227,2738.989,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,432.678,-876.978,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.070,-876.987,2739.289,0.000,90.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,430.070,-876.987,2738.979,0.000,90.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,432.168,-870.458,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,432.168,-866.448,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,426.958,-866.448,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(1319,426.958,-860.198,2738.958,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,432.169,-867.787,2739.288,0.000,90.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,432.170,-867.737,2738.989,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,432.171,-866.467,2738.990,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,432.171,-866.467,2739.290,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,429.439,-866.457,2739.288,0.000,90.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.969,-866.456,2739.289,0.000,90.000,360.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,429.439,-866.457,2738.988,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.969,-866.456,2738.989,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.953,-863.741,2739.288,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.954,-861.271,2739.289,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.953,-863.741,2738.988,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.954,-861.271,2738.989,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.955,-860.231,2739.288,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19957,426.955,-860.231,2738.988,-0.000,90.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(2790,438.810,-873.442,2740.378,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	SetDynamicObjectMaterial(tmpobjid, 2, 9515, "bigboxtemp1", "mullcar01_law", 0x00000000);
	tmpobjid = CreateDynamicObject(2790,438.810,-868.242,2740.378,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	SetDynamicObjectMaterial(tmpobjid, 2, 9515, "bigboxtemp1", "mullcar01_law", 0x00000000);
	tmpobjid = CreateDynamicObject(11390,425.253,-866.265,2742.217,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 3, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 4, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 5, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 6, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 7, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 8, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 9, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 10, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(11390,425.253,-884.045,2742.217,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 3, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 4, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 5, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 6, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 7, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 8, 19962, "samproadsigns", "materialtext1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 9, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 10, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,426.844,-864.930,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,426.844,-874.560,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,426.844,-884.191,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-864.930,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-874.560,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,416.344,-884.190,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,437.343,-864.930,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,437.343,-874.560,2742.123,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4830, "airport2", "scaff2flas", 0x00000000);
	tmpobjid = CreateDynamicObject(19903,419.780,-860.631,2734.695,0.000,0.000,-130.500,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(1569,426.908,-863.296,2734.695,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18200, "w_town2cs_t", "Bow_door_graffiti_128", 0x00000000);
	tmpobjid = CreateDynamicObject(3799,422.111,-878.670,2734.354,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(3799,424.831,-880.170,2734.354,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19903,420.849,-860.958,2734.695,0.000,0.000,-48.299,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(2063,416.630,-871.708,2735.595,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,416.630,-874.308,2735.595,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(3633,417.065,-876.402,2735.155,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(1271,420.391,-874.775,2735.035,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19479,424.043,-879.703,2737.887,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 4227, "graffiti_lan01", "cleargraf01_LA", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19482,435.574,-877.053,2740.107,0.000,0.000,450.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14801, "lee_bdupsmain", "Bdup_graf1", 0x00000000);
	tmpobjid = CreateDynamicObject(19482,429.744,-866.562,2735.985,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 5114, "beach_las2", "ganggraf04_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19482,429.994,-860.152,2739.867,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 5390, "glenpark7_lae", "ganggraf01_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19482,429.994,-860.152,2739.867,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 5390, "glenpark7_lae", "ganggraf01_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,430.555,-879.704,2740.514,29.399,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14801, "lee_bdupsmain", "Bdup_graf5", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,423.815,-879.704,2741.425,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 5998, "sunstr_lawn", "ganggraf02_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,418.175,-879.704,2740.714,16.199,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 5114, "beach_las2", "ganggraf04_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19399,432.916,-863.185,2740.149,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19353,434.440,-864.709,2740.147,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19383,437.632,-864.704,2740.148,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19353,432.910,-859.979,2740.147,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19379,438.087,-859.967,2738.327,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "sfe_arch10", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,438.087,-859.967,2741.810,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	tmpobjid = CreateDynamicObject(19466,432.906,-863.230,2740.268,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10839, "aircarpkbarier_sfse", "glass_64a", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,432.886,-863.022,2739.497,90.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,432.886,-863.022,2740.927,90.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,432.886,-863.992,2740.367,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(1897,432.886,-862.191,2740.367,180.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18646, "matcolours", "grey-10-percent", 0x00000000);
	tmpobjid = CreateDynamicObject(19353,438.790,-863.019,2740.147,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19353,438.790,-859.809,2740.147,0.000,0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19353,434.590,-860.069,2740.147,0.000,0.000,269.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(19353,437.800,-860.069,2740.147,0.000,0.000,269.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10023, "bigwhitesfe", "bigwhite_3", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(1569,436.817,-864.760,2738.407,0.000,0.000,-123.399,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 9515, "bigboxtemp1", "int02_128", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(14826,419.792,-877.788,2735.295,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(3799,419.911,-877.970,2734.354,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(3799,419.911,-878.720,2734.354,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(1271,421.431,-876.135,2735.035,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(1271,421.431,-876.135,2735.706,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(1271,417.921,-877.076,2735.035,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(1271,417.921,-877.076,2735.706,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,495.943,-864.411,2737.454,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,490.653,-864.420,2739.271,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(1569,490.726,-865.985,2737.540,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18200, "w_town2cs_t", "Bow_door_graffiti_128", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,495.543,-859.520,2739.271,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,491.133,-870.939,2739.271,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,495.943,-874.041,2737.454,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,490.653,-874.050,2739.271,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,506.443,-874.041,2737.454,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,506.443,-864.411,2737.454,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3984, "lanbloki", "greytile_LA", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,500.753,-870.949,2739.271,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,504.803,-872.459,2739.271,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,504.803,-862.830,2739.271,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(19447,505.173,-859.520,2739.271,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 3820, "boxhses_sfsx", "ws_mixedbrick", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.076,-869.538,2738.420,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.666,-869.558,2738.420,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.076,-869.538,2740.121,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.666,-869.558,2740.121,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.346,-869.538,2738.420,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.936,-869.558,2738.420,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.346,-869.538,2740.121,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.936,-869.558,2740.121,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,503.816,-869.538,2738.420,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,504.406,-869.558,2738.420,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,503.816,-869.538,2740.121,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,504.406,-869.558,2740.121,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.076,-860.907,2738.420,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.666,-860.927,2738.420,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.076,-860.907,2740.121,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,495.666,-860.927,2740.121,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.346,-860.907,2738.420,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.936,-860.927,2738.420,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.346,-860.907,2740.121,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,499.936,-860.927,2740.121,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,503.816,-860.907,2738.420,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,504.406,-860.927,2738.420,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,503.816,-860.907,2740.121,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(2063,504.406,-860.927,2740.121,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(931,503.827,-866.424,2738.560,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(931,503.827,-864.064,2738.560,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-868.540,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.070,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.770,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-870.390,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-870.280,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.900,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-868.870,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-868.730,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.080,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.440,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.910,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-870.291,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-870.291,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-868.761,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-868.761,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.131,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.501,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-869.881,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-870.251,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,503.828,-870.251,2740.212,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-868.540,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.070,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.770,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-870.390,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-870.280,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.900,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-868.870,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-868.730,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.080,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.440,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.910,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-870.291,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-870.291,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-868.761,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-868.761,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.131,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.501,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-869.881,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-870.251,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,504.379,-870.251,2740.212,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,495.943,-864.411,2741.095,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,495.943,-874.041,2741.095,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,506.443,-874.041,2741.095,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(19379,506.443,-864.411,2741.095,0.000,90.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 16640, "a51", "concretemanky", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-859.910,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.440,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.140,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.760,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.650,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.270,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.240,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.100,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.450,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.810,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.280,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.660,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.660,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.130,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.130,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.501,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-860.871,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.251,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.621,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.048,-861.621,2740.212,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-859.910,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.440,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.140,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.760,2738.020,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.650,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.270,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.240,2738.470,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.100,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.450,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.810,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.280,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.660,2738.911,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.660,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.130,2739.341,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.130,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.501,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 14612, "ab_abattoir_box", "ab_boxStack2", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-860.871,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 18064, "ab_sfammuunits", "gun_blackbox", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.251,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.621,2739.701,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(3013,495.599,-861.621,2740.212,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 2567, "ab", "Box_Texturepage", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,494.656,-867.681,2743.171,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,494.655,-867.401,2743.171,180.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,494.623,-867.571,2740.501,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "SPOILER'S", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,498.956,-867.681,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,498.955,-867.401,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,498.923,-867.571,2740.501,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "BUMPERS", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,503.396,-867.681,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,503.395,-867.401,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,503.363,-867.571,2740.501,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "PAINT", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,494.656,-862.910,2743.171,0.000,179.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,494.655,-862.629,2743.171,0.000,179.999,-90.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,494.623,-862.799,2740.501,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "PAINT", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,498.956,-862.910,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,498.955,-862.629,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,498.923,-862.799,2740.501,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "SPOILER'S", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,503.396,-862.910,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,503.395,-862.629,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,503.363,-862.799,2740.501,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "BUMPERS", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,503.396,-865.380,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,503.395,-865.100,2743.171,-0.000,179.999,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,503.363,-865.270,2740.501,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "NITRO", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,492.690,-860.852,2743.171,-0.000,179.999,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,492.409,-860.853,2743.171,-0.000,179.999,-0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,492.579,-860.885,2740.501,-0.000,-0.000,-89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "WHEELS", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(19981,492.449,-869.825,2743.171,-0.000,179.999,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19981,492.730,-869.824,2743.171,-0.000,179.999,179.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 9514, "711_sfw", "ws_carpark2", 0x00000000);
	tmpobjid = CreateDynamicObject(19483,492.560,-869.792,2740.501,-0.000,-0.000,89.999,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterialText(tmpobjid, 0, "WHEELS", 130, "Ariel", 30, 1, 0xFF000000, 0x00000000, 1);
	tmpobjid = CreateDynamicObject(2612,434.652,-864.578,2740.174,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 3, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(2257,438.674,-862.812,2740.053,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10101, "2notherbuildsfe", "ferry_build14", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 1, 14530, "estate2", "Auto_windsor", 0x00000000);
	tmpobjid = CreateDynamicObject(19359,432.916,-863.076,2739.846,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 19962, "samproadsigns", "materialtext1", 0x00000000);
	tmpobjid = CreateDynamicObject(2195,433.390,-864.198,2739.033,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 1, 19071, "wssections", "wood1", 0x00000000);
	SetDynamicObjectMaterial(tmpobjid, 2, 4830, "airport2", "kbplanter_plants1", 0x00000000);
	tmpobjid = CreateDynamicObject(19825,433.743,-860.196,2740.685,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, 1654, "dynamite", "clock64", 0xFFF0FFFF);
	tmpobjid = CreateDynamicObject(18075,438.553,-858.308,2741.726,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFFF0FFFF);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	tmpobjid = CreateDynamicObject(18981,427.910,-880.422,2736.976,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1569,416.445,-869.096,2734.695,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19917,418.995,-879.011,2737.965,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19872,417.965,-862.852,2733.911,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(927,426.875,-865.223,2736.285,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(927,426.815,-865.373,2736.155,180.000,630.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(16322,421.541,-879.056,2738.666,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19817,422.811,-864.940,2733.904,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1348,425.445,-860.598,2735.375,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1271,421.111,-874.775,2735.035,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1081,420.904,-874.041,2735.165,0.000,0.000,80.299,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1726,438.170,-871.049,2738.407,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1726,438.170,-868.689,2738.407,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1823,437.310,-870.213,2738.407,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1823,437.310,-872.594,2738.407,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,504.296,-865.863,2739.130,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,504.296,-867.003,2739.130,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,503.546,-866.873,2739.130,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,503.386,-864.673,2739.130,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,503.386,-863.483,2739.130,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,504.146,-864.093,2739.130,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,504.296,-865.863,2738.059,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,504.296,-867.003,2738.059,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,503.546,-866.873,2738.059,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,503.386,-864.673,2738.059,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,503.386,-863.483,2738.059,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(930,504.146,-864.093,2738.059,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1001,495.109,-869.533,2737.840,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1003,495.046,-869.514,2738.340,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1146,495.058,-869.479,2739.280,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1014,494.979,-869.564,2739.570,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1015,495.086,-869.562,2740.061,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1147,495.097,-869.535,2740.610,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1014,495.757,-869.535,2737.858,0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1015,495.651,-869.537,2738.350,0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1147,495.639,-869.564,2738.899,0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1001,495.667,-869.479,2739.131,0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1003,495.729,-869.497,2739.552,0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1146,495.717,-869.533,2740.591,0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1150,499.589,-868.586,2738.230,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1183,499.352,-868.652,2738.490,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1140,499.831,-868.523,2739.190,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1141,499.931,-868.511,2739.570,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1148,499.937,-870.625,2739.990,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1183,499.352,-868.652,2740.651,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1150,499.694,-870.527,2739.531,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1183,499.931,-870.461,2739.711,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1140,499.452,-870.591,2740.491,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1141,499.352,-870.602,2740.872,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1001,499.369,-860.953,2737.840,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1003,499.306,-860.934,2738.340,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1146,499.318,-860.899,2739.280,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1014,499.239,-860.984,2739.570,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1015,499.346,-860.982,2740.061,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1147,499.357,-860.955,2740.610,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1014,500.017,-860.955,2737.858,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1015,499.911,-860.957,2738.350,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1147,499.899,-860.984,2738.899,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1001,499.926,-860.899,2739.131,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1003,499.989,-860.918,2739.552,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1146,499.977,-860.953,2740.591,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1150,504.069,-860.056,2738.230,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1183,503.832,-860.121,2738.490,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1140,504.312,-859.992,2739.190,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1141,504.412,-859.981,2739.570,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1148,504.418,-862.094,2739.990,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1183,503.832,-860.121,2740.651,-0.000,0.000,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1150,504.174,-861.997,2739.531,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1183,504.412,-861.931,2739.711,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1140,503.932,-862.060,2740.491,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1141,503.832,-862.072,2740.872,0.000,0.000,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19848,492.601,-859.637,2738.238,0.000,14.500,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.205,-860.073,2738.841,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.455,-860.073,2738.841,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.705,-860.073,2738.841,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.955,-860.073,2738.841,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,494.059,-860.066,2738.842,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,493.809,-860.066,2738.842,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,493.559,-860.066,2738.842,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,493.309,-860.066,2738.842,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19848,492.668,-870.824,2738.238,-0.000,14.500,-89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,494.063,-870.388,2738.841,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,493.814,-870.388,2738.841,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,493.564,-870.388,2738.841,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,493.314,-870.388,2738.841,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.209,-870.395,2738.842,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.459,-870.395,2738.842,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.709,-870.395,2738.842,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.959,-870.395,2738.842,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19848,492.613,-859.629,2739.419,0.000,14.500,89.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.218,-860.065,2740.022,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.468,-860.065,2740.022,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.718,-860.065,2740.022,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,491.968,-860.065,2740.022,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,494.072,-860.057,2740.023,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,493.822,-860.057,2740.023,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,493.572,-860.057,2740.023,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,493.322,-860.057,2740.023,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(19848,492.677,-870.836,2739.419,0.000,14.500,-90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,494.072,-870.401,2740.022,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,493.822,-870.401,2740.022,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,493.572,-870.401,2740.022,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1075,493.322,-870.401,2740.022,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.218,-870.408,2740.023,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.468,-870.408,2740.023,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.718,-870.408,2740.023,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1085,491.968,-870.408,2740.023,0.000,-0.000,-0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,492.553,-865.783,2741.257,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,497.323,-865.783,2741.257,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,501.773,-865.783,2741.257,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,440.850,-867.502,2736.976,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,427.910,-857.362,2736.976,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,415.210,-867.502,2736.976,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,428.130,-867.502,2745.934,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,428.130,-867.502,2730.495,0.000,90.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(2009,433.482,-860.633,2738.413,0.000,0.000,270.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1715,433.205,-861.471,2738.413,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1726,436.528,-860.674,2738.413,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1721,435.329,-860.343,2738.413,0.000,0.000,180.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1808,435.964,-860.348,2738.413,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,418.666,-861.674,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,418.666,-864.914,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,418.666,-868.124,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,418.666,-871.344,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,418.666,-874.554,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,418.666,-877.765,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,422.126,-861.674,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,422.126,-864.914,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,422.126,-868.124,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,422.126,-871.344,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,422.126,-874.554,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,422.126,-877.765,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,425.636,-861.674,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,425.636,-864.914,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,425.636,-868.124,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,425.636,-871.344,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,425.636,-874.554,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,425.636,-877.765,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,429.066,-861.674,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,429.066,-864.914,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,429.066,-868.124,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,429.066,-871.344,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,429.066,-874.554,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,429.066,-877.765,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,489.128,-872.345,2744.603,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,513.758,-871.885,2744.603,0.000,0.000,0.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,434.357,-868.124,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,434.357,-871.344,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(1893,434.357,-874.554,2741.977,0.000,-0.000,179.999,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,502.128,-859.695,2744.603,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,502.128,-880.725,2744.603,0.000,0.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,502.128,-871.665,2744.603,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
	tmpobjid = CreateDynamicObject(18981,502.128,-871.665,2735.684,0.000,90.000,90.000,-1,-1,-1,300.000,300.000);
}

stock LoadTD()
{
    TuningTitleTD[0] = TextDrawCreate(14.666666, 103.703704, "LD_SPAC:white");
	TextDrawLetterSize(TuningTitleTD[0], 0.000000, 0.000000);
	TextDrawTextSize(TuningTitleTD[0], 99.000007, 29.451841);
	TextDrawAlignment(TuningTitleTD[0], 1);
	TextDrawColor(TuningTitleTD[0], 112);
	TextDrawSetShadow(TuningTitleTD[0], 0);
	TextDrawSetOutline(TuningTitleTD[0], 0);
	TextDrawFont(TuningTitleTD[0], 4);

	TuningTitleTD[1] = TextDrawCreate(64.666748, 109.096290, "TUNING");
	TextDrawLetterSize(TuningTitleTD[1], 0.276000, 1.782516);
	TextDrawAlignment(TuningTitleTD[1], 2);
	TextDrawColor(TuningTitleTD[1], -1);
	TextDrawSetShadow(TuningTitleTD[1], 0);
	TextDrawSetOutline(TuningTitleTD[1], 1);
	TextDrawBackgroundColor(TuningTitleTD[1], 51);
	TextDrawFont(TuningTitleTD[1], 2);
	TextDrawSetProportional(TuningTitleTD[1], 1);
}

stock LoadPlayerTD(playerid)
{
	TuningItemTD[playerid][0][0] = CreatePlayerTextDraw(playerid, 15.999990, 135.644439, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][0][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][0][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][0][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][0][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][0][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][0][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][0][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][0][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][0][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][0][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][0][0], 1);

	TuningItemTD[playerid][0][1] = CreatePlayerTextDraw(playerid, 112.000007, 135.644439, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][0][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][0][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][0][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][0][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][0][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][0][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][0][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][0][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][0][1], 1);

	TuningItemTD[playerid][1][0] = CreatePlayerTextDraw(playerid, 15.999995, 150.333297, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][1][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][1][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][1][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][1][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][1][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][1][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][1][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][1][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][1][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][1][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][1][0], 1);

	TuningItemTD[playerid][1][1] = CreatePlayerTextDraw(playerid, 112.000007, 150.333297, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][1][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][1][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][1][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][1][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][1][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][1][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][1][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][1][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][1][1], 1);

	TuningItemTD[playerid][2][0] = CreatePlayerTextDraw(playerid, 15.666662, 165.022247, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][2][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][2][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][2][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][2][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][2][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][2][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][2][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][2][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][2][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][2][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][2][0], 1);

	TuningItemTD[playerid][2][1] = CreatePlayerTextDraw(playerid, 112.000007, 165.022247, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][2][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][2][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][2][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][2][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][2][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][2][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][2][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][2][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][2][1], 1);

	TuningItemTD[playerid][3][0] = CreatePlayerTextDraw(playerid, 15.666662, 179.711120, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][3][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][3][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][3][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][3][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][3][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][3][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][3][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][3][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][3][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][3][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][3][0], 1);

	TuningItemTD[playerid][3][1] = CreatePlayerTextDraw(playerid, 112.000007, 179.711120, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][3][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][3][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][3][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][3][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][3][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][3][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][3][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][3][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][3][1], 1);

	TuningItemTD[playerid][4][0] = CreatePlayerTextDraw(playerid, 15.666662, 194.400009, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][4][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][4][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][4][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][4][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][4][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][4][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][4][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][4][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][4][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][4][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][4][0], 1);

	TuningItemTD[playerid][4][1] = CreatePlayerTextDraw(playerid, 112.000007, 194.400009, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][4][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][4][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid,TuningItemTD[playerid][4][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][4][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][4][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][4][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][4][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][4][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][4][1], 1);

	TuningItemTD[playerid][5][0] = CreatePlayerTextDraw(playerid, 15.666662, 209.088867, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][5][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][5][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][5][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][5][0], 255);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][5][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][5][0], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][5][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][5][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][5][0], 255);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][5][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][5][0], 1);

	TuningItemTD[playerid][5][1] = CreatePlayerTextDraw(playerid, 112.000007, 209.088867, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][5][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][5][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][5][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][5][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][5][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][5][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][5][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][5][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][5][1], 1);

	TuningItemTD[playerid][6][0] = CreatePlayerTextDraw(playerid, 15.666662, 223.777786, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][6][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][6][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][6][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][6][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][6][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][6][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][6][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][6][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][6][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][6][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][6][0], 1);

	TuningItemTD[playerid][6][1] = CreatePlayerTextDraw(playerid, 112.000007, 223.777786, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][6][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][6][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][6][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][6][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][6][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][6][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][6][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][6][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][6][1], 1);

	TuningItemTD[playerid][7][0] = CreatePlayerTextDraw(playerid, 15.666662, 238.466629, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][7][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][7][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][7][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][7][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][7][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][7][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][7][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][7][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][7][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][7][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][7][0], 1);

	TuningItemTD[playerid][7][1] = CreatePlayerTextDraw(playerid, 112.000007, 238.466629, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][7][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][7][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][7][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][7][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][7][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][7][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][7][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][7][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][7][1], 1);

	TuningItemTD[playerid][8][0] = CreatePlayerTextDraw(playerid, 15.666662, 253.155517, "Skin Name");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][8][0], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][8][0], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][8][0], 1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][8][0], -1);
	PlayerTextDrawUseBox(playerid, TuningItemTD[playerid][8][0], true);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][8][0], 117);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][8][0], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][8][0], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][8][0], 85);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][8][0], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][8][0], 1);

	TuningItemTD[playerid][8][1] = CreatePlayerTextDraw(playerid, 112.000007, 253.155517, "45$");
	PlayerTextDrawLetterSize(playerid, TuningItemTD[playerid][8][1], 0.194666, 1.147852);
	PlayerTextDrawTextSize(playerid, TuningItemTD[playerid][8][1], 112.333335, 18.251850);
	PlayerTextDrawAlignment(playerid, TuningItemTD[playerid][8][1], 3);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][8][1], -1);
	PlayerTextDrawSetShadow(playerid, TuningItemTD[playerid][8][1], 0);
	PlayerTextDrawSetOutline(playerid, TuningItemTD[playerid][8][1], 0);
	PlayerTextDrawBackgroundColor(playerid, TuningItemTD[playerid][8][1], 51);
	PlayerTextDrawFont(playerid, TuningItemTD[playerid][8][1], 1);
	PlayerTextDrawSetProportional(playerid, TuningItemTD[playerid][8][1], 1);
}

stock TuningMechanicCheckLevel(playerid)
{
	new level = uInfo[playerid][uTuningMechanicLevel];
	switch(level)
	{
		case 0: return 1;
		case 1..9:
		{
		    if(uInfo[playerid][uTuningMechanicOrders] >= TuningMechanicLevels[level][tuning_mechanic_orders_needed])
		    	return TuningMechanicRise(playerid);
		}
	}
	return 1;
}

stock TuningMechanicRise(playerid)
{
    uInfo[playerid][uTuningMechanicLevel]++;
    SetPlayerSkin(playerid, TuningMechanicLevels[uInfo[playerid][uTuningMechanicLevel]][tuning_mechanic_skin_id]);
    format:g_str_small("[TUNING]: Поздравляем! Вы повышены до {ffffff}%d {33aa33}уровня тюнинг-механика!", uInfo[playerid][uTuningMechanicLevel]);
    SendClientMessage(playerid, COLOR_GREEN, g_str_small);
    format:g_str_small("[TUNING]: Для следующего повышения нужно выполнить {ffffff}%d {33aa33}заказов!", TuningMechanicLevels[uInfo[playerid][uTuningMechanicLevel]][tuning_mechanic_orders_needed]);
    SendClientMessage(playerid, COLOR_GREEN, g_str_small);
	return 1;
}

stock PutPlayerInTuning(playerid)
{
	TogglePlayerControllable(playerid, 0);

	new veh = GetPlayerVehicleID(playerid);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetVehiclePos(veh, 426.1375,-873.5552,2735.5212);
	SetVehicleZAngle(veh, 55.8901);
	
	/*for(new i; i<MAX_TUNING_CATEGORIES; i++)
	{
	    for(new e; e<sizeof(TuningElements); e++)
	    {
			if(TuningElements[e][tuning_element_categorie_id] == i)
			{
			    if(e == VehicleInfo[veh][vehicle_tuning_elements][i])
			    {
			        TempInfo[playerid][temp_selected_tuning_elements][i] = e;
			    }
			}
	    }
	}*/
	
	for(new i; i<MAX_TUNING_CATEGORIES; i++)
	{
        TempInfo[playerid][temp_selected_tuning_elements][i] = VehicleInfo[veh][vehicle_tuning_elements][i];
	}
	
	LinkVehicleToInterior(veh, GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(veh, GetPlayerVirtualWorld(playerid));
	
	InterpolateCameraPosEx(playerid, 429.172729, -868.448425, 2735.440429, 417.032958, -872.375427, 2737.866943, 5000);
	InterpolateCameraLookAtEx(playerid, 428.260467, -873.364440, 2735.414550, 421.777221, -872.895935, 2736.376708, 5000);
	
    ShowTuningCategories(playerid);
	
	SetPVarInt(playerid, "Tuning:Active", 1);
	
	return 1;
}

stock ShowFirstCategorie(playerid)
{
    TempInfo[playerid][temp_selected_td_item] = 0;
    SelectItemInTuningTD(playerid, TempInfo[playerid][temp_selected_td_item]);
    return 1;
}

stock ShowNextCategorie(playerid)
{

    /*if(!FindNextCategorie(playerid))
		TempInfo[playerid][temp_selected_td_item] = 0;
	else
	*/
 	TempInfo[playerid][temp_selected_td_item]++;

    UpdateCategoriesList(playerid);
}

stock ShowPreviousCategorie(playerid)
{
    TempInfo[playerid][temp_selected_td_item]--;

	/*if(TempInfo[playerid][temp_selected_td_item] < 0)
    {
	    if(!FindPreviousCategorie(playerid))
			TempInfo[playerid][temp_selected_td_item] = TempInfo[playerid][temp_selected_items_array_size]-1;
	}*/

    UpdateCategoriesList(playerid);
}
stock UpdateCategoriesList(playerid)
{
	new array_size;
	if(TempInfo[playerid][temp_selected_items_array_size] < 9)
	{
	    array_size = TempInfo[playerid][temp_selected_items_array_size];
	}
	else
	{
	    array_size = 9;
	}

	if(TempInfo[playerid][temp_selected_td_item] >= array_size)
	{
		TempInfo[playerid][temp_selected_td_item] = array_size-1;
		new next_categorie = FindNextCategorie(playerid);
	    if(next_categorie != -1)
		{
	    	for(new i; i<array_size; i++)
			{
			    if(i+1 < array_size)
                	TempInfo[playerid][temp_selected_categories][i] = TempInfo[playerid][temp_selected_categories][i+1];
				else
				    TempInfo[playerid][temp_selected_categories][i] = next_categorie;
                PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningCategories[TempInfo[playerid][temp_selected_categories][i]][tuning_categorie_name]);
			}
		}
		else
		{
		    ShowTuningCategories(playerid);
  		}
	}
	else if(TempInfo[playerid][temp_selected_td_item] < 0)
	{
	    if(TempInfo[playerid][temp_selected_items_array_size] < 9)
	    {
	        TempInfo[playerid][temp_selected_td_item] = TempInfo[playerid][temp_selected_items_array_size]-1;
	        SelectItemInTuningTD(playerid, TempInfo[playerid][temp_selected_td_item]);
	    }
	    else
	    {
			TempInfo[playerid][temp_selected_td_item] = 0;
		    new previous_categorie = FindPreviousCategorie(playerid);
		    if(previous_categorie != -1)
			{
			    for(new i=array_size-1; i>=0; i--)
				{
				    if(i-1 >= 0)
	                	TempInfo[playerid][temp_selected_categories][i] = TempInfo[playerid][temp_selected_categories][i-1];
					else
					    TempInfo[playerid][temp_selected_categories][i] = previous_categorie;

                    PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningCategories[TempInfo[playerid][temp_selected_categories][i]][tuning_categorie_name]);
				}
			}
			else
			{
				new td = 8;
			    for(new i = sizeof(TuningElements)-1; i >= 0; i--) if(td >= 0)
			    {
           			if(IsCategorieAvaible(GetPlayerVehicleID(playerid), i))
			        {
                        TempInfo[playerid][temp_selected_categories][td] = i;
                        PlayerTextDrawSetString(playerid, TuningItemTD[playerid][td][0], TuningCategories[i][tuning_categorie_name]);

                        td--;
			        }
			    }
			    TempInfo[playerid][temp_selected_td_item] = 8;
			    //ShowTuningElements(playerid, categorie);
			}
		}
	}
	return SelectItemInTuningTD(playerid, TempInfo[playerid][temp_selected_td_item]);
}

stock ClearTuningOrderData()
{
	TuningCustomerInfo[tuning_customer_id] = -1;
	TuningCustomerInfo[tuning_vehicle_id] = 0;
	for(new i; i<MAX_TUNING_ORDERS; i++)
	{
		TuningOrders[i][tuning_order_active] = 0;
		TuningOrders[i][tuning_order_mechanic_id] = -1;
		TuningOrders[i][tuning_order_component_id] = 0;
		TuningOrders[i][tuning_order_activity_timer] = 0;
		TuningOrders[i][tuning_order_install_progress] = 0;
		TuningOrders[i][tuning_order_done] = 0;
	}
	return 1;
}

/*stock UpdateCategoriesList(playerid, itemid)
{
	if(itemid > TempInfo[playerid][temp_selected_items_array_size])
	{
		itemid = TempInfo[playerid][temp_selected_items_array_size];
		TempInfo[playerid][temp_selected_td_item] = TempInfo[playerid][temp_selected_items_array_size];
		new next_categorie = FindNextCategorie(playerid);
	    if(next_categorie)
		{
	    	for(new i; i<TempInfo[playerid][temp_selected_items_array_size]; i++)
			{
			    if(i+1 < TempInfo[playerid][temp_selected_items_array_size])
                	TempInfo[playerid][temp_selected_categories][i] = TempInfo[playerid][temp_selected_categories][i+1];
				else
				    TempInfo[playerid][temp_selected_categories][i] = next_categorie;
				    
				PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningCategories[i][tuning_categorie_name]);
			}
		}
		else
		{
		    ShowTuningCategories(playerid);
  		}
	}
	else if(itemid < 0)
	{
		itemid = 0;
		TempInfo[playerid][temp_selected_td_item] = 0;
	    new previous_categorie = FindPreviousCategorie(playerid);
	    if(previous_categorie)
		{
		    for(new i; i<TempInfo[playerid][temp_selected_items_array_size]; i++)
			{
			    if(i-1 > 0)
                	TempInfo[playerid][temp_selected_categories][i] = TempInfo[playerid][temp_selected_categories][i-1];
				else
				    TempInfo[playerid][temp_selected_categories][i] = previous_categorie;

				PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningCategories[i][tuning_categorie_name]);
			}
		}
		else
		{
		    ShowTuningCategories(playerid);
		}
	}
	return SelectItemInTuningTD(playerid, itemid);
}*/
stock ShowNextElement(playerid)
{
    /*if(!FindNextElement(playerid))
		TempInfo[playerid][temp_selected_td_item] = 0;
	else*/
	/*InterpolateCameraPos(playerid, 429.172729, -868.448425, 2735.440429, 417.032958, -872.375427, 2737.866943, 5000);
	InterpolateCameraLookAt(playerid, 428.260467, -873.364440, 2735.414550, 421.777221, -872.895935, 2736.376708, 5000);*/
	
 	TempInfo[playerid][temp_selected_td_item]++;

    UpdateElementsList(playerid);
}

stock ShowPreviousElement(playerid)
{
    TempInfo[playerid][temp_selected_td_item]--;

	/*if(TempInfo[playerid][temp_selected_td_item] < 0)
    {
	    if(!FindPreviousElement(playerid))
			TempInfo[playerid][temp_selected_td_item] = TempInfo[playerid][temp_selected_items_array_size]-1;
	}*/

    UpdateElementsList(playerid);
}
stock UpdateElementsList(playerid)
{
	new categorie = TempInfo[playerid][temp_selected_categorie];
	new array_size;
	if(TempInfo[playerid][temp_selected_items_array_size] < 9)
	{
	    array_size = TempInfo[playerid][temp_selected_items_array_size];
	}
	else
	{
	    array_size = 9;
	}
	
	if(TempInfo[playerid][temp_selected_td_item] >= array_size)
	{
		TempInfo[playerid][temp_selected_td_item] = array_size-1;
		new next_element = FindNextElement(playerid);
	    if(next_element)
		{
	    	for(new i; i<array_size; i++)
			{
			    if(i+1 < array_size)
                	TempInfo[playerid][temp_selected_categories][i] = TempInfo[playerid][temp_selected_categories][i+1];
				else
				    TempInfo[playerid][temp_selected_categories][i] = next_element;
				PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningElements[TempInfo[playerid][temp_selected_categories][i]][tuning_element_name]);

				
				if(TempInfo[playerid][temp_selected_tuning_elements][categorie] == TempInfo[playerid][temp_selected_categories][i])
					g_str_least = "X";
				else
					format:g_str_least("%d$", TuningElements[TempInfo[playerid][temp_selected_categories][i]][tuning_element_price]);
					
				PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][1], g_str_least);
			}
		}
		else
		{
		    ShowTuningElements(playerid, categorie);
  		}
	}
	else if(TempInfo[playerid][temp_selected_td_item] < 0)
	{
	    if(TempInfo[playerid][temp_selected_items_array_size] < 9)
	    {
	        TempInfo[playerid][temp_selected_td_item] = TempInfo[playerid][temp_selected_items_array_size]-1;
	        SelectItemInTuningTD(playerid, TempInfo[playerid][temp_selected_td_item]);
	    }
	    else
	    {
			TempInfo[playerid][temp_selected_td_item] = 0;
		    new previous_element = FindPreviousElement(playerid);
		    if(previous_element)
			{
			    for(new i=array_size-1; i>=0; i--)
				{
				    if(i-1 >= 0)
	                	TempInfo[playerid][temp_selected_categories][i] = TempInfo[playerid][temp_selected_categories][i-1];
					else
					    TempInfo[playerid][temp_selected_categories][i] = previous_element;

					PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningElements[TempInfo[playerid][temp_selected_categories][i]][tuning_element_name]);
					
					if(TempInfo[playerid][temp_selected_tuning_elements][categorie] == TempInfo[playerid][temp_selected_categories][i])
						g_str_least = "X";
					else
						format:g_str_least("%d$", TuningElements[TempInfo[playerid][temp_selected_categories][i]][tuning_element_price]);

					PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][1], g_str_least);
				}
			}
			else
			{
				new td = 8;
			    for(new i = sizeof(TuningElements)-1; i >= 0; i--) if(td >= 0)
			    {
			        if(TuningElements[i][tuning_element_categorie_id] == categorie)
			        {
	               		if(IsTuningElementCompatible(GetPlayerVehicleID(playerid), i))
       					{
                            TempInfo[playerid][temp_selected_categories][td] = i;
                            
                            PlayerTextDrawSetString(playerid, TuningItemTD[playerid][td][0], TuningElements[i][tuning_element_name]);
                            
							if(TempInfo[playerid][temp_selected_tuning_elements][categorie] == TempInfo[playerid][temp_selected_categories][td])
								g_str_least = "X";
							else
								format:g_str_least("%d$", TuningElements[i][tuning_element_price]);
								
							PlayerTextDrawSetString(playerid, TuningItemTD[playerid][td][1], g_str_least);
							
                            td--;
			            }
			        }
			    }
			    TempInfo[playerid][temp_selected_td_item] = 8;
			    //ShowTuningElements(playerid, categorie);
			}
		}
	}
	return SelectItemInTuningTD(playerid, TempInfo[playerid][temp_selected_td_item]);
}

stock IsTuningElementCompatible(vehicleid, elementid)
{
	new categorie = TuningElements[elementid][tuning_element_categorie_id];
    if(IsAUniversalTuningElement(elementid) || !TuningElements[elementid][tuning_element_id])
    {
        return 1;
    }
    else
    {
        if(categorie == TUNING_CATEGORIE_PAINTJOB)
        {
            if(IsVehiclePaintJobCompatible(GetVehicleModel(vehicleid), TuningElements[elementid][tuning_element_id]))
            {
                return 1;
            }
        }
        else
        {
            if(categorie == TUNING_CATEGORIE_SPOILER)
	        {
	            switch(GetVehicleModel(vehicleid))
	            {
	                case 411: return 1;
	                case 541: return 1;
	            }
	        }
	        else if(categorie == TUNING_CATEGORIE_NEON)
	        {
	            switch(GetVehicleModel(vehicleid))
	            {
	                case 411: return 1;
	                case 541: return 1;
	                case 560: return 1;
	            }
	        }
	        else if(categorie == TUNING_CATEGORIE_STYLING)
	        {
	            switch(GetVehicleModel(vehicleid))
	            {
	                case 411: return 1;
	                case 541: return 1;
	                case 560: return 1;
	            }
	        }
	        
            if(IsVehicleUpgradeCompatible(GetVehicleModel(vehicleid), TuningElements[elementid][tuning_element_id]))
            {
                return 1;
            }
		}
	}
	return 0;
}

stock SelectItemInTuningTD(playerid, itemid) //тут происходит выбор, какой из 9 текстдравов должен загораться белым. Подсчет нужного текстдрава происходит в стоке сверху
{
	for(new i; i<TempInfo[playerid][temp_selected_items_array_size]; i++) if(i < 9)
	{
		PlayerTextDrawColor(playerid, TuningItemTD[playerid][i][0], -1);
		PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][i][0], 117);
		PlayerTextDrawColor(playerid, TuningItemTD[playerid][i][1], -1);
		PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][i][1], 117);
	}
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][itemid][0], 255);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][itemid][0], -1);
	PlayerTextDrawColor(playerid, TuningItemTD[playerid][itemid][1], 255);
	PlayerTextDrawBoxColor(playerid, TuningItemTD[playerid][itemid][1], -1);
	for(new i; i<TempInfo[playerid][temp_selected_items_array_size]; i++)
	{
	    PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][0]);
	    if(GetPVarInt(playerid, "Tuning:Active") == 2)
	    	PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][1]);
	}
	return 1;
}
stock ShowTuningElements(playerid, categorieID) //просто показывает текстдравы игроку
{
	HideTuning(playerid);
	TextDrawShowForPlayer(playerid, TuningTitleTD[0]);
	TextDrawShowForPlayer(playerid, TuningTitleTD[1]);

	TempInfo[playerid][temp_selected_items_array_size] = 0;
	TempInfo[playerid][temp_selected_categorie] = categorieID;

	new c;
	for(new i; i<9; i++) if(i<sizeof(TuningElements))
	{
	    while(c+1 < sizeof(TuningElements))
	    {
	    	c++;
	        if(TuningElements[c][tuning_element_categorie_id] == categorieID)
			{
			    if(IsTuningElementCompatible(GetPlayerVehicleID(playerid), c))
	            {
	                TempInfo[playerid][temp_selected_items_array_size]++;
			        TempInfo[playerid][temp_selected_categories][i] = c;

					PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][0]);
				    PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningElements[c][tuning_element_name]);

				    PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][1]);
				    
				    if(TempInfo[playerid][temp_selected_tuning_elements][categorieID] == c)
						g_str_least = "X";
					else
						format:g_str_least("%d$", TuningElements[c][tuning_element_price]);
				    
				    PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][1], g_str_least);

				    break;
	            }
			}
    	}
	}

	ShowFirstCategorie(playerid);

	return 1;
}
/*stock ShowTuningItems(playerid, categorieID)
{
	HideTuning(playerid);
	TextDrawShowForPlayer(playerid, TuningTitleTD[0]);
	TextDrawShowForPlayer(playerid, TuningTitleTD[1]);

	TempInfo[playerid][temp_selected_items_array_size] = 0;

    for(new i; i<sizeof(TuningElements); i++)
	{
		if(TuningElements[i][tuning_element_categorie_id] == categorieID)
		{
		    if(IsVehicleUpgradeCompatible(GetVehicleModel(GetPlayerVehicleID(playerid)), TuningElements[i][tuning_element_id]))
		    {
                TempInfo[playerid][temp_selected_items_array_size]++;
		    }
	    }
  	}
	for(new i; i<9; i++) if(i<TempInfo[playerid][temp_selected_items_array_size])
	{
	    for(new e; e<sizeof(TuningElements); e++)
		{
			if(TuningElements[e][tuning_element_categorie_id] == categorieID)
			{
			    if(IsVehicleUpgradeCompatible(GetVehicleModel(GetPlayerVehicleID(playerid)), TuningElements[e][tuning_element_id]))
			    {
					PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][0]);
				    PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningElements[i][tuning_element_name]);
				    
				    PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][1]);
				    
				    format:g_str_least("%d$", TuningElements[i][tuning_element_price]);
				    PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][1], g_str_least);
				}
			}
		}
	}
	return 1;
}*/
stock ShowTuningCategories(playerid) //просто показывает текстдравы игроку
{
	HideTuning(playerid);
	TextDrawShowForPlayer(playerid, TuningTitleTD[0]);
	TextDrawShowForPlayer(playerid, TuningTitleTD[1]);
	
	TempInfo[playerid][temp_selected_items_array_size] = 0;
	
	new c;
	for(new i; i<9; i++) if(i<sizeof(TuningCategories))
	{
	    //for(c; c<sizeof(TuningCategories); c++)
	    while(c < sizeof(TuningCategories))
	    {
		    if(IsCategorieAvaible(GetPlayerVehicleID(playerid), c))
		    {
		        TempInfo[playerid][temp_selected_items_array_size]++;
		        TempInfo[playerid][temp_selected_categories][i] = c;
		        PlayerTextDrawShow(playerid, TuningItemTD[playerid][i][0]);
				PlayerTextDrawSetString(playerid, TuningItemTD[playerid][i][0], TuningCategories[c][tuning_categorie_name]);
				c++;
		        break;
		  	}
		  	c++;
    	}
	}
	
	ShowFirstCategorie(playerid);
	
	return 1;
}
stock HideTuning(playerid) //скрывает текстдравы от игрока
{
	TextDrawHideForPlayer(playerid, TuningTitleTD[0]);
	TextDrawHideForPlayer(playerid, TuningTitleTD[1]);
	for(new i; i<9; i++)
	{
	    PlayerTextDrawHide(playerid, TuningItemTD[playerid][i][0]);
	    PlayerTextDrawHide(playerid, TuningItemTD[playerid][i][1]);
    }
}
stock IsCategorieAvaible(vehicleid, categorieid)
{
    for(new e; e<sizeof(TuningElements); e++)
	{
	    if(!TuningElements[e][tuning_element_id]) continue;
		if(TuningElements[e][tuning_element_categorie_id] == categorieid)
		{
		    if(IsTuningElementCompatible(vehicleid, e))
            {
                return 1;
            }
	    }
  	}
  	return 0;
}
stock FindNextCategorie(playerid)
{
	new
	    selected_item = TempInfo[playerid][temp_selected_td_item],
		vehicleid = GetPlayerVehicleID(playerid),
		current_max_categorie_id = TempInfo[playerid][temp_selected_categories][selected_item]+1;
		
	while(current_max_categorie_id < sizeof TuningCategories)
	{
		if(IsCategorieAvaible(vehicleid, current_max_categorie_id))
		{
  			return current_max_categorie_id;
	    }
	    current_max_categorie_id++;
  	}
  	return -1;
}
stock FindPreviousCategorie(playerid)
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		current_max_categorie_id = TempInfo[playerid][temp_selected_categories][0]-1;

	while(current_max_categorie_id > 0)
	{
		if(IsCategorieAvaible(vehicleid, current_max_categorie_id))
		{
  			return current_max_categorie_id;
	    }
	    current_max_categorie_id--;
  	}
  	return -1;
}
stock FindNextElement(playerid)
{
	new
	    selected_item = TempInfo[playerid][temp_selected_td_item],
		vehicleid = GetPlayerVehicleID(playerid),
		current_max_element_id = TempInfo[playerid][temp_selected_categories][selected_item]+1,
		categorieid =  TempInfo[playerid][temp_selected_categorie];

	while(current_max_element_id < sizeof TuningElements)
	{
		if(TuningElements[current_max_element_id][tuning_element_categorie_id] == categorieid)
		{
		    if(IsTuningElementCompatible(vehicleid, current_max_element_id))
		    {
                return current_max_element_id;
            }
	    }
	    current_max_element_id++;
  	}
  	return 0;
}
stock FindPreviousElement(playerid)
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		current_min_element_id = TempInfo[playerid][temp_selected_categories][0]-1,
		categorieid =  TempInfo[playerid][temp_selected_categorie];

	while(current_min_element_id > 0)
	{
		if(TuningElements[current_min_element_id][tuning_element_categorie_id] == categorieid)
		{
            if(IsTuningElementCompatible(vehicleid, current_min_element_id))
            {
                return current_min_element_id;
            }
	    }
	    current_min_element_id--;
  	}
  	return 0;
}
stock IsAUniversalTuningElement(i)
{
	if(TuningElements[i][tuning_element_categorie_id] == TUNING_CATEGORIE_TIRES
 	|| TuningElements[i][tuning_element_categorie_id] == TUNING_CATEGORIE_COLOR)
 	//|| (TuningElements[i][tuning_element_categorie_id] != -1 && !TuningElements[i][tuning_element_id]))
	{
	    return 1;
	}
	return 0;
}

stock TuningReCamera(playerid)
{
	/*new
	    Float:cPos[3],
	    Float:cRot[3];
	    
	GetPlayerCameraPos(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2]);
	GetPlayerCameraFrontVector(playerid, cRot[0], cRot[1], cRot[2]);*/

	switch(TempInfo[playerid][temp_selected_categorie])
	{
	    case 0, 1:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 419.710418, -873.138916, 2737.557617, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 424.327606, -873.335510, 2735.648925, 2000);
		}
	    case 2:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 426.241210, -867.547058, 2736.122802, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 426.293182, -872.440185, 2735.095947, 2000);
		}
		case 3:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 430.583282, -878.382873, 2738.104492, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 428.107574, -874.835021, 2735.597900, 2000);
		}
		case 4:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 420.249267, -866.355834, 2737.202392, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 423.075866, -870.347534, 2736.164794, 2000);
		}
		case 5:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 431.326568, -879.276672, 2737.217773, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 428.595153, -875.422241, 2735.579833, 2000);
		}
		case 6:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 427.989898, -879.514404, 2737.267333, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 427.776763, -874.724792, 2735.848144, 2000);
		}
		case 7:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 418.459442, -868.069702, 2736.612792, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 422.442626, -871.056030, 2736.147949, 2000);
		}
		case 8:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 424.389770, -864.621459, 2740.181640, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 425.347747, -869.068847, 2738.107421, 2000);
		}
		case 9:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 423.852661, -864.282836, 2740.422363, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 424.197143, -868.589843, 2737.906250, 2000);
		}
		case 10:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2],  422.210784, -865.305358, 2740.131591, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 424.045806, -869.414855, 2737.953369, 2000);
		}
		case 11:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 430.849334, -879.320678, 2735.070312, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 428.261505, -875.062561, 2735.484863, 2000);
		}
		case 12:
	    {
		    InterpolateCameraPosEx(playerid, GetInterpolateCameraPos[playerid][0], GetInterpolateCameraPos[playerid][1], GetInterpolateCameraPos[playerid][2], 420.033416, -878.565368, 2738.263427, 2000);
			InterpolateCameraLookAtEx(playerid, GetInterpolateCameraLookAt[playerid][0], GetInterpolateCameraLookAt[playerid][1], GetInterpolateCameraLookAt[playerid][2], 423.762207, -875.787170, 2736.425537, 2000);
		}
	}
	return 1;
}

stock CreateVehicleEx(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay, addsiren=0)
{
	new veh = CreateVehicle(vehicletype, x, y, z, rotation, color1, color2, respawn_delay, addsiren);
	
	for(new i; i<MAX_TUNING_CATEGORIES; i++)
	{
	    for(new e; e<sizeof(TuningElements); e++)
	    {
			if(TuningElements[e][tuning_element_categorie_id] == i)
			{
		        if(i == TUNING_CATEGORIE_COLOR)
			    {
			        if(TuningElements[e][tuning_element_id] == color1)
			        {
			            VehicleInfo[veh][vehicle_tuning_elements][TUNING_CATEGORIE_COLOR] = e;
			        }
			    }
			    else
			    {
			        if(TuningElements[e][tuning_element_id] == 0)
			        {
			            VehicleInfo[veh][vehicle_tuning_elements][i] = e;
			        }
		        }
			}
	    }
	}
	
	return 1;
}

stock InterpolateCameraPosEx(playerid, Float:X, Float:Y, Float:Z, Float:VX, Float:VY, Float:VZ, ms)
{
    InterpolateCameraPos(playerid, X, Y, Z, VX, VY, VZ, ms);
    GetInterpolateCameraPos[playerid][0] = VX;
    GetInterpolateCameraPos[playerid][1] = VY;
    GetInterpolateCameraPos[playerid][2] = VZ;
	//InterpolateCameraLookAt(playerid, 428.260467, -873.364440, 2735.414550, 421.777221, -872.895935, 2736.376708, 5000);
}

stock InterpolateCameraLookAtEx(playerid, Float:X, Float:Y, Float:Z, Float:VX, Float:VY, Float:VZ, ms)
{
    InterpolateCameraLookAt(playerid, X, Y, Z, VX, VY, VZ, ms);
    GetInterpolateCameraLookAt[playerid][0] = VX;
    GetInterpolateCameraLookAt[playerid][1] = VY;
    GetInterpolateCameraLookAt[playerid][2] = VZ;
}

CMD:tunetp(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 426.1375,-873.5552,2735.5212);
	SetPlayerFacingAngle(playerid, 55.8901);
	return 1;
}

CMD:tune(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return 1;
	TogglePlayerControllable(playerid, 0);
	PutPlayerInTuning(playerid);
	return 1;
}
CMD:list(playerid)
{
	g_str_big = "Название\tЗаказчик\n";
	for(new i; i<MAX_TUNING_ORDERS; i++)
    {
        if(!TuningOrders[i][tuning_order_active]) continue;

		new
			element_id = TuningOrders[i][tuning_order_component_id],
			customer_id = TuningCustomerInfo[tuning_customer_id];
        format(g_str_big, sizeof(g_str_big), "%s%s\t%s\n", g_str_big, TuningElements[element_id][tuning_element_name], uInfo[customer_id][uName]);
    }
    ShowPlayerDialog(playerid, dEmpty, DIALOG_STYLE_TABLIST_HEADERS, "Тюнинг", g_str_big, "Выбрать", "");
}
//============================================DEBUG=========================
CMD:setskin(playerid, params[])
{
	if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, COLOR_RED, "/setskin [ID] [Skin]");
	if(IsPlayerConnected(params[0]))
		SetPlayerSkin(params[0], params[1]);
	return 1;
}

CMD:pj(playerid, params[])
{
	if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_RED, "/pj [ID]");
	ChangeVehiclePaintjobEx(GetPlayerVehicleID(playerid), params[0]);
	return 1;
}

CMD:money(playerid, params[])
{
	if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, COLOR_RED, "/money [ID] [Cash]");
	GiveMoney(params[0], params[1]);
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
        new vehid = CreateVehicleEx(params[0],pX+2,pY,pZ,0.0,params[1],params[2],0,0);
        LinkVehicleToInterior(vehid, GetPlayerInterior(playerid));
        SetVehicleVirtualWorld(vehid, GetPlayerVirtualWorld(playerid));
        PutPlayerInVehicle(playerid, vehid, 0);
        format(string,sizeof(string),"{696969}[!] {1E90FF}Вы создали автомобиль №%d",params[0]);
        SendClientMessage(playerid,-1,string);
    }
    return 1;
}
CMD:carry(playerid)
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	return 1;
}
CMD:orders(playerid)
{
    for(new o; o<MAX_TUNING_ORDERS; o++)
    {
        if(!TuningOrders[o][tuning_order_active]) continue;
        if(TuningOrders[o][tuning_order_done]) continue;
        //printf("%d", o);
    }
    return 1;
}
CMD:restart(playerid)
{
	SendRconCommand("gmx");
}
CMD:tp(playerid)
{
	SetPlayerPos(playerid, 502.128,-871.665,2735.684);
	return 1;
}
