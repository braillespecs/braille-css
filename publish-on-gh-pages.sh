#!/usr/bin/env bash
set -x
set -e
CURDIR=$(cd $(dirname "$0") && pwd)
SITE_DIR=$1
GH_REMOTE="git@github.com:snaekobbi/braille-css-spec.git"
DEFAULT_BRANCH=$( git rev-parse --abbrev-ref HEAD )
read -p "branch? (default: $DEFAULT_BRANCH) " BRANCH
[ -z "$BRANCH" ] && BRANCH=$DEFAULT_BRANCH
TMP_DIR=$( mktemp -t "$(basename "$0")" )
rm $TMP_DIR
git clone --branch gh-pages --depth 1 $GH_REMOTE $TMP_DIR
mkdir -p $TMP_DIR/$BRANCH
cp -r $SITE_DIR/* $TMP_DIR/$BRANCH
cat <<- EOF > $TMP_DIR/index.html
	<html xmlns="http://www.w3.org/1999/xhtml">
	  <head>
	    <meta charset="UTF-8"/>
	    <script type="text/javascript">
	      window.location.href = "http://snaekobbi.github.io/braille-css-spec/master/index.html" + window.location.hash
	    </script>
	  </head>
	</html>
EOF
cd $TMP_DIR
git init
git add .
git commit --amend --no-edit
git push --force $GH_REMOTE gh-pages:gh-pages
cd $CURDIR
rm -rf $TMP_DIR
