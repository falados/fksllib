$import fksllib.modules.largecom.lslm(CHANNEL=CHANNEL);
integer CHANNEL;
default
{
	listen(integer channel, string name, key id, string message)
	{
		LCOMM_RCV(message);
	}
	link_message(integer send_num, integer message_id, string message, key command)
	{   
		//Setup for send/receive
		if( command == "#msetup#" )
		{
			LCOMM_INIT(message_id,(integer)message);
			return;
		}
		if( !MYID ) return;
		
		//Send message to all
		if( command == "#msend#")
		{
			LCOMM_XMT(message,message_id,FALSE);
			return;
		}
		
		//Send to target
		if( llSubStringIndex(command,"#msend#") == 0)
		{
			integer target = (integer)llGetSubString(command,7,-1);
			LCOMM_XMT(message,message_id,target);
			return;
		}
	}
}
