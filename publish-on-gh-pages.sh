set -x
set -e
CURDIR=$(cd $(dirname "$0") && pwd)
SITE_DIR=$1
GH_REMOTE=$2
TMP_DIR=$( mktemp )
rm $TMP_DIR
cp -r $SITE_DIR $TMP_DIR
cd $TMP_DIR
git init
git add . && git commit -m "publish site"
git push --force $GH_REMOTE master:gh-pages
cd $CURDIR
rm -rf $TMP_DIR
