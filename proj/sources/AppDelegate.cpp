#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "FileOperation.h"
#if (COCOS2D_DEBUG>0)
#include "codeIDE/runtime/Runtime.h"
#include "codeIDE/ConfigParser.h"
#endif

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;


void AppDelegateExtern::restartGame(float dt)
{
    initLuaEngine();
}


void AppDelegateExtern::extendApplication()
{
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    tolua_cc_pomelo_open(tolua_S);
    tolua_cc_lua_extension(tolua_S);
}


void AppDelegateExtern::initLuaEngine()
{
    ScriptEngineManager::getInstance()->removeScriptEngine();
    LuaEngine *pEngine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(pEngine);
    LuaStack *pStack = pEngine->getLuaStack();
    string defaultLuaPath = FileUtils::getInstance()->fullPathForFilename("scripts/main.lua");
    loadConfigFile();
    checkPath();
    extendApplication();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    // load framework
    pStack->loadChunksFromZIP("res/framework_precompiled.zip");
    
    // set script path
    string path = FileUtils::getInstance()->fullPathForFilename("scripts/main.lua");
    
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WP8 || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
    // load framework
    pStack->loadChunksFromZIP("res/framework_precompiled_wp8.zip");
    
    // set script path
    string path = FileUtils::getInstance()->fullPathForFilename("scripts/main.lua");
    
#else
    // load framework
    if (_projectConfig.isLoadPrecompiledFramework())
    {
        const string precompiledFrameworkPath = SimulatorConfig::getInstance()->getPrecompiledFrameworkPath();
        pStack->loadChunksFromZIP(precompiledFrameworkPath.c_str());
    }
    
    // set script path
    string path = FileUtils::getInstance()->fullPathForFilename(_projectConfig.getScriptFileRealPath().c_str());
#endif
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    // Code IDE
    if (_projectConfig.getDebuggerType() == kCCLuaDebuggerCodeIDE)
    {
        if (startRuntime()) return true;
    }
#endif //CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    
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
    
    //update bundle lua search path
    while ((pos = defaultLuaPath.find_first_of("\\")) != std::string::npos)
    {
        defaultLuaPath.replace(pos, 1, "/");
    }
    p = defaultLuaPath.find_last_of("/\\");
    if (p != defaultLuaPath.npos)
    {
        const string dir = defaultLuaPath.substr(0, p);
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

void AppDelegateExtern::loadConfigFile()
{
    LuaEngine *pEngine = LuaEngine::getInstance();
    string path = FileUtils::getInstance()->fullPathForFilename("scripts/config.lua");
    pEngine->executeScriptFile("scripts/config.lua");
}

const char* AppDelegateExtern::getAppVersion()
{
    lua_State *tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(tolua_S, "CONFIG_APP_VERSION");
    const char* path = tolua_tostring(tolua_S, -1, 0);
    return path;
}


bool AppDelegateExtern::isDebug()
{
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(tolua_S, "CONFIG_IS_DEBUG");
    bool isDebug = tolua_toboolean(tolua_S, -1, 0);
    return isDebug;
}


void AppDelegateExtern::checkPath()
{
    FileUtils* fileUtils = FileUtils::getInstance();
    const char* appVersion = getAppVersion();
    string writePath = fileUtils->getWritablePath();
    string updatePath = writePath + "update/";
    string appPath = updatePath + appVersion + "/";
    if(!fileUtils->isDirectoryExist(appPath)){
        if(fileUtils->isDirectoryExist(updatePath)){
            FileOperation::removeDirectory(updatePath.c_str());
        }
        FileOperation::createDirectory(updatePath.c_str());
        FileOperation::createDirectory(appPath.c_str());
    }
    string resPath = appPath + "res/";
    string scriptsPath = appPath + "scripts/";
    if (!fileUtils->isDirectoryExist(resPath)) {
        FileOperation::createDirectory(resPath.c_str());
    }
    if (!fileUtils->isDirectoryExist(scriptsPath)) {
        FileOperation::createDirectory(scriptsPath.c_str());
    }
    string from = FileUtils::getInstance()->fullPathForFilename("res/fileList.json");
    string to = appPath + "res/fileList.json";
    if (!FileUtils::getInstance()->isFileExist(to)) {
        FileOperation::copyFile(from.c_str(), to.c_str());
    }
    
    std::vector<std::string> paths = fileUtils->getSearchPaths();
    if (isDebug())
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
    }
}


AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    if (_projectConfig.getDebuggerType() == kCCLuaDebuggerCodeIDE)
    {
        initRuntime(_projectConfig.getProjectDir());
        if (!ConfigParser::getInstance()->isInit())
        {
            ConfigParser::getInstance()->readConfig();
        }
    }
#endif //CC_TARGET_PLATFORM == CC_PLATFORM_MAC
    
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#else
        Size viewSize = _projectConfig.getFrameSize();
        glview = GLView::createWithRect("kod", Rect(0,0,viewSize.width,viewSize.height));
        director->setOpenGLView(glview);
#endif
    }
    
    // turn on display FPS
    director->setDisplayStats(true);
    
    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);
    //call our functions
    AppDelegateExtern::initLuaEngine();

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent(EVENT_COME_TO_BACKGROUND);
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();
    Director::getInstance()->resume();
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent(EVENT_COME_TO_FOREGROUND);
}

void AppDelegate::setProjectConfig(const ProjectConfig& config)
{
    _projectConfig = config;
}


