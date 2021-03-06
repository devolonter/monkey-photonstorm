'/**
 '* FlxCollision
 '* -- Part of the Flixel Power Tools set
 '* 
 '* v1.6 Fixed bug in pixelPerfectCheck that stopped non-square rotated objects from colliding properly (thanks to joon on the flixel forums for spotting)
 '* v1.5 Added createCameraWall
 '* v1.4 Added pixelPerfectPointCheck()
 '* v1.3 Update fixes bug where it wouldn't accurately perform collision on AutoBuffered rotated sprites, or sprites with offsets
 '* v1.2 Updated for the Flixel 2.5 Plugin system
 '* 
 '* @version 1.6 - October 8th 2011
 '* @link http://www.photonstorm.com
 '* @author Richard Davey / Photon Storm
 '* Copyright: Monkey port - 2012 Aleksey 'KaaPex' Kazantsev 
'*/
Strict

Import flixel
Import flxextendedrect
Import flxmath
Import flxextendedcolor
Import monkey.math
	
Class FlxCollision 

	'public static var debug:BitmapData = new BitmapData(1, 1, false);
	
	Global CAMERA_WALL_OUTSIDE:Int = 0
	Global CAMERA_WALL_INSIDE:Int = 1

	'/**
	 '* A Pixel Perfect Collision check between two FlxSprites.
	 '* It will do a bounds check first, and if that passes it will run a pixel perfect match on the intersecting area.
	 '* Works with rotated, scaled and animated sprites.
	 '* 
	 '* @param	contact			The first FlxSprite to test against
	 '* @param	target			The second FlxSprite to test again, sprite order is irrelevant
	 '* @param	alphaTolerance	The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
	 '* @param	camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 '* 
	 '* @return	Boolean True if the sprites collide, false if not
	 '*/
	Function PixelPerfectCheck:Bool(contact:FlxSprite, target:FlxSprite, alphaTolerance:Int = 255, camera:FlxCamera = Null)
		Local pointA:FlxPoint = New FlxPoint()
		Local pointB:FlxPoint = New FlxPoint()
		
		If (camera) Then
			pointA.x = contact.x - Int(camera.scroll.x * contact.scrollFactor.x) - contact.offset.x
			pointA.y = contact.y - Int(camera.scroll.y * contact.scrollFactor.y) - contact.offset.y
			
			pointB.x = target.x - Int(camera.scroll.x * target.scrollFactor.x) - target.offset.x
			pointB.y = target.y - Int(camera.scroll.y * target.scrollFactor.y) - target.offset.y
		Else
			pointA.x = contact.x - Int(FlxG.Camera.scroll.x * contact.scrollFactor.x) - contact.offset.x
			pointA.y = contact.y - Int(FlxG.Camera.scroll.y * contact.scrollFactor.y) - contact.offset.y
			
			pointB.x = target.x - Int(FlxG.Camera.scroll.x * target.scrollFactor.x) - target.offset.x
			pointB.y = target.y - Int(FlxG.Camera.scroll.y * target.scrollFactor.y) - target.offset.y
		Endif
		
		Local boundsA:FlxExtendedRect = New FlxExtendedRect(pointA.x, pointA.y, contact.frameWidth, contact.frameHeight)
		Local boundsB:FlxExtendedRect = New FlxExtendedRect(pointB.x, pointB.y, target.frameWidth, target.frameHeight)
		
		Local intersect:FlxExtendedRect = boundsA.Intersection(boundsB)
		
		If ((intersect.width = 0 And intersect.height = 0) Or intersect.width = 0 Or intersect.height = 0) Then
			Return False
		Endif
		
		'//	Normalise the values or it'll break the BitmapData creation below
		intersect.x = Floor(intersect.x)
		intersect.y = Floor(intersect.y)
		intersect.width = Ceil(intersect.width)
		intersect.height = Ceil(intersect.height)
		
		If (intersect.width = 0 And intersect.height = 0)
			Return False
		Endif
		Return True
#rem		
		'//	Thanks to Chris Underwood for helping with the translate logic :)
		
		var matrixA:Matrix = New Matrix;
		matrixA.translate(-(intersect.x - boundsA.x), -(intersect.y - boundsA.y));
		
		var matrixB:Matrix = New Matrix;
		matrixB.translate(-(intersect.x - boundsB.x), -(intersect.y - boundsB.y));
		
		var testA:BitmapData = contact.framePixels;
		var testB:BitmapData = target.framePixels;
		var overlapArea:BitmapData = New BitmapData(intersect.width, intersect.height, False);
		
		overlapArea.draw(testA, matrixA, New ColorTransform(1, 1, 1, 1, 255, -255, -255, alphaTolerance), BlendMode.NORMAL);
		overlapArea.draw(testB, matrixB, New ColorTransform(1, 1, 1, 1, 255, 255, 255, alphaTolerance), BlendMode.DIFFERENCE);
		
		'//	Developers: If you'd like to see how this works, display it in your game somewhere. Or you can comment it out to save a tiny bit of performance
		debug = overlapArea;
		
		var overlap:Rectangle = overlapArea.getColorBoundsRect(0xffffffff, 0xff00ffff);
		overlap.offset(intersect.x, intersect.y);
		
		If (overlap.isEmpty())
		{
			Return False;
		}
		Else
		{
			Return True;
		}
#End		
	End Function
	
		
	'/**
	 '* A Pixel Perfect Collision check between a given x/y coordinate and an FlxSprite<br>
	 '* 
	 '* @param	pointX			The x coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 '* @param	pointY			The y coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 '* @param	target			The FlxSprite to check the point against
	 '* @param	alphaTolerance	The alpha tolerance level above which pixels are counted as colliding. Default to 255 (must be fully transparent for collision)
	 '* 
	 '* @return	Boolean True if the x/y point collides with the FlxSprite, false if not
	 '*/
	function PixelPerfectPointCheck:Bool(pointX:int, pointY:int, target:FlxSprite, alphaTolerance:int = 255)
		'//	Intersect check
		If (FlxMath.PointInCoordinates(pointX, pointY, target.x, target.y, target.frameWidth, target.frameHeight) = False) Then
			Return False
		Endif
		
		'//	How deep is pointX/Y within the rect?
		Local buf:=New Int[1]
		ReadPixels (buf,pointX, pointY,1,1 ,0,0)
		
		If (FlxExtendedColor.GetAlpha(buf[0]) >= alphaTolerance) Then
			Return True
		Else
			Return False
		Endif
	End Function

	
	'/**
	 '* Creates a "wall" around the given camera which can be used for FlxSprite collision
	 '* 
	 '* @param	camera				The FlxCamera to use for the wall bounds (can be FlxG.camera for the current one)
	 '* @param	placement			CAMERA_WALL_OUTSIDE or CAMERA_WALL_INSIDE
	 '* @param	thickness			The thickness of the wall in pixels
	 '* @param	adjustWorldBounds	Adjust the FlxG.worldBounds based on the wall (true) or leave alone (false)
	 '* 
	 '* @return	FlxGroup The 4 FlxTileblocks that are created are placed into this FlxGroup which should be added to your State
	 '*/
	Function CreateCameraWall:FlxGroup(camera:FlxCamera, placement:Int, thickness:Int, adjustWorldBounds:Bool = False)

		Local left:FlxTileblock
		Local right:FlxTileblock
		Local top:FlxTileblock
		Local bottom:FlxTileblock
		
		Select (placement)
			Case CAMERA_WALL_OUTSIDE
				left = New FlxTileblock(camera.X - thickness, camera.Y + thickness, thickness, camera.Height - (thickness * 2))
				right = New FlxTileblock(camera.X + camera.Width, camera.Y + thickness, thickness, camera.Height - (thickness * 2))
				top = New FlxTileblock(camera.X - thickness, camera.Y - thickness, camera.Width + thickness * 2, thickness)
				bottom = New FlxTileblock(camera.X - thickness, camera.Height, camera.Width + thickness * 2, thickness)
				
				If (adjustWorldBounds) Then
					FlxG.WorldBounds = New FlxRect(camera.X - thickness, camera.Y - thickness, camera.Width + thickness * 2, camera.Height + thickness * 2)
				Endif
			
			Case CAMERA_WALL_INSIDE
				left = New FlxTileblock(camera.X, camera.Y + thickness, thickness, camera.Height - (thickness * 2))
				right = New FlxTileblock(camera.X + camera.Width - thickness, camera.Y + thickness, thickness, camera.Height - (thickness * 2))
				top = New FlxTileblock(camera.X, camera.Y, camera.Width, thickness)
				bottom = New FlxTileblock(camera.X, camera.Height - thickness, camera.Width, thickness)
				
				If (adjustWorldBounds) Then
					FlxG.WorldBounds = New FlxRect(camera.X, camera.Y, camera.Width, camera.Height)
				Endif
		End Select
		
		Local result:FlxGroup = New FlxGroup(4)
		
		result.Add(left)
		result.Add(right)
		result.Add(top)
		result.Add(bottom)
		
		Return result
	End Function
	
End Class