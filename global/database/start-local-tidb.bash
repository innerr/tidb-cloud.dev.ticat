set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`

db_port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`

# TODO: use kill_old_service_process()
old_pids=`ps -ef`
old_pids=`echo "${old_pids}" | \
	{ grep 'tidb-server' || test $? = 1; } | \
	{ grep "\-P ${db_port}" || test $? = 1; } | \
	{ grep '\-host=127.0.0.1' || test $? = 1; } |\
	awk '{print $2}'`
if [ ! -z "${old_pids}" ]; then
	echo "[:-] killing old pids:"
	echo "${old_pids}" | while read old_id; do
		echo "     ${old_id} (tidb-server@${db_port})"
		kill -9 "${old_id}"
	done
fi

echo "[:-] starting tiup playground:"
tiup playground v6.1.0 --db.port "${db_port}" --tiflash 0 --without-monitor
