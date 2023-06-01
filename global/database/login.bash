set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"

env=`cat ${1}/env`
shift

host=`must_env_val "${env}" 'tidb-cloud.global.db.host'`
port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`
user=`must_env_val "${env}" 'tidb-cloud.global.db.user'`

db="${1}"
if [ ! -z "${db}" ]; then
	db=" --database=${db}"
else
	db=''
fi

echo mysql -h "${host}" -P "${port}" -u "${user}" --comments${db}
mysql -h "${host}" -P "${port}" -u "${user}" --comments${db}
