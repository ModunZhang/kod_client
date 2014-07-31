
#include "cocos2d.h"
#include "AppDelegate.h"
#include "SimpleAudioEngine.h"
#include "support/CCNotificationCenter.h"
#include "CCLuaEngine.h"
#include <string>
#include "tolua++.h"
#include "FileOperation.h"
#include "LuaExtension.h"

using namespace std;
using namespace cocos2d;
using namespace CocosDenshion;

#define CONFIG_IS_DEBUG false

void AppDelegateExtern::restartGame()
{
    AppDelegate* delegate = (AppDelegate *)CCApplication::sharedApplication();
    delegate->initLuaEngine();
}

AppDelegate::AppDelegate()
{
    // fixed me
    //_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF|_CRTDBG_LEAK_CHECK_DF);
}

AppDelegate::~AppDelegate()
{
    // end simple audio engine here, or it may crashed on win32
    SimpleAudioEngine::sharedEngine()->end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());
    pDirector->setProjection(kCCDirectorProjection2D);
    
    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);
    
    this->initLuaEngine();
    
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();
    CCDirector::sharedDirector()->pause();
    SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    SimpleAudioEngine::sharedEngine()->pauseAllEffects();
    CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_ENTER_BACKGROUND");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();
    CCDirector::sharedDirector()->resume();
    SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
    SimpleAudioEngine::sharedEngine()->resumeAllEffects();
    CCNotificationCenter::sharedNotificationCenter()->postNotification("APP_ENTER_FOREGROUND");
}

void AppDelegate::initLuaEngine()
{
    // register lua engine
    CCScriptEngineManager::sharedManager()->removeScriptEngine();
    CCLuaEngine *pEngine = CCLuaEngine::defaultEngine();
    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);
    CCLuaStack *pStack = pEngine->getLuaStack();
    
    loadConfigFile();
    checkPath();
    extendApplication();
    
    pStack->loadChunksFromZIP("res/framework_precompiled.zip");
    string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("scripts/main.lua");
    
    size_t pos;
    while ((pos = path.find_first_of("\\")) != std::string::npos)
    {
        path.replace(pos, 1, "/");
    }
    size_t p = path.find_last_of("/\\");
    if (p != path.npos)
    {
        const string dir = path.substr(0, p);
        pStack->addSearchPath(dir.c_str());
        
        p = dir.find_last_of("/\\");
        if (p != dir.npos)
        {
            pStack->addSearchPath(dir.substr(0, p).c_str());
        }
    }
    
    string env = "__LUA_STARTUP_FILE__=\"";
    env.append(path);
    env.append("\"");
    pEngine->executeString(env.c_str());
    
    CCLOG("------------------------------------------------");
    CCLOG("LOAD LUA FILE: %s", path.c_str());
    CCLOG("------------------------------------------------");
    pEngine->executeScriptFile(path.c_str());
}

void AppDelegate::extendApplication()
{
    lua_State* tolua_S = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    tolua_cc_pomelo_open(tolua_S);
    tolua_cc_lua_extension(tolua_S);
}

void AppDelegate::loadConfigFile()
{
    CCLuaEngine *pEngine = CCLuaEngine::defaultEngine();
    string path = CCFileUtils::sharedFileUtils()->fullPathForFilename("scripts/config.lua");
    printf("%s", path.c_str());
    pEngine->executeScriptFile("scripts/config.lua");
}

const char* AppDelegate::getAppVersion()
{
    lua_State* tolua_S = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    lua_getglobal(tolua_S, "CONFIG_APP_VERSION");
    const char* path = tolua_tostring(tolua_S, -1, 0);
    return path;
}

bool AppDelegate::isDebug()
{
    lua_State* tolua_S = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
    lua_getglobal(tolua_S, "CONFIG_IS_DEBUG");
    bool isDebug = tolua_toboolean(tolua_S, -1, 0);
    return isDebug;
}

void AppDelegate::checkPath()
{
    CCFileUtils* fileUtils = CCFileUtils::sharedFileUtils();
    const char* appVersion = this->getAppVersion();
    string writePath = fileUtils->getWritablePath();
    string updatePath = writePath + "update";
    string appPath = updatePath + "/" + appVersion;
    if(!fileUtils->isDirectoryExist(appPath)){
        if(fileUtils->isDirectoryExist(updatePath)){
            FileOperation::removeDirectory(updatePath.c_str());
        }
        FileOperation::createDirectory(updatePath.c_str());
        FileOperation::createDirectory(appPath.c_str());
    }
    string resPath = appPath + "/res";
    string scriptsPath = appPath + "/scripts";
    if (!fileUtils->isDirectoryExist(resPath)) {
        FileOperation::createDirectory(resPath.c_str());
    }
    if (!fileUtils->isDirectoryExist(scriptsPath)) {
        FileOperation::createDirectory(scriptsPath.c_str());
    }
    string from = CCFileUtils::sharedFileUtils()->fullPathForFilename("res/fileList.json");
    string to = appPath + "/res/fileList.json";
    if (!CCFileUtils::sharedFileUtils()->isFileExist(to)) {
        FileOperation::copyFile(from.c_str(), to.c_str());
    }
    
    std::vector<std::string> paths = fileUtils->getSearchPaths();
    if (this->isDebug())
    {
        paths.insert(paths.begin(), "res/");
        fileUtils->setSearchPaths(paths);
    }
    else
    {
        paths.insert(paths.begin(), appPath.c_str());
        paths.insert(paths.begin(), "res/");
        paths.insert(paths.begin(), resPath.c_str());
        fileUtils->setSearchPaths(paths);
        CCLuaEngine::defaultEngine()->addSearchPath(scriptsPath.c_str());
    }
}
