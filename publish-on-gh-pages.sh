#!/usr/bin/env bash
set -x
set -e
CURDIR=$(cd $(dirname "$0") && pwd)
SITE_DIR=$1
if [ -n "$GITHUB_TOKEN" ]; then
	GH_REMOTE="https://${GITHUB_TOKEN}@github.com/braillespecs/braille-css.git"
else
	GH_REMOTE="git@github.com:braillespecs/braille-css.git"
fi
BRANCH=$( git rev-parse --abbrev-ref HEAD )
if [ -n "$( git status --porcelain )" ]; then
	echo "Dirty working tree. Not publishing" >&2
	exit
fi
TAG=$( git tag --contains=HEAD )
if [ -z "$TAG" ]; then
	echo "Current revision is not a tag. Not publishing" >&2
	exit
fi
DEFAULT_VERSION=$TAG
if [ -t 0 ]; then
	read -p "Version? (default: $DEFAULT_VERSION) " VERSION
fi
[ -z "$VERSION" ] && VERSION=$DEFAULT_VERSION
LATEST=$( git tag --list | tail -n1 )
[ -z "$LATEST" ] && LATEST=master
TMP_DIR=$( mktemp -d "${TMPDIR:-/tmp}/$(basename "$0").XXXXXXXXX" )
rm -r $TMP_DIR
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
if [ -n "$GITHUB_TOKEN" ]; then
	git config user.name "Github CI"
	git config user.email "braille-css@users.noreply.github.com"
fi
git commit --amend --no-edit
git push --force $GH_REMOTE gh-pages:gh-pages
cd $CURDIR
rm -rf $TMP_DIR
