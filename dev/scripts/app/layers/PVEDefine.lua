local Enum = import("..utils.Enum")
local SpriteConfig = import("..sprites.SpriteConfig")

local OBJECT_TYPE = Enum("START_AIRSHIP",
    "WOODCUTTER",
    "QUARRIER",
    "MINER",
    "FARMER",
    "CAMP",
    "CRASHED_AIRSHIP",
    "CONSTRUCTION_RUINS",
    "KEEL",
    "WARRIORS_TOMB",
    "OBELISK",
    "ANCIENT_RUINS",
    "ENTRANCE_DOOR",
    "TREE",
    "HILL",
    "LAKE")
local OBJECT_IMAGE = {}
OBJECT_IMAGE[OBJECT_TYPE.START_AIRSHIP] = "airship_106x81.png"
OBJECT_IMAGE[OBJECT_TYPE.WOODCUTTER] = SpriteConfig["woodcutter"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.QUARRIER] = SpriteConfig["quarrier"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.MINER] = SpriteConfig["miner"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.FARMER] = SpriteConfig["farmer"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.CAMP] = "camp_137x80.png"
OBJECT_IMAGE[OBJECT_TYPE.CRASHED_AIRSHIP] = "crashed_airship_94x80.png"
OBJECT_IMAGE[OBJECT_TYPE.CONSTRUCTION_RUINS] = "ruin_1_136x92.png"
OBJECT_IMAGE[OBJECT_TYPE.KEEL] = "keel_95x80.png"
OBJECT_IMAGE[OBJECT_TYPE.WARRIORS_TOMB] = "warriors_tomb.png"
OBJECT_IMAGE[OBJECT_TYPE.OBELISK] = "obelisk.png"
OBJECT_IMAGE[OBJECT_TYPE.ANCIENT_RUINS] = "ancient_ruins.png"
OBJECT_IMAGE[OBJECT_TYPE.ENTRANCE_DOOR] = "entrance_door.png"
OBJECT_IMAGE[OBJECT_TYPE.TREE] = "tree_2_120x120.png"
OBJECT_IMAGE[OBJECT_TYPE.HILL] = "hill_228x146.png"
OBJECT_IMAGE[OBJECT_TYPE.LAKE] = "lake_220x174.png"



local OBJECT_DESC = {}
OBJECT_DESC[OBJECT_TYPE.START_AIRSHIP] = _('手下向你汇报, 飞艇一切准备就绪, "长官希望前往何处?"')
OBJECT_DESC[OBJECT_TYPE.WOODCUTTER] = _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
OBJECT_DESC[OBJECT_TYPE.QUARRIER] = _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
OBJECT_DESC[OBJECT_TYPE.MINER] = _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
OBJECT_DESC[OBJECT_TYPE.FARMER] = _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
OBJECT_DESC[OBJECT_TYPE.CAMP] = _('你大胆地闯入了一支不明身份部队的营地, 一场战斗一触即发。')
OBJECT_DESC[OBJECT_TYPE.CRASHED_AIRSHIP] = _('你发现了一艘坠毁的飞艇, 其中的有大量的物资, 但当你走近时却发现那里已经被强盗占领。')
OBJECT_DESC[OBJECT_TYPE.CONSTRUCTION_RUINS] = _('废弃的建筑残骸, 不知道是否能找到一些有价值的东西, 是否愿意花费3点体力搜索这里?')
OBJECT_DESC[OBJECT_TYPE.KEEL] = _('你发现了一具阵亡的巨龙骸骨, 恍惚间, 有声音在低语, "你想获得我的知识, 还是我的生命?"')
OBJECT_DESC[OBJECT_TYPE.WARRIORS_TOMB] = _('你发现一些未被安葬的战士的遗骸, 是否花费10个宝石将他们安葬?')
OBJECT_DESC[OBJECT_TYPE.OBELISK] = _('你发现一座用你从未见过的石头雕刻的石碑。你上前仔细观察一番, 石碑上突然闪现一个神秘的符文没入你的身体, 让你感觉身体中充满了力量。')
OBJECT_DESC[OBJECT_TYPE.ANCIENT_RUINS] = _('一群僧侣正在上古遗迹中进行仪式。见你走近, 其中一名僧侣小声告诉你, 只要你捐献20个金龙币, 他们便赐予你一件宝物。')
OBJECT_DESC[OBJECT_TYPE.ENTRANCE_DOOR] = _('你能感觉到一个一场强大的生物驻守在这里, 阻挡着你继续前进, 但想要前往下一关卡必须击败它。')


local OBJECT_HOLD_DESC = {}
OBJECT_HOLD_DESC[OBJECT_TYPE.START_AIRSHIP] = _('手下向你汇报, 飞艇一切准备就绪, "长官希望前往何处?"')
OBJECT_HOLD_DESC[OBJECT_TYPE.WOODCUTTER] = _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!')
OBJECT_HOLD_DESC[OBJECT_TYPE.QUARRIER] = _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!')
OBJECT_HOLD_DESC[OBJECT_TYPE.MINER] = _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!')
OBJECT_HOLD_DESC[OBJECT_TYPE.FARMER] = _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!')
OBJECT_HOLD_DESC[OBJECT_TYPE.CAMP] = _('你看到营地有火光, 走到近前却是空空荡荡。你感觉纳闷, 这里怎么如此眼熟')
OBJECT_HOLD_DESC[OBJECT_TYPE.CRASHED_AIRSHIP] = _('一艘飞艇的残骸, 可惜里面的物资早已被人洗劫一空')
OBJECT_HOLD_DESC[OBJECT_TYPE.CONSTRUCTION_RUINS] = _('你又花费了数小时搜索建筑废墟, 却一无所获')
OBJECT_HOLD_DESC[OBJECT_TYPE.KEEL] = _('"我已经把一切都给了你, "虚空中灵魂道, "你还是快走吧!"')
OBJECT_HOLD_DESC[OBJECT_TYPE.WARRIORS_TOMB] = _('陵墓之中仿佛有几个人形虚影正在向你招手, 你不禁背心一凉, 还是赶紧离开吧')
OBJECT_HOLD_DESC[OBJECT_TYPE.OBELISK] = OBJECT_DESC[OBJECT_TYPE.OBELISK]
OBJECT_HOLD_DESC[OBJECT_TYPE.ANCIENT_RUINS] = _('你还想进入上古遗迹, 一名僧侣却拦住了你说道, "我们正在祈福, 无关人等还是赶紧离开!"')
OBJECT_HOLD_DESC[OBJECT_TYPE.ENTRANCE_DOOR] = _('在没有什么能阻挡你前进了, 你可以直接前往下一个关卡')


local OBJECT_TITLE = {}
OBJECT_TITLE[OBJECT_TYPE.START_AIRSHIP] = _('飞艇')
OBJECT_TITLE[OBJECT_TYPE.WOODCUTTER] = _('废弃的木工小屋')
OBJECT_TITLE[OBJECT_TYPE.QUARRIER] = _('废弃的石匠小屋')
OBJECT_TITLE[OBJECT_TYPE.MINER] = _('废弃的矿工小屋')
OBJECT_TITLE[OBJECT_TYPE.FARMER] = _('废弃的农夫小屋')
OBJECT_TITLE[OBJECT_TYPE.CAMP] = _('野外营地')
OBJECT_TITLE[OBJECT_TYPE.CRASHED_AIRSHIP] = _('坠毁的飞艇')
OBJECT_TITLE[OBJECT_TYPE.CONSTRUCTION_RUINS] = _('建筑废墟')
OBJECT_TITLE[OBJECT_TYPE.KEEL] = _('龙骨')
OBJECT_TITLE[OBJECT_TYPE.WARRIORS_TOMB] = _('勇士之墓')
OBJECT_TITLE[OBJECT_TYPE.OBELISK] = _('方尖碑')
OBJECT_TITLE[OBJECT_TYPE.ANCIENT_RUINS] = _('上古遗迹')
OBJECT_TITLE[OBJECT_TYPE.ENTRANCE_DOOR] = _('异界之门')

local OBJECT_OP = {}
OBJECT_OP[OBJECT_TYPE.START_AIRSHIP] = { {label = _("传送")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.WOODCUTTER] = { {label = _("进攻")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.QUARRIER] = { {label = _("进攻")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.MINER] = { {label = _("进攻")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.FARMER] = { {label = _("进攻")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.CAMP] = { {label = _("进攻")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.CRASHED_AIRSHIP] = { {label = _("进攻")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.CONSTRUCTION_RUINS] = { {label = _("搜索")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.KEEL] = { {label = _("知识")}, {label = _("生命")} }
OBJECT_OP[OBJECT_TYPE.WARRIORS_TOMB] = { {label = _("安葬")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.OBELISK] = { {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.ANCIENT_RUINS] = { {label = _("捐献")}, {label = _("离开")} }
OBJECT_OP[OBJECT_TYPE.ENTRANCE_DOOR] = { {label = _("进攻")}, {label = _("离开")} }

local OBJECT_HOLD_OP = {}
OBJECT_HOLD_OP[OBJECT_TYPE.START_AIRSHIP] = { {label = _("传送")}, {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.WOODCUTTER] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.QUARRIER] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.MINER] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.FARMER] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.CAMP] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.CRASHED_AIRSHIP] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.CONSTRUCTION_RUINS] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.KEEL] = { {label = _("生命")} }
OBJECT_HOLD_OP[OBJECT_TYPE.WARRIORS_TOMB] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.OBELISK] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.ANCIENT_RUINS] = { {label = _("离开")} }
OBJECT_HOLD_OP[OBJECT_TYPE.ENTRANCE_DOOR] = { {label = _("传送")}, {label = _("离开")} }



return {
    object_type = OBJECT_TYPE,
    object_image = OBJECT_IMAGE,
    object_desc = OBJECT_DESC,
    object_hold_desc = OBJECT_HOLD_DESC,
    object_title = OBJECT_TITLE,
    object_op = OBJECT_OP,
    object_hold_op = OBJECT_HOLD_OP,
}

