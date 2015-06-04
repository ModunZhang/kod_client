//
//  MarketSDKTool.m
//  kod
//
//  Created by DannyHe on 3/13/15.
//
//

#include "MarketSDKTool.h"
#import "TalkingDataGA.h"
#include "tolua_fix.h"
//MARK:定义宏
#define USE_TAKING_DATA true
#define TD_APP_ID @"3309C905801D8D028876DB821ADB0123"
#define TD_CHANNEL_ID @"All"

static MarketSDKTool *s_MarketSDKTool = NULL; // pointer to singleton
#ifdef USE_TAKING_DATA
static TDGAAccount *tdga_account = NULL;
#endif
MarketSDKTool * MarketSDKTool::getInstance()
{
    if(!s_MarketSDKTool)
    {
        s_MarketSDKTool = new MarketSDKTool();
    }
    return s_MarketSDKTool;
}

void MarketSDKTool::destroyInstance()
{
     if(s_MarketSDKTool)
     {
         delete s_MarketSDKTool;
         s_MarketSDKTool = NULL;
     }
}

void MarketSDKTool::initSDK()
{
#ifdef USE_TAKING_DATA
    [TalkingDataGA onStart:TD_APP_ID withChannelId:TD_CHANNEL_ID];
    [TalkingDataGA setVerboseLogDisabled];
#endif
}


void MarketSDKTool::onPlayerLogin(const char *playerId,const char*playerName,const char*serverName)
{
#ifdef USE_TAKING_DATA
    TDGAAccount *account = [TDGAAccount setAccount:[NSString stringWithUTF8String:playerId]];
    [account setAccountName:[NSString stringWithUTF8String:playerName]];
    [account setAccountType:kAccountRegistered];
    [account setGender:kGenderUnknown];
    [account setGameServer:[NSString stringWithUTF8String:serverName]];
    tdga_account = account;
#endif
}

void MarketSDKTool::onPlayerChargeRequst(const char *orderID, const char *productId, double currencyAmount, double virtualCurrencyAmount,const char *currencyType)
{
#ifdef USE_TAKING_DATA
    [TDGAVirtualCurrency onChargeRequst:[NSString stringWithUTF8String:orderID]
                                  iapId:[NSString stringWithUTF8String:productId]
                         currencyAmount:currencyAmount currencyType:[NSString stringWithUTF8String:currencyType]
                  virtualCurrencyAmount:virtualCurrencyAmount
                            paymentType:@"Apple"];
#endif
}

void MarketSDKTool::onPlayerChargeSuccess(const char *orderID)
{
#ifdef USE_TAKING_DATA
     [TDGAVirtualCurrency onChargeSuccess:[NSString stringWithUTF8String:orderID]];
#endif
}

void MarketSDKTool::onPlayerBuyGameItems(const char *itemID, int count, double itemPrice)
{
#ifdef USE_TAKING_DATA
    [TDGAItem onPurchase:[NSString stringWithUTF8String:itemID] itemNumber:count priceInVirtualCurrency:itemPrice];
#endif
}

void MarketSDKTool::onPlayerUseGameItems(const char *itemID,int count)
{
#ifdef USE_TAKING_DATA
    [TDGAItem onUse:[NSString stringWithUTF8String:itemID] itemNumber:count];
#endif
}

void MarketSDKTool::onPlayerReward(double cont,const char* reason)
{
#ifdef USE_TAKING_DATA
    [TDGAVirtualCurrency onReward:cont reason:[NSString stringWithUTF8String:reason]];
#endif
}

void MarketSDKTool::onPlayerEvent(const char *event_id,const char*arg)
{
#ifdef USE_TAKING_DATA
    [TalkingDataGA onEvent:[NSString stringWithUTF8String:event_id] eventData:@{@"desc":[NSString stringWithUTF8String:arg]}];
#endif
}

void MarketSDKTool::onPlayerLevelUp(int level)
{
#ifdef USE_TAKING_DATA
    if (tdga_account) {
        [tdga_account setLevel:level];
    }
#endif
}

//MARK:LuaWarpper
static int tolua_market_onPlayerLogin(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S,1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S,2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S,3, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerLogin(tolua_tostring(tolua_S, 1, 0), tolua_tostring(tolua_S, 2, 0),tolua_tostring(tolua_S, 3, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerLogin'.",&tolua_err);
    return 0;
#endif
    return 0;
}

static int tolua_market_onPlayerChargeRequst(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err)||
        !tolua_isnumber(tolua_S, 4, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        const char * default_currencyType = tolua_isstring(tolua_S, 5, 0, &tolua_err) ? tolua_tostring(tolua_S, 5, 0) : "USD";
        MarketSDKTool::getInstance()->onPlayerChargeRequst(tolua_tostring(tolua_S, 1, 0), tolua_tostring(tolua_S, 2, 0), tolua_tonumber(tolua_S, 3, 0), tolua_tonumber(tolua_S, 4, 0),default_currencyType);
         return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerChargeRequst'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerChargeSuccess(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S,1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerChargeSuccess(tolua_tostring(tolua_S, 1, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerChargeSuccess'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerBuyGameItems(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerBuyGameItems(tolua_tostring(tolua_S, 1, 0),tolua_tonumber(tolua_S, 2, 0),tolua_tonumber(tolua_S, 3, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerBuyGameItems'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}


static int tolua_market_onPlayerUseGameItems(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerUseGameItems(tolua_tostring(tolua_S, 1, 0),tolua_tonumber(tolua_S, 2, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerUseGameItems'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}


static int tolua_market_onPlayerReward(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 1, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerReward(tolua_tonumber(tolua_S, 1, 0),tolua_tostring(tolua_S, 2, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerReward'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerEvent(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err)        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerEvent(tolua_tostring(tolua_S, 1, 0),tolua_tostring(tolua_S, 2, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerEvent'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerLevelUp(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isnumber(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerLevelUp(tolua_tonumber(tolua_S, 1, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerLevelUp'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}


void tolua_ext_module_market(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME_MARKET,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_MARKET);
    tolua_function(tolua_S,"onPlayerLogin",tolua_market_onPlayerLogin);
    tolua_function(tolua_S,"onPlayerChargeRequst",tolua_market_onPlayerChargeRequst);
    tolua_function(tolua_S,"onPlayerChargeSuccess",tolua_market_onPlayerChargeSuccess);
    tolua_function(tolua_S,"onPlayerBuyGameItems",tolua_market_onPlayerBuyGameItems);
    tolua_function(tolua_S,"onPlayerUseGameItems",tolua_market_onPlayerUseGameItems);
    tolua_function(tolua_S,"onPlayerReward",tolua_market_onPlayerReward);
    tolua_function(tolua_S,"onPlayerEvent",tolua_market_onPlayerEvent);
    tolua_function(tolua_S,"onPlayerLevelUp",tolua_market_onPlayerLevelUp);
    tolua_endmodule(tolua_S);
}

