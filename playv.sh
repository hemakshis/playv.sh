#! /bin/bash

# play all the videos in the folder OR play a single video OR provide a start and end no. OR provide no. of videos to play consecutively
# for all the videos '-a'
# for single video '-1=5' (note: it is 1 (one, integer) not the char 'l') play video no. 5 as per `ls` command listing
# for start & end '-s=2' '-e=5' it will play videos from video no. 2 to video no. 5 as per `ls` command listing
# for consecutive playing '-s=2' '-n=5' starting from video no. 2 (as per `ls` command listing) play next 4 videos including this one (1 + 4 = 5)
# playback speed '-p=1.5x'
# time gap between two videos '-d=10' time gap of 10 seconds
# maybe a volume option as well '-v=75' keep volume at 75
# BONUS - play any random video '-r'

# Function to play single video file
function play_video() {
	i=$(($1 - 1))
	$(vlc --play-and-exit --rate $2 ${video_files[$i]} 2>&1)
}

# Function to play multiple video files
function play_videos() {
	s=$(($1 - 1))
	e=$(($2 - 1))
	for ((i=$s ; i <= $e ; i++)) ;
	do
		$(vlc --play-and-exit --rate $3 ${video_files[$i]} 2>&1)
		sleep $4
	done
}

# Get general folder details
cwd=$(pwd)
shopt -s nullglob
video_files=(
	"$cwd"/*.mp4
	"$cwd"/*.mkv
	"$cwd"/*.avi
)
no_of_video_files=${#video_files[@]}



single=false

random=false

video_num=0

play_single_file=false

all=false

# Default - play from the first video
start_num=1
start_num_provided=false

# Default - play till the last video
end_num=$no_of_video_files
end_num_provided=false

# Default - play till the last video
num_of_videos_to_play=$no_of_video_files
num_of_videos_to_play_provided=false

play_multiple_files=false

playback_speed=1

time_delay=0

while getopts "ar1:d:e:n:p:s:" opt;
do
	case "$opt" in
		a)
			all=true
			play_multiple_files=true
			echo "Playing all videos in the directory"
		;;
		r)
			random=true
			video_num=$((1 + RANDOM % $no_of_video_files))
			play_single_file=true
			echo "Playing video number $video_num"
			;;

		1)
			single=true
			video_num=$OPTARG
			play_single_file=true
			echo "Playing video number $video_num"
		;;
		d)
			time_delay=$OPTARG
			echo "Added a time delay of $time_delay between videos"
		;;
		e)
			end_num=$OPTARG
			end_num_provided=true
			play_multiple_files=true
		;;
		n)
			num_of_videos_to_play=$OPTARG
			num_of_videos_to_play_provided=true
			play_multiple_files=true
		;;
		p)
			playback_speed=$OPTARG
			echo "Playing videos at a playback speed of $playback_speed"
		;;
		s)
			start_num=$OPTARG
			start_num_provided=true
			play_multiple_files=true
		;;
	esac
done

if [[ $play_single_file = true && $play_multiple_files = true ]]
then
	echo "ERROR: Options for playing single file and options for playing multiple files cannot be used simultaneously"
	exit 1
fi

if [[ $play_single_file = true ]]
then
	if [[ $single = true && $random = true ]]
	then
		echo "ERROR: Option `-s` and `-r` cannot be used simultaneously"
		exit 1
	fi

	play_video $video_num $playback_speed
fi

if [[ $play_multiple_files = true ]]
then
	if [[ $end_num_provided = true && $num_of_videos_to_play_provided = true ]]
	then
		echo "ERROR: Option `-e` and `-n` cannot be used simultaneously"
		exit 1
	fi

	if [[ $end_num_provided = true && $end_num -lt $start_num ]]
	then
		echo "ERROR: Value for option `-e` cannot be less than value for option `-s`"
		exit 1
	fi

	s=$start_num
	e=$end_num

	if [[ $end_num_provided = true ]]
	then
		e=$end_num
	elif [[ $num_of_videos_to_play_provided = true ]]
	then
		e=$(($start_num + $num_of_videos_to_play - 1))

	fi
	# If end index exceeds number of video files
	if [[ $e -gt $no_of_video_files ]]
	then
		e=$no_of_video_files
	fi

	play_videos $s $e $playback_speed $time_delay
fi