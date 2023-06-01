set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env=`cat "${1}/env"`
shift

host=`must_env_val "${env}" 'tidb-cloud.global.db.host'`
port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`
user=`must_env_val "${env}" 'tidb-cloud.global.db.user'`

timeout="${2}"

for ((i=0; i < ${timeout}; i++)); do
	set +e
	mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
	if [ "${?}" == 0 ]; then
		set -e
		exit 0
	fi
	sleep 1
	echo "[:-] verifying mysql address '${user}@${host}:${port}'"
done

echo "[:(] access mysql '${user}@${host}:${port}' failed" >&2
exit 1
