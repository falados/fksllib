// USAGE -
// Send Link Message 
//  NUM = ID#
//  STR = llList2CSV([Avatar Key, Dialog Message, Button1, Button2, ... ,Button N])
//  KEY = "#dialog#"
	// Wait for Link Message
// NUM = SAME ID#
// STR = Button Picked
// KEY = "#dialog-response#"
	// -- Constants -- //
	string NEXT_BUTTON = ">>";
string BACK_BUTTON = "<<";
	// -- Globals -- //
	integer gStartIndex;
integer gEndIndex;
integer gDialogNumber;
integer gDialogChannel;
integer gListenHandle_Dialog;
integer gMaxPages;
integer gCurrentPage;
key gDialogTarget;
string gDialogMessage;
list gAllOptions;
list gCurrentSelection;
list gCurrentPanel;
	dialog() 
{
	if( gCurrentPage < 0 ) gCurrentPage = 0;
	if( gCurrentPage > gMaxPages ) gCurrentPage = gMaxPages;
	gStartIndex = 0;
	gEndIndex = -1;
	if( gCurrentPage == 0 ) {
	if( gCurrentPage == gMaxPages )
		gCurrentPanel = llList2List(gAllOptions,0,-1);
	else {
		gEndIndex = 10;
		gCurrentPanel = llList2List(gAllOptions,0,1) + [NEXT_BUTTON] + llList2List(gAllOptions,2,gEndIndex);
	}
	}
	else if( gCurrentPage == gMaxPages) {
	gStartIndex = 11 + 10*(gMaxPages-1);
	gEndIndex = -1;
	gCurrentPanel = [BACK_BUTTON] + llList2List(gAllOptions,gStartIndex,gEndIndex);        
	} else {
	gStartIndex = 11 + 10*(gCurrentPage-1);
	gEndIndex = gStartIndex + 9;
	gCurrentPanel = [BACK_BUTTON] + llList2List(gAllOptions,gStartIndex,gStartIndex) + [NEXT_BUTTON] + llList2List(gAllOptions,gStartIndex+1,gEndIndex);
	}
	gCurrentSelection = gCurrentPanel;
	integer len = llGetListLength(gCurrentPanel);
	integer i;
	string item;
	for( i = 0; i < len; ++i)
	{
	item = llList2String(gCurrentPanel,i);
	if( llStringLength( item ) > 24 ) 
	{
		gCurrentPanel = llListReplaceList( gCurrentPanel , [llGetSubString(item,0,23)],i,i);
	}
		}
	llDialog(gDialogTarget,gDialogMessage,gCurrentPanel,gDialogChannel);
}
	default
{
	link_message(integer sn, integer num, string str, key id)
	{
	if(id == "#dialog#")
	{
		gDialogNumber = num;
		gDialogChannel = llFloor( llFrand(1000000) + 1000000 );
		list options = llCSV2List(str);
		gDialogTarget = llList2String(options,0);
		gDialogMessage = llList2String(options,1);
		gListenHandle_Dialog = llListen(gDialogChannel,"",gDialogTarget,"");
		gAllOptions = llDeleteSubList(options,0,1);
		
		gCurrentPage = 0;
		gMaxPages = 0;
		integer n = llGetListLength(gAllOptions);
		if( n > 12 )
		{
		    //First Page
		    n -= 11;
		    
		    //Middle Pages
		    while(n > 11) 
		    {
		        n-=10;
		        ++gMaxPages;
		    }
		    //Last Page
		    ++gMaxPages;
		}
		dialog();
	}
	}
	listen(integer channel, string name, key id, string str)
	{
	llListenRemove(gListenHandle_Dialog);
	if(str == NEXT_BUTTON)
	{
		++gCurrentPage;
		dialog();
	}else if( str == BACK_BUTTON )
	{
		--gCurrentPage;
		dialog();
	} else {
		integer i = llListFindList(gCurrentPanel,[str]);
		if( i != -1)
		{
		    string result = llList2String(gCurrentSelection,i);
		    llMessageLinked(LINK_SET,gDialogNumber,result,"#dialog-response#");
		} else {
		    dialog();
		}
	}
	}
}
