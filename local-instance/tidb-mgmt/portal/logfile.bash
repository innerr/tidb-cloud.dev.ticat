set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env_file="${1}/env"
env=`cat "${env_file}"`
shift

match_str="${1}"
ticat=`must_env_val "${env}" 'sys.paths.ticat'`

session_id=`"${ticat}" display.quiet : display.plain : session.running "${match_str}" |\
	{ grep -v 'display.plain : session.running' || test $? = 1; } |\
	{ grep "${match_str}" -B 2 || test $? = 1; } |\
	head -n 1`
if [ -z "${session_id}" ]; then
	echo "[:(] can't find session by '${match_str}'" >&2
	exit 1
fi

log_file=`"${ticat}" display.quiet : display.plain : display.width 9999 : session.desc "${session_id}" |\
	{ grep '\[tidb-mgmt.portal.start\]' -A 4 || test $? = 1; } |\
	{ grep 'execute-log' -A 1 || test $? = 1; } |\
	tail -n 1 |\
	awk '{print $1}'`
if [ -z "${log_file}" ]; then
	echo "[:(] can't find log path of tidb-mgmt-portal in session ${session_id}" >&2
	exit 1
fi

echo "tidb-cloud.tidb-mgmt.portal.logfile=${log_file}" >> "${env_file}"
echo "${log_file}"
