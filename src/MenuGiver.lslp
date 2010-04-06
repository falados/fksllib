// Menu Giver Script
// Author: Falados Kapuskas

// --- SETTINGS --- //
integer ACCESS_LEVEL = 2; // 0 = Anyone, 1 = Group Only, 2 = Owner Only
integer GIVE_SELF = FALSE; // Giver will be able to give itself away
string SELECT_CATEGORY_MESSAGE = "Please select a category";
string SELECT_ITEM_MESSAGE = "Please select an item";
string NEXT_PAGE = ">>";
string PREV_PAGE = "<<";
string NO_BUTTON = "--";
// --- END SETTINGS --- //

// --- GLOBALS --- //
integer gASKMODE;
integer gLISTENHDL;
integer gCATEGORY;
integer gCATOFFSET;
integer gNUMCATEGORY;
integer gCATMAX;
list gCATEGORYS;
list gBUTTONS;
// --- END GLOBALS --- //

integer HasAccess(key agent){
    return (((ACCESS_LEVEL - llSameGroup(agent)) - (2 * (llGetOwner() == agent))) <= 0);
}

LoadCategories()
{
	gCATEGORYS= [
		"Textures",INVENTORY_TEXTURE,
		"Sounds",INVENTORY_SOUND,
		"Scripts",INVENTORY_SCRIPT,
		"Objects",INVENTORY_OBJECT,
		"Notecards",INVENTORY_NOTECARD,
		"Gesture",INVENTORY_GESTURE,
		"Clothing",INVENTORY_CLOTHING,
		"Bodypart",INVENTORY_BODYPART,
		"Animation",INVENTORY_ANIMATION
	];
	gNUMCATEGORY = llGetListLength(gCATEGORYS)/2;
	integer i = 0;
	integer num;
	integer cat;
	for( i = 0; i < llGetListLength(gCATEGORYS); i += 2)
	{
		cat = llList2Integer(gCATEGORYS,i+1);
		num = llGetInventoryNumber(cat);
		if( num <= 0 || (
			!GIVE_SELF && (cat == INVENTORY_ALL || cat == INVENTORY_SCRIPT ) && num == 1	
		) )
		{
				//Cull Empty Category
				gCATEGORYS = llDeleteSubList(gCATEGORYS,i,i+1);
				i-=2;
				--gNUMCATEGORY;
		}
	}
}

SetupSelection(integer category)
{
	gCATEGORY = category;
	gCATOFFSET = 0;
	gCATMAX = llGetInventoryNumber(gCATEGORY);
}

ShowCategory(key target)
{
	if( gNUMCATEGORY > 1 )
	{
		gASKMODE = 0;
		llListenRemove(gLISTENHDL);
		integer channel = llFloor( llFrand(1e6) + 1e6 );
		gLISTENHDL = llListen(channel,"",target,"");
		llDialog(target, SELECT_CATEGORY_MESSAGE, llList2ListStrided(gCATEGORYS,0,-1,2), channel);
	} else {
		gCATEGORY = INVENTORY_ALL;
		SetupSelection(gCATEGORY);
		ShowSelection(target);
	}
}

ShowSelection(key target)
{
	if( gCATMAX == 0 ) return;
	integer i = gCATOFFSET;
	integer end = gCATMAX;
	string name;
	if( end > i + 9 ) end = i + 9;
	gBUTTONS = [];
	for( i = gCATOFFSET; i < end; ++i)
	{
		name = llGetInventoryName(gCATEGORY, i);
		if( gCATEGORY == INVENTORY_ALL || gCATEGORY == INVENTORY_SCRIPT )
		{
			if( !GIVE_SELF )
			{
				if( name != llGetScriptName() ) gBUTTONS += [llGetSubString(name,0,12),name];
			}
		} else {
			gBUTTONS += [llGetSubString(name,0,12),name];
		}	
	}
	if( gBUTTONS == [] ) return;
	list bottom = [];
	if( gCATOFFSET > 0  ) { bottom += [PREV_PAGE]; } else { bottom += [NO_BUTTON]; }
	bottom += [NO_BUTTON];
	if( gCATMAX > end  ) { bottom += [NEXT_PAGE]; } else { bottom += [NO_BUTTON]; }
	gASKMODE = 1;
	llListenRemove(gLISTENHDL);
	integer channel = llFloor( llFrand(1e6) + 1e6 );
	gLISTENHDL = llListen(channel,"",target,"");
	llDialog(target, SELECT_ITEM_MESSAGE, bottom + llList2ListStrided(gBUTTONS,0,-1,2), channel);
}

ProcessResponse(key target,string message)
{
	llListenRemove(gLISTENHDL);
	integer i;
	if( gASKMODE == 0 )
	{
		i = llListFindList(gCATEGORYS,[message]);
		if( i != -1 )
		{
			SetupSelection(llList2Integer(gCATEGORYS,i+1));
			ShowSelection(target);
			return;
		}
	}
	if( gASKMODE == 1 )
	{
		if( message == NEXT_PAGE )
		{
			gCATOFFSET += 9;
		} else
		if( message == PREV_PAGE )
		{
			gCATOFFSET -= 9;
		} else {
			i = llListFindList(gBUTTONS,[message]);
			if( i != -1 )
			{
				llGiveInventory(target, llList2String(gBUTTONS,i+1) );
			}
			return;
		}
		if( gCATOFFSET >= gCATMAX ) gCATOFFSET = gCATMAX - 9;
		if( gCATOFFSET < 0 ) gCATOFFSET = 0;
		ShowSelection(target);
	}
}

default
{
	state_entry()
	{
		LoadCategories();
	}
	changed(integer change)
	{
		if( change & (CHANGED_INVENTORY | CHANGED_ALLOWED_DROP) ) LoadCategories();
	}
	touch_start(integer num)
	{
		if( HasAccess( llDetectedKey(0)) )
		{
			ShowCategory( llDetectedKey(0) );
		}
	}
	
	listen(integer channel, string name, key id, string message) {
		ProcessResponse(id,message);
	}
	
}
