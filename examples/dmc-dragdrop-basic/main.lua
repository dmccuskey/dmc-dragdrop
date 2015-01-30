--====================================================================--
-- DragDrop Basic
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
--====================================================================--



print( '\n\n##############################################\n\n' )



--===================================================================--
--== Imports


local DragMgr = require 'dmc_corona.dmc_dragdrop'



--===================================================================--
--== Setup, Constants


display.setStatusBar( display.HiddenStatusBar )

local COLOR_BLUE = { 25/255, 100/255, 255/255 }
local COLOR_LIGHTBLUE = { 90/255, 170/255, 255/255 }
local COLOR_GREEN = { 50/255, 255/255, 50/255 }
local COLOR_LIGHTGREEN = { 170/255, 225/255, 170/255 }
local COLOR_RED = { 255/255, 50/255, 50/255 }
local COLOR_LIGHTRED = { 255/255, 120/255, 120/255 }
local COLOR_GREY = { 180/255, 180/255, 180/255 }
local COLOR_LIGHTGREY = { 200/255, 200/255, 200/255 }



-- forward declares
local dragExitHandler

local localGroup



--====================================================================--
--== Support Functions


-- createSquare()
--
-- function to help create shapes, useful for drag/drop target examples
--
local function createSquare( params )
	params = params or {}
	if params.fillColor==nil then params.fillColor=COLOR_LIGHTGREY end
	if params.strokeColor==nil then params.strokeColor=COLOR_GREY end
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
-- START: Setup DROP Target - areas we drag TO

-- forward declares
local theScore =  0
local textScore, updateScore


-- dragStartHandler
--
local dragStartHandler = function( e )

	local target = e.target
	target:setStrokeColor( unpack( COLOR_RED ) )

	return true
end


-- dragEnterHandler
--
local dragEnterHandler = function( e )

	local target = e.target
	target:setFillColor( unpack( COLOR_LIGHTGREEN ) )

	DragMgr:acceptDragDrop()

	return true
end


-- dragOverHandler
--
local dragOverHandler = function( e )
	-- pass
	return true
end


-- dragDropHandler
--
local dragDropHandler = function( e )

	theScore = theScore + 1
	updateScore()
	dragExitHandler( e )

	return true
end


-- dragExitHandler
--
dragExitHandler = function( e )

	local target = e.target
	target:setFillColor( unpack( COLOR_LIGHTBLUE ) )

	return true
end


-- dragStopHandler
--
local dragStopHandler = function( e )

	local target = e.target
	target:setStrokeColor( unpack( COLOR_GREY ) )

	return true
end


-- create our drop target
-- note that it's just a regular Corona object
--
local dropTarget = createSquare{
	width=125, height=125,
	fillColor=COLOR_LIGHTBLUE,
	strokeColor=COLOR_GREY,
	strokeWidth=2
}
dropTarget.x, dropTarget.y = 160, 200

DragMgr:register( dropTarget, {
	dragStart=dragStartHandler,
	dragEnter=dragEnterHandler,
	dragOver=dragOverHandler,
	dragDrop=dragDropHandler,
	dragExit=dragExitHandler,
	dragStop=dragStopHandler,
})

updateScore = function()
	textScore.text = tostring( theScore )
	textScore.x = 160 ; textScore.y = 200
end

textScore = display.newText( "", 160, 160, native.systemFont, 24 )
textScore:setTextColor( 0, 0, 0, 255 )
textScore.anchorX, textScore.anchorY = 0.5, 0.5

updateScore()

-- END: Setup DROP Target - areas we drag TO
--======================================================--



--======================================================--
-- START: Setup DRAG Target - areas we drag FROM

local function dragItemTouchHandler( event )

	if event.phase == 'began' then
		-- now tell the Drag Manager about it
		DragMgr:doDrag( event.target, event )
	end

	return true
end


-- this is the Drag Initiator
-- ie, the location from which we start a drag
--
local dragItem = createSquare{
	width=75, height=75,
	fillColor=COLOR_LIGHTBLUE,
	strokeColor=COLOR_GREY,
	strokeWidth=2
}
dragItem.x, dragItem.y = 160, 400

dragItem:addEventListener( 'touch', dragItemTouchHandler )

-- END: Setup DRAG Target - areas we drag FROM
--======================================================--




--== Unregister Drop Target after 10 seconds
--
timer.performWithDelay( 10000, function()
	print( "Unregistering drop target" )
	DragMgr:unregister( dropTarget )
end)


