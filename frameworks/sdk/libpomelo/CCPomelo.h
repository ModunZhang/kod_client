//
//
//  Created by xudexin on 13-4-17.
//
//

#ifndef __CCPomelo__
#define __CCPomelo__

#include "cocos2d.h"

#include "jansson.h"
#include "pomelo.h"
#include<queue>

using namespace cocos2d;

class CCPomeloContent_;
class CCPomeloReponse_;
class CCPomeloEvent_ ;
class CCPomeloNotify_;
class CCPomeloConnect_;
class CCPomeloReponse;

typedef std::function<void(const CCPomeloReponse&)> PomeloCallback;


class CCPomeloReponse:public cocos2d::Ref{
public:
    CCPomeloReponse(){}
    ~CCPomeloReponse(){}
    int status;
    json_t *docs;
};



class CCPomelo :public cocos2d::Ref{
public:
    static CCPomelo *getInstance();
    static void destroyInstance();
    
    int connect(const char* addr,int port);
    void asyncConnect(const char* addr,int port, const PomeloCallback& callback);
    void stop();

    int request(const char*route,json_t *msg, const PomeloCallback& callback);
    int notify(const char*route,json_t *msg, const PomeloCallback& callback);
    int addListener(const char* event, const PomeloCallback& callback);
    void removeListener(const char* event);

public:
    CCPomelo();
    virtual ~CCPomelo();
    
    void cleanup();
    
    void cleanupEventContent();
    void cleanupNotifyContent();
    void cleanupRequestContent();
    
    void dispatchCallbacks(float delta);
    
    
    void lockReponsQeueue();
    void unlockReponsQeueue();
    void lockEventQeueue();
    void unlockEventQeueue();
    void lockNotifyQeueue();
    void unlockNotifyQeueue();
    
    void lockConnectContent();
    void unlockConnectContent();
    
    
    void pushReponse(CCPomeloReponse_*resp);
    void pushEvent(CCPomeloEvent_*ev);
    void pushNotiyf(CCPomeloNotify_*ntf);
    void connectCallBack(int status);

private:
    void incTaskCount();
    void desTaskCount();
    
    CCPomeloReponse_*popReponse();
    CCPomeloEvent_*popEvent();
    CCPomeloNotify_*popNotify();
    
    std::map<pc_notify_t*,CCPomeloContent_*> notify_content;
    pthread_mutex_t  notify_queue_mutex;
    std::queue<CCPomeloNotify_*> notify_queue;
    
    std::map<std::string,CCPomeloContent_*> event_content;
    pthread_mutex_t  event_queue_mutex;
    std::queue<CCPomeloEvent_*> event_queue;
    
    std::map<pc_request_t *,CCPomeloContent_*> request_content;
    pthread_mutex_t  reponse_queue_mutex;
    std::queue<CCPomeloReponse_*> reponse_queue;
    
    
    pthread_mutex_t  connect_mutex;
    CCPomeloConnect_* connect_content;
    
    
    pthread_mutex_t  task_count_mutex;
    void dispatchRequest();
    void dispatchEvent();
    void dispatchNotify();
    void connectCallBack();
    pc_client_t *client;
    int task_count;
    int connect_status;
};

#endif /* defined(__CCPomelo__) */
