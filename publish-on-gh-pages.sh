#!/usr/bin/env bash
set -x
set -e
CURDIR=$(cd $(dirname "$0") && pwd)
SITE_DIR=$1
GH_REMOTE="git@github.com:braillespecs/braille-css.git"
BRANCH=$( git rev-parse --abbrev-ref HEAD )
if [ -z "$( git status --porcelain )" ]; then
	TAG=$( git tag --contains=HEAD )
fi
if [ -n "$TAG" ]; then
	DEFAULT_VERSION=$TAG
else
	DEFAULT_VERSION=$BRANCH
fi
read -p "Version? (default: $DEFAULT_VERSION) " VERSION
[ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION
LATEST=$( git tag --list | tail -n1 )
[ -z "$LATEST" ] && LATEST=master
TMP_DIR=$( mktemp -t "$(basename "$0")" )
rm $TMP_DIR
git clone --branch gh-pages --depth 1 $GH_REMOTE $TMP_DIR
mkdir -p $TMP_DIR/$VERSION
cp -r $SITE_DIR/* $TMP_DIR/$VERSION
pages=( index obfl text-transform )
for page in ${pages[@]}; do
	if [ $page == index ]; then
		redirect="http://braillespecs.github.io/braille-css/${LATEST}"
	else
		redirect="http://braillespecs.github.io/braille-css/${LATEST}/${page}"
	fi
	cat <<- EOF > $TMP_DIR/${page}.html
		<html xmlns="http://www.w3.org/1999/xhtml">
		  <head>
		    <meta charset="UTF-8"/>
		    <script type="text/javascript">
		      window.location.href = "$redirect" + window.location.hash
		    </script>
		  </head>
		</html>
	EOF
done
cd $TMP_DIR
git add .
git commit --amend --no-edit
git push --force $GH_REMOTE gh-pages:gh-pages
cd $CURDIR
rm -rf $TMP_DIR
