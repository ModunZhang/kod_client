--
-- Author: Danny He
-- Date: 2014-10-07 15:07:59
--

local my_filter  = filter
local UIButton = require("framework.cc.ui.UIButton")
local UIPushButton = cc.ui.UIPushButton
local WidgetPushButton = import(".WidgetPushButton")
local WidgetSequenceButton = class("WidgetSequenceButton",WidgetPushButton)

-- images, options, filters 参数同WidgetPushButton

function WidgetSequenceButton:ctor(images,options,seqImages,seqFilters,initial_state)
	assert(initial_state)
	self.seqImages_ = {}
	self.seqsprite_ = {}
	self.seqFilter_ = {}
	self.isImageState = false
	self.scale_ = options and options.scale or 1.0
	if type(seqImages) == 'table' then
		local events = {}
	    -- image Sequence
		local countOfimages = #seqImages
		if countOfimages > 1 then
			self.isImageState = true
			for i,v in ipairs(seqImages) do
				local event = {}
				if i == 1 then
					event = {
						name = v.name,
						from = seqImages[countOfimages].name,
						to   = seqImages[1].name,
						image = v.image
					}
				elseif i == countOfimages then
					event = {
						name = v.name,
						from = seqImages[countOfimages - 1].name,
						to   = seqImages[i].name,
						image = v.image
					}
				else
					event = {
						name = v.name,
						from = seqImages[i-1].name,
						to   = seqImages[i].name,
						image = v.image,
					}
				end
				table.insert(events,event)
			end
			self.events_ = events
			-- dump(events)


			self.fsm_seq_ = {}
			cc(self.fsm_seq_)
		    	:addComponent("components.behavior.StateMachine")
		    	:exportMethods()
		    self.fsm_seq_:setupState({
		        initial = {state = initial_state and initial_state or self:getCurrentEvent().name, event = "startup", defer = false},
		        events = events,
		        callbacks = {
		            onchangestate = handler(self, self.onSeqStateChange_),
		        }
		    })
			for i,v in ipairs(events) do
				self:setButtonSeqImage(v.name,v.image,true)
			end
			self:addNodeEventListener(cc.NODE_EVENT, function(event)
		        if event.name == "enter" then
		            self:updateSeqButtonImage_()
		        end
	    	end)
		    self:setSeqState(initial_state and initial_state or self:getCurrentEvent().name)
	    elseif countOfimages == 1 and seqFilters then
	    	local countOfFilters = #seqFilters
	    	for i,v in ipairs(seqFilters) do
	    		local event = {}
	    		if i == 1 then
	    			event = {
						name = v.name,
						from = seqFilters[countOfFilters].name,
						to   = seqFilters[1].name,
						color = v.color
					}
				elseif i == countOfFilters then
					event = {
						name = v.name,
						from = seqFilters[countOfFilters - 1].name,
						to   = seqFilters[i].name,
						color = v.color
					}
				else
					event = {
						name = v.name,
						from = seqFilters[i-1].name,
						to   = seqFilters[i].name,
						color = v.color,
					}
	    		end
	    		table.insert(events,event)
	    	end
	    	-- dump(events)
	    	self.events_ = events
	    	self.fsm_seq_ = {}
			cc(self.fsm_seq_)
		    	:addComponent("components.behavior.StateMachine")
		    	:exportMethods()
		    self.fsm_seq_:setupState({
		        initial = {state = initial_state and initial_state or self:getCurrentEvent().name, event = "startup", defer = false},
		        events = events,
		        callbacks = {
		            onchangestate = handler(self, self.onSeqStateChange_),
		        }
		    })
	    	for i,v in ipairs(events) do
	    		self:setButtonFilter(v.name,v.color,true)
	    	end
	    	self:addNodeEventListener(cc.NODE_EVENT, function(event)
		        if event.name == "enter" then
		            self:updateSeqButtonImage_(seqImages[1].image)
		        end
	    	end)
	    	self:setSeqState(initial_state and initial_state or self:getCurrentEvent().name)
		end
	end
	-- call super	
	WidgetSequenceButton.super.ctor(self,images, options, {disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}})
	self:onButtonClicked(handler(self, self.onButtonClicked_))
end

function WidgetSequenceButton:setSeqState( state )
	local indexOfState = -1
	for i,v in ipairs(self.events_) do
	 	if v.name == state then
	 		indexOfState = i
	 		break
	 	end
	 end
	 if indexOfState > 0 then
	 	print("WidgetSequenceButton:setSeqState------>",state,indexOfState)
	 	if self.fsm_seq_:canDoEvent(state) then
	 		self.fsm_seq_:doEvent(state)
	 		self.indexOfEvent_ = indexOfState
	 	else
	 		self.fsm_seq_:doEventForce(state)
	 		self.indexOfEvent_ = indexOfState
	 	end
	 	print(self.fsm_seq_:getState())
	 end
end

function WidgetSequenceButton:setButtonFilter(state,color,ignoreEmpty)
	 if ignoreEmpty and color == nil then return end
	 self.seqFilter_[state] = color
end

function WidgetSequenceButton:setButtonSeqImage(state, image, ignoreEmpty)
    if ignoreEmpty and image == nil then return end
    self.seqImages_[state] = image
    if state == self.fsm_seq_:getState() then
        self:updateSeqButtonImage_()
    end
    return self
end

function WidgetSequenceButton:GetSeqState()
	return self.fsm_seq_:getState()
end

function WidgetSequenceButton:onSeqStateChange_()
	if self:isRunning() then
		if self.isImageState then
        	self:updateSeqButtonImage_()
        else
        	self:updateSeqButtonImage_(self.currentSeqImage_)
        end
    end
end

function WidgetSequenceButton:align(align, x, y)
	WidgetSequenceButton.super.align(self,align, x, y)
	self:updateSeqButtonImage_()
    return self
end


function WidgetSequenceButton:updateSeqButtonImage_(oneImage)
	print("updateSeqButtonImage_---->")
	if not oneImage then
		local state = self.fsm_seq_:getState()
	    local image = self.seqImages_[state]
		print("state----->",state,self.scale9_)

	    if image then
	        if self.currentSeqImage_ ~= image then
	            for i,v in ipairs(self.seqsprite_) do
	                v:removeFromParent(true)
	            end
	            self.seqsprite_ = {}
	            self.currentSeqImage_ = image
				self.seqsprite_[1] = display.newSprite(image)
	            if self.seqsprite_[1].setFlippedX then
	                self.seqsprite_[1]:setFlippedX(self.flipX_ or false)
	                self.seqsprite_[1]:setFlippedY(self.flipY_ or false)
	            end
	            self.seqsprite_[1]:setScale(self.scale_)
	            self:addChild(self.seqsprite_[1], UIButton.IMAGE_ZORDER+1)
	        end
	        for i,v in ipairs(self.seqsprite_) do
	            v:setAnchorPoint(self:getAnchorPoint())
	            v:setPosition(0, 0)
	        end
	    end
	else
		local state = self.fsm_seq_:getState()
		print("state----->",state,self.scale9_)
		-- dump(self.seqFilter_)
		local filter = self.seqFilter_[state]
    	local customParams = {frag = "shaders/customer_color.fsh",
					shaderName = state,
					color = filter}
		local params = json.encode(customParams)
        if self.seqsprite_ and self.seqsprite_[1] then
        	self:SetFilterOnSprite(self.seqsprite_[1],{
        		name = "CUSTOM",
	        	params = params
        	})
        else
        	self.seqsprite_ = {}
        	self.currentSeqImage_ = oneImage

			self.seqsprite_[1] =  display.newSprite(oneImage, nil, nil, {class=cc.FilteredSpriteWithOne})
	        if self.seqsprite_[1].setFlippedX then
	            self.seqsprite_[1]:setFlippedX(self.flipX_ or false)
	            self.seqsprite_[1]:setFlippedY(self.flipY_ or false)
	        end
	        self:SetFilterOnSprite(self.seqsprite_[1],{
	        	name = "CUSTOM",
	        	params = params
	        })
	        self.seqsprite_[1]:setScale(self.scale_)
	        self:addChild(self.seqsprite_[1], UIButton.IMAGE_ZORDER+1)
	        for i,v in ipairs(self.seqsprite_) do
	            v:setAnchorPoint(self:getAnchorPoint())
	            v:setPosition(0, 0)
	        end
        end
       
	end
end

function WidgetSequenceButton:onButtonClicked_(event)
		--change state
		if not self.events_ then return end
		local nextEvent = self:getNextEvent().name
    	if self.fsm_seq_:canDoEvent(nextEvent) then 
    		self.fsm_seq_:doEvent(nextEvent)
    	end
end

function WidgetSequenceButton:getCurrentEvent()
	if not self.indexOfEvent_ then
		self.indexOfEvent_ = 1
	end
	return self.events_[self.indexOfEvent_]
end

function WidgetSequenceButton:getNextEvent()
	local index = self.indexOfEvent_
	if index then
		if index >= #self.events_ then
			index = 1
		else
			index = index + 1
		end
	end
	self.indexOfEvent_ = index
	return self:getCurrentEvent()
end


return WidgetSequenceButton