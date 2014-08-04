
#ifndef  _APP_DELEGATE_H_
#define  _APP_DELEGATE_H_

#include "CCApplication.h"
#include "ProjectConfig/SimulatorConfig.h"

class AppDelegateExtern : public cocos2d::CCObject
{
public:
    AppDelegateExtern(){};
    ~AppDelegateExtern(){};
    void restartGame();
};

/**
 @brief    The cocos2d Application.
 
 The reason for implement as private inheritance is to hide some interface call by CCDirector.
 */
class  AppDelegate : public cocos2d::CCApplication
{
public:
    AppDelegate();
    virtual ~AppDelegate();
    
    /**
     @brief    Implement CCDirector and CCScene init code here.
     @return true    Initialize success, app continue.
     @return false   Initialize failed, app terminate.
     */
    virtual bool applicationDidFinishLaunching();
    
    /**
     @brief  The function be called when the application enter background
     @param  the pointer of the application
     */
    virtual void applicationDidEnterBackground();
    
    /**
     @brief  The function be called when the application enter foreground
     @param  the pointer of the application
     */
    virtual void applicationWillEnterForeground();
    void setProjectConfig(const ProjectConfig& config);
    
    void initLuaEngine();
    
private:
    ProjectConfig m_projectConfig;
    
private:
    void extendApplication();
    void loadConfigFile();
    const char* getAppVersion();
    bool isDebug();
    void checkPath();
};

#endif // _APP_DELEGATE_H_
