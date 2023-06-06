set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../../helper/helper.bash"
env=`cat "${1}/env"`
shift

timeout="${1}"

addr=`must_env_val "${env}" 'tidb-cloud.serverless-regional.addr'`
disp_addr="serverless-regional-service 'http://:${addr}'"

for ((i=0; i < ${timeout}; i++)); do
	set +e
	response=`curl -s "http://${addr}/fake-page"`
	set -e
	rtc=`echo "${response}" | awk '{print $1}'`
	if [ "${rtc}" == '404' ]; then
		echo "[:)] ${disp_addr} is accessable" >&2
		exit 0
	fi
	sleep 1
	echo "[:-] verifying ${disp_addr}" >&2
done

echo "[:(] access "${disp_addr}" failed" >&2
exit 1
