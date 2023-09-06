set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env=`cat "${1}/env"`
shift

timeout="${1}"

addr=`must_env_val "${env}" 'tidb-cloud.core-svc.proxy.addr'`
disp_addr="core-svc-proxy '${addr}'"

for ((i=0; i < ${timeout}; i++)); do
	set +e
	# curl should return code 1, message: curl: (1) Received HTTP/0.9 when not allowed
	response=`curl "http://${addr}" 2>&1`
	set -e
	sleep 1
	not_allow=`echo "${response}" | { grep 'not allowed' || test $? = 1; } | wc -l | awk '{print $1}'`
	if [ "${not_allow}" == '1' ]; then
		echo "[:)] ${disp_addr} is accessable" >&2
		exit 0
	fi
	echo "[:-] verifying ${disp_addr}" >&2
done

echo "[:(] access "${disp_addr}" failed" >&2
exit 1
