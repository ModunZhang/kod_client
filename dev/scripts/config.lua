-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2
DEBUG_FPS = true
DEBUG_MEM = false

-- design resolution
CONFIG_SCREEN_WIDTH = 640
CONFIG_SCREEN_HEIGHT = 960

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

-- big version config
CONFIG_APP_VERSION = "0.0.1"

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
        host = "54.178.151.193",
        port = 3000,
        name = "update-server-1"
    },
    gate = {
        host = "54.178.151.193",
        port = 3011,
        name = "gate-server-1"
    },
}

CONFIG_IS_LOCAL = false
CONFIG_IS_DEBUG = true