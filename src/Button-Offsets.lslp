//--------------------------------------------------------\\
//					Configuration						  ||
//--------------------------------------------------------//
// -- Button Texture -- //
key TEXTURE = "bdb38e9e-9e05-973a-205c-9dca34c8f03a";

// -- Size of the image (in pixels) -- //
vector IMAGE_SIZE = <1024,1024,0>;

// -- Button Sets -- //
list BUTTON_SET = [
	// -- Set Format -- //
	//offset (px), size (px), grid size (integer)
	
	//Set - Cut Numbers
	<0,0,0>,<341.333333333333,341.333333333333,0>,<3,3,0>
	
];

// -- If true, buttons are read down then across -- //
// -- If false, buttons are read across then down -- //
integer TRANSPOSE = TRUE;

//--------------------------------------------------------\\
//--------------------------------------------------------//

list get_offset(integer set, integer row, integer col)
{
	vector MAIN_OFFSET;
	vector OFFSET;
	vector BUTTON_SIZE;
	
    vector tex_offset = llList2Vector(BUTTON_SET,set*3+0);
    tex_offset.x /= IMAGE_SIZE.x;
    tex_offset.y /= IMAGE_SIZE.y;
    BUTTON_SIZE = llList2Vector(BUTTON_SET,set*3+1);
    BUTTON_SIZE.x /= IMAGE_SIZE.x;
    BUTTON_SIZE.y /= IMAGE_SIZE.y;
    vector set_grid = llList2Vector(BUTTON_SET,set*3+2);
    
    if( row > set_grid.y ) llSay(DEBUG_CHANNEL,"get_offset: row too large for set " + (string)set);
    if( col > set_grid.x ) llSay(DEBUG_CHANNEL,"get_offset: col too large for set " + (string)set);
    
	MAIN_OFFSET = <-0.5 + BUTTON_SIZE.x/2,0.5 - BUTTON_SIZE.y*1/2,0> - tex_offset;
	OFFSET = <BUTTON_SIZE.x*col,-BUTTON_SIZE.y*row,0>;
    OFFSET += MAIN_OFFSET;
    
    llSetPrimitiveParams([
    	PRIM_TEXTURE,0,TEXTURE,BUTTON_SIZE,OFFSET,0.0,
    	PRIM_SIZE,llVecNorm(BUTTON_SIZE)
    ]);
    
    return [BUTTON_SIZE,OFFSET];
}

list get_all_offsets(integer set)
{
	vector set_grid = llList2Vector(BUTTON_SET,set*3+2);
	
	integer x;
	integer y;
	list offsets = [];
	if( TRANSPOSE ) 
	{
		for( x = 0; x < set_grid.x; ++x)
		{
			for( y = 0; y < set_grid.y; ++y)
			{
				offsets = offsets + get_offset(set,y,x);	
			}			
		}
	} else {
		for( y = 0; y < set_grid.y; ++y)
		{
			for( x = 0; x < set_grid.x; ++x)
			{
				offsets = offsets + get_offset(set,y,x);	
			}			
		}
	}
	return offsets;
}

OwnerSayLong(string long)
{
    integer len = llStringLength(long);
    integer num = llCeil(len/1024.0);
    integer i;
    for(i = 0; i < num; ++i)
    {
        llOwnerSay( llGetSubString(long,1024*i,-1) );
        llSleep(.5);
    }
}

default
{
	state_entry()
	{
		llSetText("Touch to Start",<1,1,1>,1.0);
	}
    touch_start(integer num)
    {
		integer len = llGetListLength(BUTTON_SET);
		if( len % 3 != 0 ) { llOwnerSay("Error: All sets must have all 3 parameters in BUTTON_SET list"); return; }
		integer i;
		for( i = 0; i < len/3; ++i)
		{
			llOwnerSay("Set " + (string)i);
			OwnerSayLong(llList2CSV(get_all_offsets(i)));
		}
    }
}
