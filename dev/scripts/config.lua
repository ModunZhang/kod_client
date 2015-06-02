-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2
DEBUG_FPS = false
DEBUG_MEM = false

-- design resolution
CONFIG_SCREEN_WIDTH = 640
CONFIG_SCREEN_HEIGHT = 960

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
CONFIG_SCREEN_ORIENTATION = "portrait"

LOAD_DEPRECATED_API = true

-- server config
CONFIG_LOCAL_SERVER = {
    update = {
        host = "127.0.0.1",
        port = 3000,
        name = "update-server-1"
    },
    gate = {
        host = "127.0.0.1",
        port = 3011,
        name = "gate-server-1"
    },
}
CONFIG_REMOTE_SERVER = {
    update = {
        host = "192.168.0.12",
        port = 80,
        name = "update-server-1"
    },
    gate = {
        host = "54.223.166.65",
        port = 3011,
        name = "gate-server-1"
    },
}
-- app store url
CONFIG_APP_URL = {
    ios = "https://itunes.apple.com/us/app/dragonfall-the-1st-moba-slg/id993631614?l=zh&ls=1&mt=8",
    android = "https://batcat.sinaapp.com/ad_hoc/build-index.html"
}

CONFIG_IS_LOCAL = false
CONFIG_IS_DEBUG = false
CONFIG_LOG_DEBUG_FILE = true -- 记录日志文件
GLOBAL_FTE = true
GLOBAL_FTE_DEBUG = false
GAME_DEFAULT_LANGUAGE = 'zh_TW' -- 游戏首次安装启动的默认语言 如果为nil则根据设备的语言为首次启动语言

CONFIG_SCREEN_AUTOSCALE_CALLBACK = function(w, h, deviceModel)
    if w/h > 640/960 then
        CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
    end
end
