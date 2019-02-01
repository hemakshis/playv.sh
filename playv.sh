#! /bin/bash

function print_help() {
	echo -e "playv
A command line utilily to play videos inside a directory with ease.

Usage:  playv [OPTIONS]...
Plays video(s) inside the current directory as per the options given

Options
    1 <file_num>  Play single video file <file_num>.

    a             Play all video files present in the directory starting
                  from first.

    d <secs>      Add a time delay of <secs> seconds between two video
                  files when playing multiple video files.

    e <file_num>  Play all video(s) till video file number <file_num>.

    f             Play videos in full screen mode.

    h             Display help.

    l             List all the video files present in the current directory
                  with their number.

    n <count>     Play <count> files consecutively starting from the starting
                  file number (or first file if start number not provide).

    p <rate>      Play all the videos at a playback speed of <rate>.

    r             Play any random video file from the directory.

    s <file_num>  Play all files starting from the <file_num> till the given
                  ending number or count (or till the last video file if both
                  not provided)"
}

# Function to print the list of video files inside a directory with video number
function print_list() {
	for ((i = 0 ; i < $no_of_video_files; i++)) ;
	do
		echo $(($i + 1)): $(basename "${video_files[$i]}")
	done

	if [[ $no_of_video_files -eq 0 ]]
	then
		echo "No video files found"
	fi
}

# Function to play single video file
function play_video() {
	i=$(($1 - 1))
	if [[ $full_screen = true ]]
	then
		$(vlc --play-and-exit --rate $playback_speed --fullscreen "${video_files[$i]}" 2>&1)
	else
		$(vlc --play-and-exit --rate $playback_speed "${video_files[$i]}" 2>&1)
	fi
}

# Function to play multiple video files
function play_videos() {
	a=$(($1 - 1))
	b=$(($2 - 1))
	for ((i = $a ; i <= $b ; i++)) ;
	do
		echo "Playing video number $(($i + 1))"
		if [[ $full_screen = true ]]
		then
			$(vlc --play-and-exit --rate $playback_speed --fullscreen "${video_files[$i]}" 2>&1)
		else
			$(vlc --play-and-exit --rate $playback_speed "${video_files[$i]}" 2>&1)
		fi
		sleep $time_delay
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
full_screen=false

while getopts "1:ad:e:fhln:p:rs:" opt;
do
	case "$opt" in
		1)
			single=true
			video_num=$OPTARG
			play_single_file=true
			echo "Playing video number $video_num"
		;;
		a)
			all=true
			play_multiple_files=true
			echo "Playing all videos in the directory"
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
		f)
			full_screen=true
			echo "Playing videos in fullscreen mode"
		;;
		h)
			print_help
		;;
		l)
			print_list
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
		r)
			random=true
			video_num=$((1 + RANDOM % $no_of_video_files))
			play_single_file=true
			echo "Playing video number $video_num"
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

	if [[ $video_num -ge 1 && $video_num -le $no_of_video_files ]]
	then
		play_video $video_num
	else
		echo "Invalid file number"
		exit 1
	fi
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

	# If start index is less than 1
	if [[ $start_num -lt 1 ]]
	then
		start_num=1
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

	play_videos $s $e
fi