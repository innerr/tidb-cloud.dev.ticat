set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env_file="${1}/env"
shift

match_str="${1}"
log_file=`get_cmd_logfile_from_session "${env_file}" "${match_str}" 'core-svc.proxy.start' 'core-svc-proxy'`
if [ -z "${log_file}" ]; then
	exit 1
fi

echo "tidb-cloud.core-svc.proxy.logfile=${log_file}" >> "${env_file}"
echo "${log_file}"
