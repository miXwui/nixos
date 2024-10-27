#!/usr/bin/env bash

# Saves YouTube video and audio files.
# Authenticates YouTube with Firefox cookies in the specified container.
# Needs to authenticate for YouTube Premium quality downloads.

# `about:profiles` in Firefox to see profiles
#
# /usr/lib/python3.12/site-packages/yt_dlp/cookies.py
# might need to change line to:
# try_call(lambda: re.fullmatch(r'user-context-([^\.]+)', context['l10nId']).group())
# The above line does fix the `could not find firefox container user-context-personal in containers.json` issue.
# I've added it as a patch in `modules/home-manager-media.nix`.
# TODO: submit it as a PR to the yt-dlp GitHub repo?

# saving all in YouTube `248` `vp09.99.49.08` video quality ID for now.

path="$XDG_MUSIC_DIR/yt downloads/"

while getopts "p:" option; do
  case $option in
  p) path=$OPTARG ;;
  *)
    echo "usage: $0 [-p] /download/path/" >&2
    exit 1
    ;;
  esac
done

echo Downloading to "$path"
read -r -p 'Enter URL: ' yt_url
# List formats
yt-dlp --cookies-from-browser firefox::"user-context-personal" --list-formats -- "$yt_url"
read -r -p 'Enter video format ID (or leave empty for best): ' vfid
read -r -p 'Enter audio format ID (or leave empty for best): ' afid

if [ -z "${vfid}" ]; then
  vfid="bv*"
fi

if [ -z "${afid}" ]; then
  afid="ba"
fi

# Downloads selected video+audio formats (or best if left blank)
# Authentication needed for YT Premium quality
#
# --exec "rm %(requested_formats.:.filepath)#q" to delete intermediate files
# change `rm` to `del` on Windows
# https://github.com/yt-dlp/yt-dlp/issues/2916#issuecomment-1063359892
yt-dlp --cookies-from-browser firefox::"user-context-personal" --keep-video --extract-audio --no-keep-fragments --exec "rm %(requested_formats.:.filepath)#q" --embed-metadata --embed-thumbnail --embed-subs --sub-langs "en.*" --format "$vfid+$afid/b" --paths "$path" -- "$yt_url"
