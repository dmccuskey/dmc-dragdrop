--====================================================================--
-- OO Drop Target
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
--====================================================================--



--===================================================================--
--== Imports


local DragMgr = require 'dmc_corona.dmc_dragdrop'
local Objects = require 'dmc_corona.dmc_objects'
local Utils = require 'dmc_corona.dmc_utils'



--===================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase



--===================================================================--
--== Support Functions


-- createSquare()
--
-- function to help create shapes, useful for drag/drop target examples
--
local function createSquare( params )
	params = params or {}
	assert( type(params)=='table', "createSquare requires params" )
	assert( params.height and params.width, "createSquare requires height and width" )
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




--====================================================================--
--== Drop Target Class
--====================================================================--


local DropTarget = newClass( ComponentBase, {name="Drop Target"} )


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
-- called by new()
-- one of the base methods to override for dmc_objects
-- here we save params, initialize basic properties, etc
--
function DropTarget:__init__( params )
	-- print( "DropTarget:__init__" )
	self:superCall( '__init__', params )
	params = params or {}
	if params.format == nil then params.format = {} end
	if params.color == nil then params.color = DragMgr.COLOR_LIGHTGREY end
	--==--

	if type(params.format) =='string' then
		params.format = { params.format }
	end

	--== Create Properties ==--

	self._score = 0
	self._format = params.format
	self._color = params.color	-- { 255, 25, 255 }
	self._background = nil
	self._scoreboard = nil

end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
-- here we put on our display properties
--
function DropTarget:__createView__()
	-- print( "DropTarget:__createView__" )
	self:superCall( '__createView__' )
	--==--

	local o

	-- background

	o = createSquare{
		width=120, height=120,
		fillColor=self._color
	}
	o.anchorX, o.anchorY = 0.5, 0.5
	o.x, o.y = 0, 0

	self:insert( o )
	self._background = o

	-- scoreboard

	o = display.newText( "", 0, 0, native.systemFont, 24 )
	o:setTextColor( 0, 0, 0, 255 )
	o.anchorX, o.anchorY = 0.5, 0.5
	o.x, o.y = 0, 0

	self:insert( o )
	self._scoreboard = o

end


-- __initComplete__()
--
-- post init actions
-- base dmc_object override
--
function DropTarget:__initComplete__()
	-- print( "DropTarget:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--

	-- draw initial score
	self:_updateScore()
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


function DropTarget:_incrementScore()
	self._score = self._score + 1
	self:_updateScore()
end

function DropTarget:_updateScore()
	self._scoreboard.text = tostring( self._score )
	self._scoreboard.x, self._scoreboard.y = 0, 0
end



--====================================================================--
--== Event Handlers


--== define method handlers for each drag phase


function DropTarget:dragStart( e )

	local data_format = e.format

	-- loop over the data formats and see if we match
	if Utils.propertyIn( self._format, data_format ) then
		self._background:setStrokeColor( unpack( DragMgr.COLOR_RED ) )
	end

	return true
end
function DropTarget:dragEnter( e )
	-- must accept drag here

	local data_format = e.format

	-- loop over the data formats and see if we match
	if Utils.propertyIn( self._format, data_format ) then
		self._background:setFillColor( unpack( DragMgr.COLOR_LIGHTGREEN ) )
		DragMgr:acceptDragDrop()
	end

	return true
end
function DropTarget:dragOver( e )

	return true
	end
function DropTarget:dragDrop( e )

	self:_incrementScore()
	self:dragExit( e )

	return true
end
function DropTarget:dragExit( e )

	self._background:setFillColor( unpack( self._color ) )

	return true
end
function DropTarget:dragStop( e )

	self._background:setStrokeColor( unpack( DragMgr.COLOR_GREY ) )

	return true
end




return DropTarget

