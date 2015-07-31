-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0
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
        host = "54.223.220.42",
        port = 3000,
        name = "update-server-1"
    },
    gate = {
        host = "54.223.220.42",
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
CONFIG_LOG_DEBUG_FILE = false -- 记录日志文件
GLOBAL_FTE = true
GLOBAL_FTE_DEBUG = false

CONFIG_SCREEN_AUTOSCALE_CALLBACK = function(w, h, deviceModel)
    if w/h > 640/960 then
        CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
    end
end
