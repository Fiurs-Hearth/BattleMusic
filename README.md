# BattleMusic (Vanilla WoW Addon)

BattleMusic is a World of Warcraft **Vanilla (1.12)** addon that plays custom music during combat.  
It allows you to configure songs with conditions like zone, elite/boss fights, and level ranges.
There is also an option to set a linger duration to keep playing songs after combat.

---

## Features

- Add unlimited custom songs via the scrollable UI
- Configurable linger time (delay after combat before music stops)
- Option to randomize the next track
- Song filters:
  - Disable per-song
  - Zone-specific songs
  - Elite-only or Boss-only songs
  - Level range restrictions (e.g. `10-20`, `54-`, or `15`)
- Clear button (double-click confirmation)

## How to Install AddOn

- [Download the addon](https://github.com/Fiurs-Hearth/BattleMusic/archive/refs/heads/master.zip)
- Unpack the file
- Open the unpacked file and rename the folder named BattleMusic-master to BattleMusic
- Put the renamed folder into the AddOns folder: World of Warcraft\Interface\AddOns
- Start or restart WoW if already running

## How to Add Music

- Files must be mp3 or wav files
- Go into the AddOn's folder "BattleMusic" and then into "music"
- Put the songs here
- Make sure the file format is mp3 or wav
- Log in to the game and type /bmusic to open the BattleMusic config and add the song there with the fileformat at the end (my_song.mp3), don't forget to hit save when you are done.

## Config Menu (Open by typing "/bmusic")
<img width="1574" height="504" alt="image" src="https://github.com/user-attachments/assets/0a02475c-daee-4456-b6c9-bf345914f251" />  
Open by typing "/bmusic"  

  
## Video of the addon in action  
https://www.youtube.com/watch?v=YXQPcDtmPDo

## Why some MP3 or WAV files might not play
Song not playing?  
This could be the issue:  
  
World of Warcraft (Vanilla 1.12) has very strict audio support
- MP3 must use constant bitrate (CBR). If the file is variable bitrate (VBR), WoW often refuses to play it or may crash
- WAV must be uncompressed PCM (not compressed, ADPCM, or floating-point)
- Files that are too large, use unusual sample rates, or are encoded with the wrong codec will simply fail silently
- If your song doesn’t play in game, it’s usually because of the encoding format rather than the addon itself
