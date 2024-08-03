# BattleMusic
Plays battle music on combat start and ends when combat ends.

Music is randomized on start of combat, by default it will randomize between 6 different songs.
Music lingers for 5 seconds after combat by default, if you start a new combat before the lingering time ends then the same music will keep on playing.

Video of the addon in action  
https://www.youtube.com/watch?v=YXQPcDtmPDo

## Instructions:

### Config Menu (Open by typing "/bmusic")
![image](https://github.com/user-attachments/assets/9db3ceef-dd3a-45fe-94fa-31e51757eb01)  
Open by typing "/bmusic"  
  
### Install AddOn:
- [Download the addon](https://github.com/Fiurs-Hearth/BattleMusic/archive/refs/heads/main.zip)
- Unpack the file
- Open the unpacked file and rename the folder named BattleMusic-master to BattleMusic
- Put the renamed folder into the AddOns folder: World of Warcraft\Interface\AddOns
- Start or restart WoW if already running

### Add music:
- Go into the AddOn's folder "BattleMusic" and then into "music"
- Put the song here and name the file "combat_NUMBER.mp3" and replace NUMBER with a number.
- Make sure there are no gaps in the number order
- Make sure the file format is mp3
- Change number of songs to randomize from by following below instructions.

### Change number of songs to randomize from:
- Type "/script battleMusic.songs=NUMBER" and replace NUMBER with the number of songs you want it to randomize.  
Example: /script battleMusic.songs=10

### Change linger timer:
- Type "/script battleMusic.linger=NUMBER" and replace NUMBER with the lingering you want in seconds.  
Example: /script battleMusic.linger=15.5
