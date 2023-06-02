set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

if [ -z "${1+x}" ] || [ -z "${1}" ]; then
	echo "[:(] arg 'cluster-name' is empty" >&1
	exit 1
fi
name="${1}"

api_addr=`must_env_val "${env}" 'tidb-cloud.api.addr'`

echo "==> DeleteServerlessCluster(cluster name: ${name})"
echo "    curl -s -X DELETE http://${api_addr}/serverless/v1/clusters/${name}"
curl -s -X DELETE "http://${api_addr}/serverless/v1/clusters/${name}"
echo
