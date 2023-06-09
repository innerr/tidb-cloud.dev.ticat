set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat ${1}/env`
shift

host=`must_env_val "${env}" 'tidb-cloud.global.db.host'`
port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`
user=`must_env_val "${env}" 'tidb-cloud.global.db.user'`

query="${1}"
db="${2}"
fmt="${3}"
warn=`to_true "${4}"`

if [ -z "${query}" ]; then
	echo "[:(] no arg 'query', alias 'q|Q'" >&2
	exit 1
fi

if [ ! -z "${db}" ]; then
	db=" --database=${db}"
else
	db=''
fi

if [ "${fmt}" == 'v' ]; then
	fmt=' --vertical'
fi
if [ "${fmt}" == 'tab' ]; then
	fmt=' --batch'
fi
if [ "${fmt}" == 't' ]; then
	fmt=' --table'
fi
if [ -z "${fmt}" ]; then
	fmt=' --table'
fi

if [ "${warn}" == 'true' ]; then
	warn=' --show-warnings'
else
	warn=''
fi

mysql -h "${host}" -P "${port}" -u "${user}" --comments${db}${fmt}${warn} -e "${query}"
