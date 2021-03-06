Strict
Import mojo
Import flixel
Import flixel.plugin.photonstorm

Import "../assets/sprites/red_ball.png"
Import "../assets/sprites/green_ball.png"
Import "../assets/sprites/blue_ball.png"

#REFLECTION_FILTER = "velo*"

'import tests.TestsHeader;
Function Main:Int()
	New Objects()
	Return 0
End Function

Class Objects Extends FlxGame
	
	Method New()
		Super.New(320, 256, GetClass("VelocityTest1"), 1, 60)
		Print VelocityTest1.title
		Print VelocityTest1.description
		Print VelocityTest1.instructions	
		FlxG.VisualDebug = True
	End Method
	
	Method OnContentInit:Void()
		FlxAssetsManager.AddImage("red_ball", "red_ball.png")
		FlxAssetsManager.AddImage("green_ball", "green_ball.png")
		FlxAssetsManager.AddImage("blue_ball", "blue_ball.png")
	End Method	

End Class


Class VelocityTest1 Extends FlxState
	'//	Test specific variables
Private 
	
	Field red:FlxSprite
	Field green:FlxSprite
	Field blue:FlxSprite
	
'	Field header:TestsHeader

Public
	'//	Common variables
	Global title:String = "Velocity 1"
	Global description:String = "Move an FlxObject towards another FlxObject"
	Global instructions:String = "Click with the mouse to position the green ball"
	
	Method Create:Void()
'		header = new TestsHeader(instructions);
'		Add(header);
		FlxG.Mouse.Show()
		'//	Test specific
			
		red = New FlxSprite(160, 120, "red_ball")
		green = New FlxSprite(-32, 0, "green_ball")
		blue = New FlxSprite(0, 0, "blue_ball")
		blue.visible = false
			
		Add(blue)
		Add(red)
		Add(green)
	
		
		'//	Header overlay
		'add(header.overlay);
	End Method
	
	Method Update:Void()
		Super.Update()
		If (FlxG.Mouse.JustReleased()) Then
			green.x = FlxG.Mouse.screenX
			green.y = FlxG.Mouse.screenY
			
			blue.x = red.x
			blue.y = red.y
			blue.visible = true
			
			FlxVelocity.MoveTowardsObject(blue, green, 180)
		Endif
	End Method
End Class