#!/bin/bash
#
# shallow checkoutされたブランチを、base branchとの分岐地点まで遡ってcheckoutする
# base branchが指定されていない場合、GitHub APIから取得する（要 GITHUB_API_TOKEN）
#

USAGE=$(cat <<'USAGE'
Usage:
       git-deepen.sh -p <PR NUMBER> -r abema/abema-ios-tutorial-public
   or
       git-deepen.sh -b <BASE BRANCH> -r abema/abema-ios-tutorial-public
USAGE
)

set -euo pipefail

PULL_REQUEST_NUMBER=
BASE_BRANCH=
REPO=

while getopts p:b:r: OPT
do
  case $OPT in
    "p" ) PULL_REQUEST_NUMBER="$OPTARG" ;;
    "b" ) BASE_BRANCH="$OPTARG" ;;
    "r" ) REPO="$OPTARG" ;;
  esac
done

if [ -z "$REPO" ]; then
    echo "error: specify repository owner and name" >&2
    echo "$USAGE" >&2
    exit 1
fi

if [ -z "$PULL_REQUEST_NUMBER" ] && [ -z "$BASE_BRANCH" ]; then
    echo "error: specify PR number (-p) or the base branch name (-b)" >&2
    echo "$USAGE" >&2
    exit 1
fi

REPO_OWNER=$(cut -d'/' -f1 <<<$REPO)
REPO_NAME=$(cut -d'/' -f2 <<<$REPO)

if [ -n "$PULL_REQUEST_NUMBER" ] && [ -z "$BASE_BRANCH" ]; then
    QUERY=$(cat <<EOS
{
    "query": "query {
            repository(
                owner: \\"$REPO_OWNER\\",
                name: \\"$REPO_NAME\\"
            ) {
                    pullRequest(number: $(basename $PULL_REQUEST_NUMBER)) {
                            baseRef {
                                    name
                            }
                    }
            }
    }"
}
EOS
)

    echo "Calling GitHub API: $QUERY" >&2

    QUERY_RESULT=$(
        echo $QUERY \
        | curl -Ss -X POST https://api.github.com/graphql \
            -H "Authorization: bearer $GITHUB_API_TOKEN" \
            -d @-
    )

    echo "==> $QUERY_RESULT" >&2

    BASE_BRANCH=$(
        echo $QUERY_RESULT \
        | sed -nE 's/{"data":{"repository":{"pullRequest":{"baseRef":{"name":"(.+)"}}}}}/\1/p'
    )

    echo "Fetched target branch: $BASE_BRANCH" >&2
fi

if [ -z "$BASE_BRANCH" ]; then
    echo "The target branch not found; skipping" >&2
else
    BRANCH=$(git branch --show-current)
    git config --local --add remote.origin.fetch +refs/heads/$BASE_BRANCH:refs/remotes/origin/$BASE_BRANCH
    git fetch --depth=1 origin $BASE_BRANCH
    while [ -z "$(git merge-base $BRANCH origin/$BASE_BRANCH || true)" ]; do
        echo "Fetching an additional commit..." >&2
        git fetch -q --deepen=1
    done
fi
