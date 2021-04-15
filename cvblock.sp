#include <sourcemod>
#include <clientprefs>
 
#pragma semicolon 1
#pragma newdecls required
 
Cookie cookie_voteBlocked;
 
public Plugin myinfo = {
    name        = "Callvote Blocker",
    author      = "Jobggun",
    description = "This plugin helps to stop players spamming with internal vote system.",
    version     = "0.0.1",
    url         = ""
};
 
public void OnPluginStart()
{
    cookie_voteBlocked = new Cookie("sm_cvblocker_status", "CallVote Block Status", CookieAccess_Protected);
    
    AddCommandListener(CallVoteListener, "callvote");
    
    RegAdminCmd("sm_cvblock_ban", Cmd_AddBlock, ADMFLAG_GENERIC | ADMFLAG_KICK, "CallVote Block Add");
    RegAdminCmd("sm_cvblock_ban_steamid", Cmd_AddBlockSteamID, ADMFLAG_ROOT, "CallVote Block Add");
    RegAdminCmd("sm_cvblock_unban", Cmd_RemoveBlock, ADMFLAG_GENERIC | ADMFLAG_KICK, "CallVote Block Remove");
}

public Action Cmd_AddBlock(int client, int args)
{
    if(args != 1)
    {
        ReplyToCommand(client, "Usage: sm_cvblock_ban (TARGET)");
    }
    
    char name[256];
    
    GetCmdArg(1, name, sizeof(name));
    
    int target = FindTarget(client, name);
    
    if(target == -1)
    {
        ReplyToTargetError(client, target);
        
        return Plugin_Handled;
    }
    
    cookie_voteBlocked.Set(target, "1");
    
    return Plugin_Handled;
}

public Action Cmd_AddBlockSteamID(int client, int args)
{
    if(args != 1)
    {
        ReplyToCommand(client, "Usage: sm_cvblock_ban_steamid (SteamID)");
    }
    
    char steamid[256];
    
    GetCmdArg(1, steamid, sizeof(steamid));
    
    cookie_voteBlocked.SetByAuthId(steamid, "1");
    
    return Plugin_Handled;
}

public Action Cmd_RemoveBlock(int client, int args)
{
    if(args != 1)
    {
        ReplyToCommand(client, "Usage: sm_cvblock_unban (TARGET)");
    }
    
    char name[256];
    
    GetCmdArg(1, name, sizeof(name));
    
    int target = FindTarget(client, name);
    
    if(target == -1)
    {
        ReplyToTargetError(client, target);
        
        return Plugin_Handled;
    }
    
    cookie_voteBlocked.Set(target, "0");
    
    return Plugin_Handled;
}
 
public Action CallVoteListener(int client, const char[] command, int argc)
{
    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }
    
    if(!AreClientCookiesCached(client))
    {
        return Plugin_Continue;
    }
    
    char buf[32];
    
    cookie_voteBlocked.Get(client, buf, sizeof(buf));
    
    if(StringToInt(buf) == 1)
    {
        PrintToChat(client, "[CVB] You're banned from using callvote command by abusing vote system.");
        
        return Plugin_Stop;
    }
    
    return Plugin_Continue;
}
 
stock bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client));
}
