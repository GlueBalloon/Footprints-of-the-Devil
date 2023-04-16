--[[
Hm ok. Here’s a summary of the current animations:
1. The crosshairs bouncing up on targets. It’s a tween. The code for this animation looks like it is called both from somewhere in the InGameUI:touched function, and in the Game:draw function, and referenced in various other places, so that I’m not sully clear on how it’s handled. The InGameUI:drawBadgesAndAnimations function, seems to have something to do with it too.

2. The floating-number animation when a unit is attacked. These are also tweens but I don't fully get how they're managed. it looks like they are created in Game:Attack when an attack is called as a result of a tap or an AI command. this creates a damage animation tween, which is then added to a damage animations table. The tweens seem to be managed by a function InGameUI:drawBadgesAndAnimations, which is called every turn by the game in its draw cycle.

3. The turn-changing animation. this all happens inside one function, InGameUI:drawAnnouncement, taht's called every draw cycle from the game: draw function. It uses os.clock(). it seems to be activated by setting the variable InGameUI.announcementTeam, somewhere, which causes the animation to happen, frame by frame every draw cycle, and when the animation sequence is completed, that value was it back to nil. 

5. The badge enlargement bounce when dsmage is taken. This seems to go through InGameUI:drawBadgesAndAnimations too. I can't quite tell how separated badges and damage animations are, they seem to be intertwined, but not identical.

6. The arrows indicating flanking opportunities. Uses os.clock(), and apparently creates a new mesh every frame — will that eventually cause memory problems?

... not to mention that there are two separate big, honking draw functions, one in Game, and one in InGameUI. I think they each have their own crucial sequences. It's probably not good to combine them both into one ultra-massive function, but it's probably also not good that the things that have to happen in the definite orders are spread out for different functions.

]]