//
//  MarketSDKTool.h
//  kod
//
//  Created by DannyHe on 3/13/15.
//

#include "tolua++.h"

/**
 *  MarketSDKTool 市场sdk工具类
 */
class MarketSDKTool
{
public:
    static MarketSDKTool *getInstance();
    void destroyInstance();
    /**
     *  玩家登陆成功
     *
     *  @param playerId   玩家ID
     *  @param playerName 玩家名称
     *  @param serverName 服务器名称
     */
    void onPlayerLogin(const char *playerId,const char*playerName,const char*serverName = "");
    /**
     *  虚拟币充值请求
     *
     *  @param orderID               订单号
     *  @param productId             购买的商品编号
     *  @param currencyAmount        现金金额
     *  @param virtualCurrencyAmount 游戏币金额
     *  @param currencyType          货币类型
     */
    void onPlayerChargeRequst(const char* orderID,const char*productId,double currencyAmount,double virtualCurrencyAmount,const char *currencyType);
    /**
     *  虚拟币充值成功
     *
     *  @param orderID 订单号
     */
    void onPlayerChargeSuccess(const char* orderID);
    /**
     *  虚拟币购买游戏中的道具或者消费宝石
     *
     *  @param itemID    道具的唯一标识
     *  @param count     购买数量
     *  @param itemPrice 道具价格
     */
    void onPlayerBuyGameItems(const char* itemID,int count,double itemPrice);
    /**
     *  消费游戏中的道具
     *
     *  @param itemID 道具的唯一标识
     *  @param count  使用数量
     */
    void onPlayerUseGameItems(const char* itemID,int count = 1);
    /**
     *  玩家获得虚拟币奖励
     *
     *  @param cont 数量
     *  @param reason 奖励原因
     */
    void onPlayerReward(double cont,const char *reason = "奖励");
    /**
     * 初始化函数
     */
    void initSDK();
    /**
     *  记录自定义事件
     *
     *  @param event_id 事件名称或id
     *  @param arg      额外参数
     */
    void onPlayerEvent(const char* event_id,const char * arg = "");
    /**
     *  用户等级升级
     *
     *  @param level 等级
     */
    void onPlayerLevelUp(int level);
};

#define EXT_MODULE_NAME_MARKET "market_sdk"
void tolua_ext_module_market(lua_State* tolua_S);
