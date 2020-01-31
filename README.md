thumbmap v0.6 - Scans a RetroArch playlist for game names and crc32 values, then compares to thumbmap.map (no-intro)
                and renames your downloaded thumbnail images to match your playlist game names.

with thumbmap [lpl file ...] [system]
Example:
              thumbmap "D:/RetroArch/playlists/Atari - 2600.lpl" "Atari - 2600"

Author:
   Discord - Romeo#3620
   
Notes:
   Thumbnails must be present in your /RetroArch/thumbnails directory in order for the thumbmap program to rename.
   You will need the program "Git" to download the thumbnails package from Github, available here:  https://git-scm.com/
   You can download the entire package of default RA (no-intro) thumbnails with a simple command line command for Git:
      git clone --recursive --depth=1 http://github.com/libretro-thumbnails/libretro-thumbnails.git thumbnails
   The RetroArch approved thumbnails repository is available for viewing and further information is here, currently at 54GB:
      https://github.com/libretro-thumbnails/libretro-thumbnails
   The thumbmap program mapping file (thumbmap.map) was created using .dat files generated from the no-intro website:
      https://datomatic.no-intro.org/
