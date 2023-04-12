--[[

The game that I am picturing based on our discussions works basically like this: 1) a player is told the era they’re playing in, and the battle they’re leading up to; 2) the player is given 3-5 preparatory battles to win leading up to the final battle, and in the final battle they will have whatever powerups, stat modifications, and allies they retain from the prep battles; 3) success in winning the final war leads to progression to the next era; 4) the game as planned right now only includes a first era, presumably Homo sapiens versus Neanderthals, and a last era, perhaps as an Allied country versus an Axis country in World War II; 5) each era’s units, terrain, and resources will be customized for that era; 6) there will be a timer for each turn, so that the player cannot ponder their moves forever; 7) an AI opponent will be available but the main focus of the game is multiplayer combat on mobile devices; 8) each prep battle is very focused and limited compared to an Advance Wars battle, with a maximum of 5 units and a smaller map; 9) the final battles can have more units and a larger map and a longer timer. Am I leaving anything out?

Next, you should ask the Coder to expand on the existing code by implementing the following features:

Create a main menu with options for starting a new game or loading a saved game.
Implement a turn system that allows players to take turns moving and performing actions with their units.
Add basic AI functionality for the opposing player, allowing the AI to make simple decisions like moving and attacking with its units.
Develop a simple user interface (UI) for in-game actions such as unit selection, movement, and combat.
Implement a system for loading and saving game progress.
Remember to ask the Coder to provide clear and concise code, focusing on one feature at a time to ensure that the code remains organized and easy to build upon.


Let me summarize the game a little more specifically. It will be structured around the concept of a “great battle“. In final form, it should chart a series of great battles from the distant past up to very recent history, but in the current mission, it will have one great battle at the dawn of history and one great battle from World War II. Great battles will consist of 3 to 5 smaller, preparatory conflicts, followed by participation in the main event. Gameplay will resemble Advance Wars, though highly simplified, and with each turn having a fairly tight time limit. The game is intended mainly for multiplayer, though there will be an AI-opponent option. In every battle, the player will command a small handful of units, from 3 to 8, and the units will be customized to the era of combat. The preparatory battles may grant power ups, skill buffs, and levelled-up units that can then be brought into the final battle. At this point, with gameplay so focused and fast-paced, I don’t think fog of war features will be used. The first great battle will be between Homo sapiens and Neanderthals, with the Neanderthals having superior strength, and the advantages of Homo sapiens not yet decided. The last great battle will be in world war two, which presents so many different possibilities for scenarios that one has not been chosen yet. Does anything in that description need clarifying?

et’s review the goals for this sprint:

Please implement the following features:

1. Create a basic combat system where Neanderthal units have a strength advantage over Homo sapiens units.
2. Give Homo sapiens units a combat bonus when they flank an opponent on two or more sides.
3. Implement a simple leveling system, where surviving a battle allows a unit to level up and increase its strength.
4. This is a multiplayer-focused game with a time limit for each turn. Implement turn taking.
5. Constrain unit movement to 1 cell per turn. Only allow orthogonal moves. 

All code should be written for Codea Lua, only using the functions and features available in Codea Lua. Specifically there are no “def” statements in Codea Lua
;;
]]