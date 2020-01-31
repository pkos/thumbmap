use strict;
use warnings;
use Term::ProgressBar;

#init
my $mapfile = "";
my $lplfile = "";
my $system = "";
my $substringh = "-h";
my @linesmapsystem = "";
my @linesmapgame = "";
my @linesmapcrc32 = "";
my @lineslpl = "";
my @lineslplgame = "";
my @lineslplcrc32 = "";

#check command line
foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "thumbmap v0.7 - Scans a playlist for game names and crc32 values, then compares to thumbmap.map (no-intro)\n";
	print "                and renames your downloaded thumbnail images to match your playlist game names\n";
	print "\n";
	print "with thumbmap [lpl file ...] [system]";
    print "\n";
	print "Example:\n";
	print '              thumbmap "D:/RetroArch/playlists/Atari - 2600.lpl" "Atari - 2600"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
}

#set paths and system variables
if (scalar(@ARGV) < 2 or scalar(@ARGV) > 2) {
  print "Invalid command line.. exit\n";
  print "use: thumbmap -h\n";
  print "\n";
  exit;
}
$mapfile = "thumbmap.map";
$lplfile = $ARGV[-2];
$system = $ARGV[-1];

#exit no parameters
if ($lplfile eq "" or $system eq "") {
  print "Invalid command line.. exit\n";
  print "use: thumbmap -h\n";
  print "\n";
  exit;
}

#debug
print "lpl file: $lplfile\n";
print "system: $system\n";

#read map file
open(FILE, "<", $mapfile) or die "Could not open $mapfile\n";
LOOP: while (my $readline = <FILE>) {
  $readline =~ s/[\x0A\x0D]//g;
  my @templine = split /,,/ , $readline;
  if ($templine[0] = $system) {
    #print "$templine[0] " . "$templine[1] " . "$templine[2]";
	push(@linesmapsystem, $templine[0]);
    push(@linesmapgame, $templine[1]);
	push(@linesmapcrc32, $templine[2]);
    next LOOP;  
  }
}
close (FILE);
print "map file: $mapfile\n";
#print "@linesmapcrc32";

#read playlist file
open(FILE, "<", $lplfile) or die "Could not open $lplfile\n";
while (my $readline = <FILE>) {
  push(@lineslpl, $readline);
  #print "$readline\n";
}
close (FILE);

my $gamename = "";
my $crc = "";
my $resultgamestart = "";
my $resultgameend = "";
my $resultcrcstart = "";
my $resultlplstart = "";
my @crclines;
my $crcline = "";
my $lplcrc = "";

#parse the game name and crc32 from playlist
foreach my $lplline (@lineslpl) {
  if ($lplline =~ m/"label": "/) {
    #parse game name
	$resultgamestart = index($lplline, '"label": "');
	$resultgameend = index($lplline, '",');
	my $length = ($resultgameend)  - ($resultgamestart + 10) ;
    $gamename  = substr($lplline, $resultgamestart + 10, $length);
    #print "$gamename ";
    push(@lineslplgame, $gamename);
  }
  if ($lplline =~ /"crc32": "/) {
    #parse crc
	$resultlplstart = index($lplline, '"crc32": "');
    $lplcrc  = uc substr($lplline, $resultlplstart + 10, 8);
	#print " $lplcrc\n";
    push(@lineslplcrc32, $lplcrc);  
  }
}

my $thumbpath = "";

#find thumbnails directory
my $temppos = rindex($lplfile, "/");
$thumbpath = substr($lplfile, 0, $temppos);
$thumbpath =~ s/playlists/thumbnails/;
$thumbpath = $thumbpath . "/" . $system;
print "thumbnails folder: " . "$thumbpath\n";
opendir ( DIR, $thumbpath ) or die "Error in opening dir $thumbpath\n";
close DIR;

#main loop to compare crc32 values and start renaming
my $i = 0;
my $originalfile = "";
my $newfile = "";
my $max = scalar(@lineslplcrc32);
my $progress = Term::ProgressBar->new({name => 'progress', count => $max});

open(LOG, ">", "log_" . "$system" . ".txt") or die "Could not open log.txt\n";
OUTER: foreach my $checklpl (@lineslplcrc32) {
  $progress->update($_);
  #print "$checklpl\n";
  my $j = -1;
  INNER: foreach my $checkmap (@linesmapcrc32) {
     $j++;
	 #print "$checkmap\n";
     if (uc "$checkmap" eq uc "$checklpl" and "$checklpl" ne "") {
	   #we have a match and the proper lpl and map game names to start renaming
	   #print "match: " . "$checklpl " . "$checkmap " . "$lineslplgame[$i] " . "$linesmapgame[$j]\n";
	   
	   #first boxarts
	   $originalfile = "$thumbpath" . "/" . "Named_Boxarts/" . "$linesmapgame[$j].png";
	   $newfile = "$thumbpath" . "/" . "Named_Boxarts/" . "$lineslplgame[$i].png";
	   #print "$originalfile " . "$newfile\n";
	   if ($originalfile ne $newfile) {
	     if (rename $originalfile, $newfile) {
	       print LOG "Renamed boxart png file: ". "$originalfile " . "$newfile\n";
	     } else {
	       if (-e $newfile) {
		     print LOG "Already exists boxart png image: $newfile\n";
		   } else {
	   	     print LOG "Missing boxart png image: $originalfile\n";
	       }
	     }
	   } else {
	     if (-e $newfile) {
	       print LOG "Already exists boxart png image: $newfile\n";
	     } else {
		   print LOG "Missing boxart png image: $originalfile\n";
		 }
	   }
	   
	   #second snaps 
	   $originalfile = "$thumbpath" . "/" . "Named_Snaps/" . "$linesmapgame[$j].png";
	   $newfile = "$thumbpath" . "/" . "Named_Snaps/" . "$lineslplgame[$i].png";
	   #print "$originalfile " . "$newfile\n";
	   if ($originalfile ne $newfile) {
	     if (rename $originalfile, $newfile) {
	       print LOG "Renamed boxart snaps file: ". "$originalfile " . "$newfile\n";
	     } else {
	       if (-e $newfile) {
		     print LOG "Already exists snaps png image: $newfile\n";
		   } else {
	   	     print LOG "Missing boxart png image: $originalfile\n";
	       }
	     }
	   } else {
	     if (-e $newfile) {
	       print LOG "Already exists snaps png image: $newfile\n";
	     } else {
		   print LOG "Missing snaps png image: $originalfile\n";
		 }
	   }
	   
	   #third titles 
	   $originalfile = "$thumbpath" . "/" . "Named_Titles/" . "$linesmapgame[$j].png";
	   $newfile = "$thumbpath" . "/" . "Named_Titles/" . "$lineslplgame[$i].png";
	   #print "$originalfile " . "$newfile\n";
	   if ($originalfile ne $newfile) {
	     if (rename $originalfile, $newfile) {
	       print LOG "Renamed boxart titles file: ". "$originalfile " . "$newfile\n";
	     } else {
	       if (-e $newfile) {
		     print LOG "Already exists titles png image: $newfile\n";
		   } else {
	   	     print LOG "Missing boxart titles image: $originalfile\n";
	       }
	     }
	   } else {
	     if (-e $newfile) {
	       print LOG "Already exists titles png image: $newfile\n";
	     } else {
		   print LOG "Missing titles png image: $originalfile\n";
		 }
	   }
	   
	   $i++;
	   next OUTER;
	 }
  }
  $i++;
}
close LOG;
print "\nlog file: log_" . "$system" . ".txt\n";


