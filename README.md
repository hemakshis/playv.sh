# playv

A command line utilily to play videos inside a directory with ease.

### Usage
`playv [OPTIONS]...`

Plays video(s) inside the current directory as per the options given

### Options

`1 <file_num>`
Play single video file `<file_num>`.

`a`
Play all video files present in the directory starting from first.

`d <secs>`
Add a time delay of `<secs>` seconds between two video files when playing multiple video files.

`e <file_num>`
Play all video(s) till video file number `<file_num>`.

`f`
Play videos in full screen mode.

`h`
Display help.

`l`
List all the video files present in the current directory with their number.

`n <count>`
Play `<count>` files consecutively starting from the starting file number (or first file if start number not provide).

`p <rate>`
Play all the videos at a playback speed of `<rate>`.

`r`
Play any random video file from the directory.

`s <file_num>`
Play all files starting from the `<file_num>` till the given ending number or count (or till the last video file if both not provided)