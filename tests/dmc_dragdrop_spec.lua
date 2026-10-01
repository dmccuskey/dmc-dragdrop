--====================================================================--
-- tests/dmc_dragdrop_spec.lua
--
-- unit tests for dmc_dragdrop, with a stand-in display, stage and transition
-- run with tests/run_unit.sh
--====================================================================--


module( ..., package.seeall )


--====================================================================--
--== Setup

-- stand-in display objects: one metatable, as in Solar2D;
-- a group has x, y and a scale, its children are placed in it

local methods = {}
local META = {}
META.__index = function( t, k )
	if k=='contentBounds' then
		if rawget( t, 'removed' ) then return nil end
		local cx, cy, s = t.parent:localToContent( t.x, t.y )
		local hw, hh = ( t.width or 0 )*s/2, ( t.height or 0 )*s/2
		return { xMin=cx-hw, xMax=cx+hw, yMin=cy-hh, yMax=cy+hh }
	end
	return methods[k]
end

local function newObject( parent, props )
	local o = setmetatable( { x=0, y=0, xScale=1, parent=parent, listeners={} }, META )
	for k, v in pairs( props or {} ) do o[k] = v end
	return o
end

-- content position (and scale) of a point given in this group
function methods:localToContent( x, y )
	if not self.parent then return x, y, 1 end
	local px, py, ps = self.parent:localToContent( self.x, self.y )
	local s = ps*self.xScale
	return px + x*s, py + y*s, s
end
function methods:contentToLocal( x, y )
	local cx, cy, s = self:localToContent( 0, 0 )
	return ( x-cx )/s, ( y-cy )/s
end
function methods:setFillColor( ... ) self.fill = { ... } end
function methods:setStrokeColor( ... ) self.stroke = { ... } end
function methods:addEventListener( name, l ) self.listeners[name] = l end
function methods:removeEventListener( name, l )
	if self.listeners[name]==l then self.listeners[name] = nil end
end
function methods:removeSelf() self.removed = true end
function methods:insert( o ) o.parent = self end

local stage = newObject( nil )
local focus -- calls to stage:setFocus(), with their argument count
function stage:setFocus( ... ) focus[#focus+1] = { n=select( '#', ... ), ... } end

_G.display = {
	getCurrentStage=function() return stage end,
	newGroup=function() return newObject( stage ) end,
	newRect=function( x, y, w, h ) return newObject( stage, { x=x, y=y, width=w, height=h } ) end,
}

local transitions -- calls to transition.to()
_G.transition = {
	to=function( o, params ) transitions[#transitions+1] = { o=o, params=params } end,
}

-- the boot and dmc_objects set their own globals; snapshot after them
pcall( function() require( 'dmc_corona_boot' ) end )
require 'dmc_objects'
local globals = {}
for k in pairs( _G ) do globals[k] = true end

local DragMgr = require 'dmc_corona.dmc_dragdrop'

local events, registered

-- a drop target, 100 x 100, centred on x, y, recording its events
local function newTarget( name, x, y, accept, parent )
	local t = newObject( parent or stage, { x=x, y=y, width=100, height=100, name=name } )
	local function record( kind )
		return function( e ) events[#events+1] = name .. ':' .. kind end
	end
	local h = {
		dragStart=record( 'start' ), dragOver=record( 'over' ), dragExit=record( 'exit' ),
		dragDrop=record( 'drop' ), dragStop=record( 'stop' ),
	}
	h.dragEnter = function( e )
		events[#events+1] = name .. ':enter'
		if accept then DragMgr:acceptDragDrop() end
	end
	DragMgr:register( t, h )
	registered[#registered+1] = t
	return t, h
end

-- start a drag from an initiator at 0, 0; returns a function
-- sending touch phases to the proxy
local function drag( id, options )
	local origin = newObject( stage, { x=0, y=0, width=40, height=40 } )
	DragMgr:doDrag( origin, { name='touch', phase='began', id=id, x=0, y=0 }, options )
	local proxy
	for p, info in pairs( DragMgr._drag_targets ) do
		if info.origin==origin then proxy = p end
	end
	return function( phase, x, y )
		return proxy.listeners.touch:touch{ name='touch', phase=phase, id=id, x=x, y=y, target=proxy }
	end, proxy, origin
end

local function joined() return table.concat( events, ' ' ) end

function setup()
	events, registered, focus, transitions = {}, {}, {}, {}
end

function teardown()
	for _, t in ipairs( registered ) do DragMgr:unregister( t ) end
	DragMgr._drag_targets = {}
end


--====================================================================--
--== Tests

function test_loadSetsNoGlobals()
	for k in pairs( _G ) do
		assert_true( globals[k] or k=='dmc_dragdrop_spec', 'new global: ' .. tostring( k ) )
	end
	assert_equal( '0.6.0', DragMgr.VERSION )
end

function test_acceptedDrag()
	newTarget( 'A', 200, 200, true )
	local touch, proxy = drag( 'T1' )
	assert_equal( 0.5, proxy.alpha )
	assert_equal( proxy, focus[1][1] ) ; assert_equal( 'T1', focus[1][2] )
	touch( 'moved', 190, 210 ) ; touch( 'moved', 200, 200 )
	assert_equal( 200, proxy.x ) ; assert_equal( 200, proxy.y )
	touch( 'moved', 400, 400 ) ; touch( 'moved', 200, 200 )
	assert_true( touch( 'ended', 200, 200 ) )
	assert_equal( 'A:start A:enter A:over A:exit A:enter A:drop A:stop', joined() )
	-- focus released for this touch only
	assert_equal( proxy, focus[2][1] ) ; assert_equal( 2, focus[2].n ) ; assert_nil( focus[2][2] )
	-- proxy shrinks onto the target, then is removed
	local t = transitions[1].params
	assert_equal( 200, t.x ) ; assert_equal( 200, t.y ) ; assert_equal( 10, t.width )
	assert_equal( DragMgr.ANIMATE_TIME_FAST, t.time )
	assert_nil( proxy.listeners.touch )
	t.onComplete()
	assert_true( proxy.removed )
	assert_nil( DragMgr._drag_targets[ proxy ] )
end

function test_notAcceptedDragGoesBack()
	newTarget( 'A', 200, 200, false )
	local touch = drag( 'T1' )
	touch( 'moved', 200, 200 ) ; touch( 'moved', 210, 200 ) ; touch( 'ended', 210, 200 )
	assert_equal( 'A:start A:enter A:stop', joined() )
	local t = transitions[1].params
	assert_equal( 0, t.x ) ; assert_equal( 0, t.y ) ; assert_nil( t.width )
	assert_equal( DragMgr.ANIMATE_TIME_SLOW, t.time )
end

-- the important bug: unregistering the target under the drag
function test_unregisterTargetUnderDrag()
	local a = newTarget( 'A', 200, 200, true )
	local touch, proxy = drag( 'T1' )
	touch( 'moved', 200, 200 )
	DragMgr:unregister( a )
	touch( 'moved', 205, 200 ) ; touch( 'ended', 205, 200 )
	assert_equal( 'A:start A:enter', joined() )
	assert_equal( 0, transitions[1].params.x ) -- back to the origin
	assert_nil( focus[2][2] ) ; assert_equal( 2, focus[2].n )
end

function test_unregisterInDragEnter()
	local a, h = newTarget( 'A', 200, 200, true )
	h.dragEnter = function() events[#events+1] = 'A:enter' ; DragMgr:acceptDragDrop() ; DragMgr:unregister( a ) end
	DragMgr:register( a, h )
	local touch = drag( 'T1' )
	touch( 'moved', 200, 200 ) ; touch( 'moved', 205, 200 ) ; touch( 'ended', 205, 200 )
	assert_equal( 'A:start A:enter', joined() )
end

function test_twoDragsAtOnce()
	newTarget( 'A', 200, 200, true )
	newTarget( 'B', 500, 200, false )
	local t1, p1 = drag( 'T1' )
	local t2, p2 = drag( 'T2' )
	assert_not_equal( p1, p2 )
	t1( 'moved', 200, 200 ) ; t2( 'moved', 500, 200 )
	t1( 'moved', 201, 200 ) ; t2( 'moved', 501, 200 )
	t2( 'ended', 501, 200 )
	t1( 'ended', 201, 200 )
	assert_equal( 'A:start B:start A:start B:start A:enter B:enter A:over A:stop B:stop A:drop A:stop B:stop', joined() )
	-- the drag on B went back, the one on A shrank onto it
	assert_equal( 0, transitions[1].params.x ) ; assert_nil( transitions[1].params.width )
	assert_equal( 200, transitions[2].params.x ) ; assert_equal( 10, transitions[2].params.width )
end

function test_acceptOutsideAnEventDoesNothing()
	newTarget( 'A', 200, 200, false )
	local touch = drag( 'T1' )
	touch( 'moved', 200, 200 )
	DragMgr:acceptDragDrop()
	touch( 'moved', 201, 200 ) ; touch( 'ended', 201, 200 )
	assert_equal( 'A:start A:enter A:stop', joined() )
end

function test_endAnimationInMovedScaledGroup()
	local g = display.newGroup()
	g.x, g.y, g.xScale = 100, 50, 2
	newTarget( 'A', 50, 50, true, g ) -- content centre 200, 150
	local pg = display.newGroup()
	pg.x, pg.y = 10, 20
	local proxy = newObject( pg, { width=20, height=20 } )
	local touch = drag( 'T1', { proxy=proxy } )
	touch( 'moved', 200, 150 )
	assert_equal( 190, proxy.x ) ; assert_equal( 130, proxy.y ) -- in its group
	touch( 'ended', 200, 150 )
	local t = transitions[1].params
	assert_equal( 190, t.x ) ; assert_equal( 130, t.y )
end

function test_registerTwiceReplaces()
	local a = newTarget( 'A', 200, 200, true )
	DragMgr:register( a, { dragStart=function() events[#events+1] = 'A2:start' end } )
	local touch = drag( 'T1' )
	touch( 'ended', 0, 0 )
	assert_equal( 'A2:start', joined() )
end

function test_proxyColorsAndTimes()
	local fill, stroke = { 1, 0, 0 }, { 0, 1, 0 }
	local touch, proxy = drag( 'T1', { fillColor=fill, strokeColor=stroke, strokeWidth=7, alpha=0.8 } )
	assert_equal( 1, proxy.fill[1] ) ; assert_equal( 1, proxy.stroke[2] ) ; assert_equal( 7, proxy.strokeWidth )
	assert_equal( 0.8, proxy.alpha ) ; assert_equal( 40, proxy.width )
	DragMgr.ANIMATE_TIME_SLOW = 999
	touch( 'ended', 0, 0 )
	DragMgr.ANIMATE_TIME_SLOW = nil
	assert_equal( 999, transitions[1].params.time )
	assert_equal( 300, DragMgr.ANIMATE_TIME_SLOW )
end

function test_targetWithViewAndWithout()
	local view = newObject( stage, { x=200, y=200, width=100, height=100 } )
	local obj = { view=view, dragEnter=function( self, e ) events[#events+1] = 'O:enter' end }
	DragMgr:register( obj )
	registered[#registered+1] = obj
	local bare = { dragEnter=function() events[#events+1] = 'bare:enter' end }
	DragMgr:register( bare )
	registered[#registered+1] = bare
	local touch = drag( 'T1' )
	touch( 'moved', 200, 200 ) ; touch( 'moved', 201, 200 ) ; touch( 'ended', 201, 200 )
	assert_equal( 'O:enter', joined() )
end

function test_unregisterInDragStop()
	local a, h = newTarget( 'A', 200, 200, false )
	h.dragStop = function() events[#events+1] = 'A:stop' ; DragMgr:unregister( a ) end
	DragMgr:register( a, h )
	newTarget( 'B', 500, 200, false )
	local touch = drag( 'T1' )
	touch( 'ended', 0, 0 )
	assert_equal( 'A:start B:start A:stop B:stop', joined() )
end

function test_focusWithoutTouchId()
	local touch, proxy = drag( nil )
	assert_equal( proxy, focus[1][1] ) ; assert_equal( 1, focus[1].n )
	touch( 'ended', 0, 0 )
	assert_nil( focus[2][1] ) ; assert_equal( 1, focus[2].n )
end
