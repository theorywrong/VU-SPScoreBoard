# VU-SPScoreBoard
SPScoreBoard is a simple scoreboard mod for sniper distance, each distance is saved inside the server and don't take care of the gamemode / maps. he is reboot-proof and can tell when you do new distance score with a notification.
He work with the Venice Unleashed engine.

# Installation

Simply put SPScoreBoard inside the folder **Admin/Mods**, after, put the name **SPScoreBoard** inside **ModList.txt**

# Settings

SPScoreBoard have some settings in this lua file. Take a look !

**Server Side**
maxScore : Number of score showed in the scoreboard (Default: 10)
isDebug : Allow the "reset" command, Disable it in "Production" (Default: False)
isHeadShotNeeded : If an headshot is needed for save the score (Default: False)
weapons_allowed : Define weapons list allowed, nil = all weapons allowed (Default: Sniper)

**Client Side**
inputPress : Key used for open the Scoreboard (Default: F2)

#  Screenshot
![ScoreBoard](https://i.ibb.co/bdvCW9k/Score-Board.png)
![Notification](https://i.ibb.co/yXQsfxb/New-Score-Notif.png)

Enjoy ! :D