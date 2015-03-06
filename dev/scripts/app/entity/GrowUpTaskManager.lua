local GrowUpTasks = GameDatas.GrowUpTasks
local GrowUpTaskManager = class("GrowUpTaskManager")

local m = {}
m.__index = m
function m:hello()
end

function GrowUpTaskManager:ctor()
    self.task_map = {}
    for k,v in pairs(GameDatas.GrowUpTasks) do
        self.task_map[k] = {}
    end
end

function GrowUpTaskManager:OnUserDataChanged(userData)
    if not userData.growUpTasks then return end
    local growUpTasks = userData.growUpTasks
    for k,v in pairs(self.task_map) do
        local all_tasks = growUpTasks[k]
        local diff_tasks = growUpTasks[string.format("__%s", k)]
        if all_tasks then
            self.task_map[k] = all_tasks
        elseif diff_tasks then
            local task = self.task_map[k]
            for i,v in ipairs(diff_tasks) do
                local type_ = v.type
                local data = v.data
                if type_ == "add" then
                    table.insert(task, data)
                elseif type_ == "remove" then
                    for i,v in ipairs(task) do
                        if v.id == data.id then
                            table.remove(task, i)
                            break
                        end
                    end
                elseif type_ == "edit" then
                    for i,v in ipairs(task) do
                        if v.id == data.id then
                            task[i] = data
                            break
                        end
                    end
                end
            end
        end
    end
    LuaUtils:outputTable("self.task_map", self.task_map)
end



return GrowUpTaskManager

