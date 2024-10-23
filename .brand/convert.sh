#!/usr/bin/env bash
set -eu

# https://imagemagick.org/
# https://pngquant.org/
# https://github.com/JackMordaunt/icns


svg::png() {
  local svg="$1" png="${2:-${1%.svg}}.png" size="${3:-1024}" ppi="${4:-72}"
  [ ! -f "$svg" ] && return 1
  magick -background None -quality 100 "$svg" -resize "$size" -density "$ppi" \
    "$png"
  pngquant --force --skip-if-larger --strip --speed 1 --ext .png "$png"

  echo "Save $png $size"
}

svg::png_extended() {
  local svg="$1" png="${2:-${1%.svg}}.png" size_x="${3:-1000}" size_y="${4:-256}"
  [ ! -f "$svg" ] && return 1
  local min_size=$((size_x < size_y ? size_x : size_y))

  magick -background None -quality 100 "$svg" \
    -resize "${min_size}x${min_size}^" -gravity center \
    -extent "${size_x}x${size_y}" "$png"
  pngquant --force --skip-if-larger --strip --speed 1 --ext .png "$png"

  echo "Saved $png at $size_x x $size_y"
}

svg::ico() {
  local svg="$1" ico="${2:-${1%.svg}}.ico"
  local size="${3:-256,128,96,64,48,32,16}" ppi="${4:-72}"
  [ ! -f "$svg" ] && return 1
  magick -background None -quality 100 "$svg" -density "$ppi" \
    -define icon:auto-resize="$size" "$ico"

  echo "Save $ico $size"
}

svg::icns() {
  local svg="$1" icns="${2:-${1%.svg}}.icns" png="${2:-${1%.svg}}.png"
  local size="${3:-1024}" ppi="${4:-72}"

  svg::png "$svg" "$2" "$size" "$ppi"
  icnsify -i "$png" -o "$icns"
  rm -f "$png"

  echo "Save $icns $size"
}

spinner() {
  local svg_in="$1" sv_out="$2" gif="${3:-spinner.gif}"
  [ ! -f "$svg_in" ] || [ ! -f "$sv_out" ] && return 1

  magick -background None -quality 100 "$svg_in" -resize 256 -density 72 \
    .overlay.png
  magick "$sv_out" -resize 320x320 -duplicate 16 -distort SRT %[fx:t*90/n] \
    -set delay 6 -loop 0 "$gif"
  magick "$gif" -background None -coalesce \
    -resize 320x320 null: .overlay.png \
    -gravity center -layers composite -layers optimize "$gif"
  rm -f .overlay.png

  echo "Save $gif"
}

opengraph() {
  local svg="$1" png="${2:-}/opengraph.png" size="${3:-256}" ppi="${4:-72}"
  [ ! -f "$svg" ] && return 1

  magick -size 1200x630 xc:#eaf7e6 "$png"
  magick -background None -quality 100 "$svg" -resize "$size"^ -density "$ppi" \
    .logo.png
  magick "$png" -coalesce .logo.png -gravity center -composite "$png"
  rm .logo.png
  pngquant --force --skip-if-larger --strip --speed 1 --ext .png "$png"

  echo "Save $png"
}

logo() {
  local svg="$1" png="${2:-}/element-app-logo.png" ppi="${3:-72}"
  [ ! -f "$svg" ] && return 1
  magick -background None -quality 100 "$svg" -resize 196^ -density "$ppi" \
    .logo.png
  magick -size 320x320 canvas:transparent \
    .logo.png -gravity center -shadow 50x25+10+10 -composite \
    .logo.png -geometry +0-20 -composite "$png"
  rm .logo.png
  pngquant --force --skip-if-larger --strip --speed 1 --ext .png "$png"

  echo "Save $png"
}

dimensions=(16x16 24x24 48x48 64x64 96x96 128x128 256x256 512x512)
for d in "${dimensions[@]}"; do
  svg::png ./talks.hub.zyfra.com_button.svg "./desktop/build/icons/$d" "$d"
done
svg::ico ./talks.hub.zyfra.com_button.svg ./desktop/build/icon
svg::icns ./talks.hub.zyfra.com_button.svg ./desktop/build/icon
spinner ./talks.hub.zyfra.com_inner.svg ./talks.hub.zyfra.com_outer.svg ./desktop/build/install-spinner.gif


opengraph ./talks.hub.zyfra.com_logo.svg ./web/res/themes/element/img/logos
cp ./talks.hub.zyfra.com_logo.svg ./web/res/themes/element/img/logos/element-logo.svg
logo ./talks.hub.zyfra.com_button.svg ./web/res/themes/element/img/logos

svg::ico ./talks.hub.zyfra.com_button.svg ./web/res/vector-icons/favicon 96,32,16

dimensions=(24 48 50 76 88 120 150 152 180 300 1024)
for d in "${dimensions[@]}"; do
  svg::png ./talks.hub.zyfra.com_button.svg "./web/res/vector-icons/$d" "$d"
done

dimensions=(57 60 72 76 114 120 144 152 180)
for d in "${dimensions[@]}"; do
  svg::png ./talks.hub.zyfra.com_button.svg "./web/res/vector-icons/apple-touch-icon-$d" "$d"
done

dimensions=(70 150 310)
for d in "${dimensions[@]}"; do
  svg::png ./talks.hub.zyfra.com_button.svg "./web/res/vector-icons/mstile-$d" "$d"
done

svg::png_extended ./talks.hub.zyfra.com_logo.svg "./web/res/vector-icons/620x300" 620 300
svg::png_extended ./talks.hub.zyfra.com_logo.svg "./web/res/vector-icons/1240x600" 1240 600
svg::png_extended ./talks.hub.zyfra.com_logo.svg "./web/res/vector-icons/mstile-310x150" 310 150
