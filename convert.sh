if ! type "convert" &> /dev/null; then
    echo "Please install ImageMagick. You can use Homebrew [http://brew.sh]"
    exit
fi;

BARCODE_RESOLUTION="3400x400"

BARCODE_DEST="./barcodes"

FILES="${BARCODE_DEST}/original/*.png"

if [[ $1 ]]; then
    FILES=$1
fi;

for filename in $FILES; do
    MOVIE_NAME="$(basename -- "$filename")"
    MOVIE_NAME=${MOVIE_NAME%%.*}
    
    echo "Creating resized ($BARCODE_RESOLUTION pixel) image..."
    convert $filename -quality 100 -resize ${BARCODE_RESOLUTION}\! "${BARCODE_DEST}/${MOVIE_NAME}_${BARCODE_RESOLUTION}.png"
done
