local Game = require("Game")
local property = import("app.utils.property")
local AllianceMember = import("app.entity.AllianceMember")
local Alliance = import("app.entity.Alliance")


module( "test_alliance", lunit.testcase, package.seeall )
function test_alliance_basic()
    local alliance = Alliance.new("联盟id", "联盟名字")
    alliance:AddListenOnType({
        OnBasicChanged = function(this, alliance, changed_map)
            if changed_map.aliasName ~= nil then
                assert_equal("abc", changed_map.aliasName.new)
            end
            if changed_map.defaultLanguage ~= nil then
                assert_equal("eng", changed_map.defaultLanguage.new)
                assert_equal("all", changed_map.defaultLanguage.old)
            end
        end},
    Alliance.LISTEN_TYPE.BASIC)
    assert_equal("联盟名字", alliance:Name())
    assert_false(alliance:IsDefault())
    alliance:SetAliasName("abc")
    assert_equal("abc", alliance:AliasName())
    alliance:SetDefaultLanguage("eng")
    assert_equal("eng", alliance:DefaultLanguage())
    assert_equal(0, alliance:Power())
    assert_equal(0, alliance:Exp())
    alliance:Flag():RandomFlag()
end

function test_alliance_member()
    local alliance = Alliance.new("联盟id")
    local l1 = {
        OnMemberChanged = function(this, alliance, changed_map)
            if #changed_map.added > 0 then
                assert_equal("aaa", changed_map.added[1]:Id())
            elseif #changed_map.removed > 0 then
                assert_equal("aaa", changed_map.removed[1]:Id())
            end
        end}
    local l2 = {
        OnMemberChanged = function(this, alliance, changed_map)
            if #changed_map.added > 0 then
                assert_equal("bbb", changed_map.added[1]:Id())
            elseif #changed_map.removed > 0 then
                assert_equal("bbb", changed_map.removed[1]:Id())
            end
        end}
    alliance:AddListenOnType(l1, Alliance.LISTEN_TYPE.MEMBER)
    assert_false(alliance:IsDefault())
    alliance:AddMembersWithNotify(AllianceMember.new("aaa"))

    alliance:RemoveAllListenerOnType(Alliance.LISTEN_TYPE.MEMBER)
    alliance:AddListenOnType(l2, Alliance.LISTEN_TYPE.MEMBER)
    alliance:AddMembersWithNotify(AllianceMember.new("bbb"))
    alliance:RemoveMemberByIdWithNotify("bbb")

    alliance:RemoveAllListenerOnType(Alliance.LISTEN_TYPE.MEMBER)
    alliance:AddListenOnType(l1, Alliance.LISTEN_TYPE.MEMBER)

    alliance:RemoveMemberByIdWithNotify("aaa")
    assert_true(alliance:IsDefault())
end

function test_alliance_events()
    local alliance = Alliance.new("联盟id")
    local l1 = {
        OnEventsChanged = function(this, alliance, changed_map)
            -- dump(changed_map)	
        end}
    alliance:AddListenOnType(l1, Alliance.LISTEN_TYPE.EVENTS)
    assert_false(alliance:IsDefault())

    assert_equal(0, #alliance:GetEvents())
    assert_equal(nil, alliance:GetEventByIndex(1))
    alliance:PushEventInHeadWithNotify(alliance:CreateEvent("key1", "event_type", "category", "time", "params"))
	alliance:PushEventInHeadWithNotify(alliance:CreateEvent("key", "event_type", "category", "time", "params"))
	assert_equal("key", alliance:GetEventByIndex(1).key)
	assert_equal("key1", alliance:GetEventByIndex(2).key)
	alliance:PopLastEventWithNotify()
end







