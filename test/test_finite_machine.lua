local Game = require("Game")
local State = import("app.utils.State")
local FiniteMachine = import("app.utils.FiniteMachine")

module( "test_finite_machine", lunit.testcase, package.seeall )


local NewState = class("NewState", state)
function NewState:OnEnter()
	print("OnEnter")
end
function NewState:OnExit()
	print("OnExit")
end
function test_finite_machine()
	local state = NewState.new()
	local finite_machine = FiniteMachine.new({
		["new"] = state
		})

	assert_equal(nil, finite_machine:CurrentState())
	finite_machine:TranslateToSatateByName("new")
	assert_equal("new", finite_machine:CurrentStateName())
	assert_equal(state, finite_machine:CurrentState())

	finite_machine:TranslateToSatateByName("old")
end