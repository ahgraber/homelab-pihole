{\rtf1\ansi\ansicpg1252\cocoartf2511
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\froman\fcharset0 Times-Bold;\f1\froman\fcharset0 Times-Roman;\f2\fmodern\fcharset0 Courier;
\f3\froman\fcharset0 Times-Italic;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;}
{\*\expandedcolortbl;;\cssrgb\c0\c0\c0;}
{\*\listtable{\list\listtemplateid1\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid1\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid1}}
{\*\listoverridetable{\listoverride\listid1\listoverridecount0\ls1}}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\sl440\sa298\partightenfactor0

\f0\b\fs36 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 Manually resizing the SD card on Raspberry Pi\
\pard\pardeftab720\sl280\sa240\partightenfactor0

\f1\b0\fs24 \cf2 You can also resize the partitions of the SD card that your Pi is running on. \
First you need to change the partition table with fdisk. You need to remove the existing partition entries and then create a single new partition than takes the whole free space of the disk. This will only change the partition table, not the partitions data on disk. 
\f0\b The start of the new partition needs to be aligned with the old partition!
\f1\b0  \
Start fdisk: \
\pard\pardeftab720\sl280\partightenfactor0

\f2 \cf2 sudo fdisk /dev/mmcblk0\
\pard\pardeftab720\sl280\sa240\partightenfactor0

\f1 \cf2 Then delete partitions with 
\f3\i d
\f1\i0  and create a new with 
\f3\i n
\f1\i0 . You can view the existing table with 
\f3\i p
\f1\i0 . \
\pard\tx220\tx720\pardeftab720\li720\fi-720\sl280\partightenfactor0
\ls1\ilvl0
\f3\i \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 p
\f1\i0  to see the current start of the main partition\
\ls1\ilvl0
\f3\i \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 d
\f1\i0 , 
\f3\i 3
\f1\i0  to delete the swap partition\
\ls1\ilvl0
\f3\i \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 d
\f1\i0 , 
\f3\i 2
\f1\i0  to delete the main partition\
\ls1\ilvl0
\f3\i \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 n
\f1\i0  
\f3\i p
\f1\i0  
\f3\i 2
\f1\i0  to create a new primary partition, next you need to enter the start of the old main partition and then the size (
\f3\i enter
\f1\i0  for complete SD card). The main partition on the Debian image from 2012-04-19 starts at 157696, but the start of your partition might be different. Check the 
\f3\i p
\f1\i0  output!\
\ls1\ilvl0
\f3\i \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 w
\f1\i0  write the new partition table\
\pard\pardeftab720\sl280\sa240\partightenfactor0
\cf2 Now you need to reboot: \
\pard\pardeftab720\sl280\partightenfactor0

\f2 \cf2  sudo shutdown -r now\
\pard\pardeftab720\sl280\sa240\partightenfactor0

\f1 \cf2 After the reboot you need to resize the filesystem on the partition. The 
\f2 resize2fs
\f1  command will resize your filesystem to the new size from the changed partition table. \
\pard\pardeftab720\sl280\partightenfactor0

\f2 \cf2 sudo resize2fs /dev/mmcblk0p2\
\pard\pardeftab720\sl280\sa240\partightenfactor0

\f1 \cf2 This will take a few minutes, depending on the size and speed of your SD card. \
When it is done, you can check the new size with: \
\pard\pardeftab720\sl280\partightenfactor0

\f2 \cf2 df -h\
}