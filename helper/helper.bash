. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/bash.helper/helper.bash"

function get_cmd_logfile_from_session()
{
	local env_file="${1}"
	local session_match_str="${2}"
	local cmd="${3}"
	local cmd_display_name="${3}"

	local env=`cat "${env_file}"`
	local ticat=`must_env_val "${env}" 'sys.paths.ticat'`

	local session_id=`"${ticat}" display.quiet : display.plain : session.running "${session_match_str}" |\
		{ grep -v 'display.plain : session.running' || test $? = 1; } |\
		{ grep "${session_match_str}" -B 2 || test $? = 1; } |\
		{ grep '^\[' || test $? = 1; }`
	if [ -z "${session_id}" ]; then
		echo "[:(] can't find session by '${session_match_str}'" >&2
		return 1
	fi
	local matched_cnt=`echo "${session_id}" | wc -l | awk '{print $1}'`
	if [ "${matched_cnt}" != '1' ]; then
		echo "[:(] too match sessions matched by '${session_match_str}'" >&2
		return 1
	fi

	local log_file=`"${ticat}" display.quiet : display.plain : display.width 9999 : session.desc "${session_id}" |\
		{ grep "_${cmd}_" || test $? = 1; } |\
		awk '{print $1}'`
	if [ -z "${log_file}" ]; then
		echo "[:(] can't find log path of ${cmd_display_name} in session ${session_id}" >&2
		return 1
	fi
	echo "${log_file}"
}

function kill_old_service_process()
{
	local cmd_name="${1}"
	local listen_port="${2}"

	local all_listen=`lsof -nP | grep LIST | grep TCP | awk '{print $1, $2, $(NF-1)}' | sort | uniq`
	if [ -z "${all_listen}" ]; then
		return 0
	fi

	echo "[:-] all local listening process:" >&2
	echo "${all_listen}" | awk '{print "     "$0}' >&2

	local old_pids=`echo "${all_listen}" | \
		{ grep ":${listen_port}$" || test $? = 1; } | \
		awk '{ if ($1=="'${cmd_name}'") {print $2} }'`

	if [ -z "${old_pids}" ]; then
		echo "[:)] no old process found" >&2
		return 0
	fi

	echo "[:-] killing old processes:"
	echo "${old_pids}" | while read old_id; do
		echo "     ${old_id} (${cmd_name}@${listen_port})"
		kill -9 "${old_id}"
		sleep 1
	done
	echo "[:)] done" >&2
}
