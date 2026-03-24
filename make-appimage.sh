#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q displaycal | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/displaycal.png
export DESKTOP=/usr/share/applications/displaycal.desktop
export DEPLOY_PYTHON=1
export DEPLOY_SDL=1

# we have to passs a ton of binaries from the argyllcms package
bins='
	applycal average cb2ti3 cctiff ccxxmake chartread collink colprof
	colverify cxf2ti3 dispcal dispread dispwin extracticc extractttag
	fakeCMY fakeread greytiff iccdump iccgamut icclu iccvcgt illumread
	invprofcheck kodak2ti3 ls2ti3 mppcheck mpplu mppprof oeminst printcal
	printtarg profcheck refine revfix scanin spec2cie specplot splitti3
	spotread synthcal synthread targen tiffgamut timage txt2ti3 viewgam xicclu
'
set --
for bin in $bins; do
	set -- /usr/bin/"$bin" "$@"
done

# Deploy dependencies
quick-sharun \
	/usr/bin/displaycal*  \
	/usr/lib/libcblas.so* \
	/usr/share/DisplayCAL \
	/usr/share/argyllcms  \
	"$@"


# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
