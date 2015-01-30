--====================================================================--
-- DragDrop OOP
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
--====================================================================--



print( '\n\n##############################################\n\n' )



--===================================================================--
--== Imports


local DragMgr = require 'dmc_corona.dmc_dragdrop'
local DropTarget = require 'drop_target'



--===================================================================--
--== Setup, Constants


display.setStatusBar( display.HiddenStatusBar )



--====================================================================--
--== Support Functions


-- createSquare()
--
-- function to help create shapes, useful for drag/drop target examples
--
local function createSquare( params )
	params = params or {}
	if params.fillColor==nil then params.fillColor=DragMgr.COLOR_LIGHTGREY end
	if params.strokeColor==nil then params.strokeColor=DragMgr.COLOR_GREY end
	if params.strokeWidth==nil then params.strokeWidth=3 end
	--==--
	local o = display.newRect(0, 0, params.width, params.height )
	o.strokeWidth = params.strokeWidth
	o:setFillColor( unpack( params.fillColor ) )
	o:setStrokeColor( unpack( params.strokeColor ) )
	return o
end


local function setupBackground()

	local o

	localGroup = display.newGroup()

	-- background
	o = display.newImageRect( "assets/bg_screen_generic.png", 320, 480 )
	o.anchorX, o.anchorY = 0, 0
	o.x=0 ; o.y=0
	localGroup:insert( o )
end



--====================================================================--
--== Main
--====================================================================--


setupBackground()




--======================================================--
-- START: Setup DROP Targets - areas we drag TO

local dropTarget2, dropTarget3, dropTarget4


--== Setup Drop Targets, using object-oriented code ==--
-- For details, see the file 'drop_target.lua'


-- this one, Blue, accepts only Blue drag notifications

dropTarget2 = DropTarget:new{
	format={ 'blue' },
	color=DragMgr.COLOR_LIGHTBLUE
}
dropTarget2.x, dropTarget2.y = 80, 240

DragMgr:register( dropTarget2 )


-- this one, Grey, accepts both Blue and Red drag notifications

dropTarget3 = DropTarget:new{
	format={ 'blue', 'red' },
	color=DragMgr.COLOR_LIGHTGREY
}
dropTarget3.x, dropTarget3.y = 160, 110

DragMgr:register( dropTarget3 )


-- this one, Light Red, accepts only Red drag notifications

dropTarget4 = DropTarget:new{
	format='red',
	color=DragMgr.COLOR_LIGHTRED
}
dropTarget4.x, dropTarget4.y = 240, 240

DragMgr:register( dropTarget4 )

-- END: Setup DROP Targets - areas we drag TO
--======================================================--






--======================================================--
-- START: Setup DRAG Targets - areas we drag FROM

local Y_BASE = 400
local dragItem, dragItemTouchHandler
local dragItem2, dragItem2TouchHandler


--== create Red Drag Target ==--

dragItemTouchHandler = function( event )

	if event.phase=='began' then

		local target = event.target

		local custom_proxy = createSquare{
			width=75, height=75,
			fillColor=DragMgr.COLOR_LIGHTRED,
			strokeColor=DragMgr.COLOR_GREY,
			strokeWidth=2
		}

		-- setup info about the drag operation
		local drag_info = {
			proxy = custom_proxy,
			format = 'red',
			yOffset = -30,
		}

		-- now tell the Drag Manager about it
		DragMgr:doDrag( target, event, drag_info )
	end

	return true
end

-- this is the drag target, the location from which we start a drag
dragItem = createSquare{
	width=75, height=75,
	fillColor=DragMgr.COLOR_LIGHTRED,
	strokeColor=DragMgr.COLOR_GREY,
	strokeWidth=3
}
dragItem.x, dragItem.y = 80, Y_BASE

dragItem:addEventListener( 'touch', dragItemTouchHandler )



--== create Blue Drag Target ==--

dragItem2TouchHandler = function( event )

	if event.phase == 'began' then

		local target = event.target

		local custom_proxy = createSquare{
			width=75, height=75,
			fillColor=DragMgr.COLOR_LIGHTBLUE,
			strokeColor=DragMgr.COLOR_GREY,
			strokeWidth=2
		}

		-- setup info about the drag operation
		local drag_info = {
			proxy = custom_proxy,
			format = 'blue',
			yOffset = -30,
		}

		-- now tell the Drag Manager about it
		DragMgr:doDrag( target, event, drag_info )
	end

	return true
end

-- this is the drag target, the location from which we start a drag
dragItem2 = createSquare{
	width=75, height=75,
	fillColor=DragMgr.COLOR_LIGHTBLUE,
	strokeColor=DragMgr.COLOR_GREY,
	strokeWidth=3
}

dragItem2.x, dragItem2.y = 240, Y_BASE

dragItem2:addEventListener( 'touch', dragItem2TouchHandler )

-- END: Setup DRAG Targets - areas we drag FROM
--======================================================--






