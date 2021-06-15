#!/bin/bash
if ! type "ffmpeg" &> /dev/null; then
    echo "Please install ffmpeg. You can use Homebrew [http://brew.sh]"
    exit
fi;

if ! type "convert" &> /dev/null; then
    echo "Please install ImageMagick. You can use Homebrew [http://brew.sh]"
    exit
fi;

BARCODE_RESOLUTION="2400x200"

DEBUG=""
# DEBUG="-ss 00:06:20 -frames:v 10" # Only take 10 screenshots

BARCODE_DEST="./barcodes"
IMAGE_TMP="./.tmp"

if [[ $1 ]]; then
    MOVIE_SOURCE=$1
else
    exit
fi;

MOVIE_NAME=$(basename -- "$MOVIE_SOURCE")
MOVIE_NAME=`rev <<< "$MOVIE_NAME" | cut -d"." -f2- | rev`

if [[ $2 ]]; then
    MOVIE_NAME=$2
fi;

MOVIE_NAME=${MOVIE_NAME//./_}
MOVIE_NAME=${MOVIE_NAME//-/_}
MOVIE_NAME=${MOVIE_NAME// /_}
MOVIE_NAME=$(echo "$MOVIE_NAME" | perl -pe 's/(^|_)./uc($&)/ge;s/_//g')

IMAGE_TMP_FOLDER="${IMAGE_TMP}/${MOVIE_NAME}"

if [ ! -d "${IMAGE_TMP}" ]; then
    mkdir "${IMAGE_TMP}"
fi
if [ ! -d "${BARCODE_DEST}" ]; then
    mkdir "${BARCODE_DEST}"
fi
if [ ! -d "${BARCODE_DEST}/original" ]; then
    mkdir "${BARCODE_DEST}/original"
fi

echo "Creating Movie Barcode for: $MOVIE_NAME"

if [ ! -d "${IMAGE_TMP_FOLDER}" ]; then
    mkdir "${IMAGE_TMP_FOLDER}"
fi

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${MOVIE_SOURCE}" | awk '{print ($0-int($0)>0)?int($0)+1:int($0)}')

echo "Creating ${DURATION}x (1x1 pixel) snapshots (This might take a while)..."
ffmpeg -i "${MOVIE_SOURCE}" $DEBUG -preset ultrafast -r 1/1 -vf fps=1 -filter:v "scale=1:1,crop=iw:ih*0.8" "${IMAGE_TMP_FOLDER}/image-%05d.bmp" &>/dev/null

echo "Creating original (${DURATION}x1 pixel) image..."
convert +append "${IMAGE_TMP_FOLDER}/*.*" "${BARCODE_DEST}/original/${MOVIE_NAME}.png"

sh ./convert.sh "${BARCODE_DEST}/original/${MOVIE_NAME}.png"

echo "Cleaning up..."
rm -rf ${IMAGE_TMP_FOLDER}

echo "Movie Barcode successfully created!"
tput bel
