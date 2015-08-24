#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WP8)
#include "CodeIDESupport.h"
#include "Runtime.h"
#endif
#include "ConfigParser.h"
#include "lua_module_register.h"


// extra lua module
#include "cocos2dx_extra.h"
#include "lua_extensions/lua_extensions_more.h"
#include "luabinding/lua_cocos2dx_extension_filter_auto.hpp"
#include "luabinding/lua_cocos2dx_extension_nanovg_auto.hpp"
#include "luabinding/lua_cocos2dx_extension_nanovg_manual.hpp"
#include "luabinding/cocos2dx_extra_luabinding.h"
#include "luabinding/HelperFunc_luabinding.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "luabinding/cocos2dx_extra_ios_iap_luabinding.h"
#include "CommonUtils.h"
#endif
#if ANYSDK_DEFINE > 0
#include "anysdkbindings.h"
#include "anysdk_manual_bindings.h"
#endif
#include "LuaExtension.h"
#include "FileOperation.h"
//json
#include "../cocos2d-x/external/json/document.h"
#include "../cocos2d-x/external/json/rapidjson.h"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;
static  std::vector<std::string> default_file_util_search_pahts;
static void quick_module_register(lua_State *L)
{
    luaopen_lua_extensions_more(L);

    lua_getglobal(L, "_G");
    if (lua_istable(L, -1))//stack:...,_G,
    {
        register_all_quick_manual(L);
        // extra
        luaopen_cocos2dx_extra_luabinding(L);
        register_all_cocos2dx_extension_filter(L);
        register_all_cocos2dx_extension_nanovg(L);
        register_all_cocos2dx_extension_nanovg_manual(L);
        luaopen_HelperFunc_luabinding(L);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        luaopen_cocos2dx_extra_ios_iap_luabinding(L);
#endif
    }
    lua_pop(L, 1);
}

//
AppDelegate::AppDelegate()
:_launchMode(0)
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
	ConfigParser::purge();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = { 8, 8, 8, 8, 24, 8 };

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();    
    if(!glview) {
        Size viewSize = ConfigParser::getInstance()->getInitViewSize();
        string title = ConfigParser::getInstance()->getInitViewName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        extern void createSimulator(const char* viewName, float width, float height, bool isLandscape = true, float frameZoomFactor = 1.0f);
        bool isLanscape = ConfigParser::getInstance()->isLanscape();
        createSimulator(title.c_str(),viewSize.width,viewSize.height, isLanscape);
#else
        glview = cocos2d::GLViewImpl::createWithRect(title.c_str(), Rect(0, 0, viewSize.width, viewSize.height));
        director->setOpenGLView(glview);
#endif
        default_file_util_search_pahts = FileUtils::getInstance()->getSearchPaths();
        FileUtils::getInstance()->setPopupNotify(true);
//        director->startAnimation();
    }
   
    AppDelegateExtern::initLuaEngine();
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#else
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_BACKGROUND_EVENT");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->resume();
    Director::getInstance()->startAnimation();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#else
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif
    Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_FOREGROUND_EVENT");
}

void AppDelegate::setLaunchMode(int mode)
{
    _launchMode = mode;
}


void AppDelegateExtern::restartGame(float dt)
{
    initLuaEngine();
}


void AppDelegateExtern::extendApplication()
{
    //register custom function
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    tolua_cc_pomelo_open(tolua_S);
    tolua_cc_lua_extension(tolua_S);
}


void AppDelegateExtern::initLuaEngine()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();
    FileUtils::getInstance()->setSearchPaths(default_file_util_search_pahts); //还原搜索路径
    
    ScriptEngineManager::getInstance()->removeScriptEngine();
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);
    
    // use Quick-Cocos2d-X
    quick_module_register(L);
    extendApplication();
    
    LuaStack* stack = engine->getLuaStack();
#if ANYSDK_DEFINE > 0
    lua_getglobal(stack->getLuaState(), "_G");
    tolua_anysdk_open(stack->getLuaState());
    tolua_anysdk_manual_open(stack->getLuaState());
    lua_pop(stack->getLuaState(), 1);
#endif
    
    stack->setXXTEAKeyAndSign("Cbcm78HuH60MCfA7", strlen("Cbcm78HuH60MCfA7"),"XXTEA", strlen("XXTEA"));
    string path = FileUtils::getInstance()->fullPathForFilename("scripts/game.zip");//in bundle
    bool use_bundle_zip = true;
    loadConfigFile();
    use_bundle_zip = checkPath();
    stack->reload("config");
    Director::getInstance()->resume();
    Director::getInstance()->startAnimation();
    if (use_bundle_zip)
    {
        stack->loadChunksFromZIP(path.c_str());
    }
    else
    {
        //in document
        path = FileUtils::getInstance()->fullPathForFilename("scripts/game.zip");
        stack->loadChunksFromZIP(path.c_str());
    }
    CCLOG("use zip path:%s",path.c_str());
    stack->executeString("require 'main'");
}

void AppDelegateExtern::loadConfigFile()
{
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
    stack->executeChunkFromZip("scripts/game.zip", "config");
    stack->executeString("require 'config'");
}

const char* AppDelegateExtern::getAppVersion()
{
    const char*ipaVersion = GetAppVersion();
    if (ipaVersion != NULL)
    {
        return ipaVersion;
    }
}


bool AppDelegateExtern::isDebug()
{
    return isAppAdHocMode();
}

string AppDelegateExtern::getGameZipcrc32(const char *filePath)
{
    FileUtils *fileUtils = FileUtils::getInstance();
    if (fileUtils->isFileExist(filePath))
    {
        string json_contents = fileUtils->getStringFromFile(filePath);
        if (json_contents.length()>0)
        {
            rapidjson::Document d;
            d.Parse<0>(json_contents.c_str());
            if (d.HasParseError())
            {
                CCLOG("GetParseError %s %s\n",filePath,d.GetParseError());
                return filePath;
            }
            else
            {
                if(d.HasMember("files"))
                {
                    const rapidjson::Value &files=d["files"];
                    rapidjson::Value::ConstMemberIterator it = files.MemberonBegin();
                    
                    for (; it !=files.MemberonEnd(); ++it)
                    {
                        string name = it->name.GetString();
                        size_t pos = name.rfind("game.zip");
                        if (pos != std::string::npos)
                        {
                            const rapidjson::Value & tagData = it->value;
                            if(tagData.HasMember("crc32"))
                            {
                                string crc32 = tagData["crc32"].GetString();
                                return crc32;
                            }
                        }

                    }
                }
            }
        }
        
    }
    return filePath;
}

bool AppDelegateExtern::checkPath()
{
    bool need_Load_zip_from_bundle = false;
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
    
    string doucument_zip_path = scriptsPath + "game.zip";
    if (!fileUtils->isFileExist(doucument_zip_path))
    {
        need_Load_zip_from_bundle = true;
        //还原版本信息重新执行自动更新
        if (FileUtils::getInstance()->isFileExist(from)) {
            FileOperation::copyFile(from.c_str(), to.c_str());
        }
    }
    else
    {
        //验证zip完整性
        //获取game.zip crc32 fileList
        unsigned long crc32 = getFileCrc32(doucument_zip_path.c_str());
        string crc32_in_config = getGameZipcrc32(to.c_str());
        char crc32_val[32];
        sprintf(crc32_val, "%08lx", crc32);
        if (strcmp(crc32_val, crc32_in_config.c_str()) != 0)
        {
            need_Load_zip_from_bundle = true;
            //还原版本信息重新执行自动更新
            if (FileUtils::getInstance()->isFileExist(from)) {
                FileOperation::copyFile(from.c_str(), to.c_str());
            }
        }
        else
        {
            need_Load_zip_from_bundle = false;
        }
        
    }
    std::vector<std::string> paths = fileUtils->getSearchPaths();
    if (isDebug())
    {
        paths.insert(paths.begin(), "res/images");
        paths.insert(paths.begin(), "res/");
        fileUtils->setSearchPaths(paths);
    }
    else
    {
        
        paths.insert(paths.begin(), "res/images/");
        paths.insert(paths.begin(), "res/");
        paths.insert(paths.begin(), (resPath + "images/").c_str());
        paths.insert(paths.begin(), resPath.c_str());
        paths.insert(paths.begin(), appPath.c_str());
        fileUtils->setSearchPaths(paths);
    }
    
    //update lua path
    //in documents
    
    LuaStack* pStack = LuaEngine::getInstance()->getLuaStack();
    size_t pos;
    while ((pos = scriptsPath.find_first_of("\\")) != std::string::npos)
    {
        scriptsPath.replace(pos, 1, "/");
    }
    size_t p = scriptsPath.find_last_of("/\\");
    if (p != scriptsPath.npos)
    {
        const string dir = scriptsPath.substr(0, p);
        pStack->addSearchPath(dir.c_str());
        
        p = dir.find_last_of("/\\");
        if (p != dir.npos)
        {
            pStack->addSearchPath(dir.substr(0, p).c_str());
        }
    }
    return need_Load_zip_from_bundle;
}