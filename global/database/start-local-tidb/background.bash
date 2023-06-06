set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env=`cat "${1}/env"`
shift

timeout="${1}"

host=`must_env_val "${env}" 'tidb-cloud.global.db.host'`
port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`
user=`must_env_val "${env}" 'tidb-cloud.global.db.user'`

for ((i=0; i < ${timeout}; i++)); do
	set +e
	mysql -h "${host}" -P "${port}" -u "${user}" -e "show databases" >/dev/null 2>&1
	set -e
	if [ "${?}" == 0 ]; then
		echo "[:)] mysql '${user}@${host}:${port}' is accessable" >&2
		exit 0
	fi
	echo "[:-] verifying mysql address '${user}@${host}:${port}'" >&2
	sleep 1
done

echo "[:(] access mysql '${user}@${host}:${port}' failed" >&2
exit 1
