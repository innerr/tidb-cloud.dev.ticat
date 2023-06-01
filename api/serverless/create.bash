set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

if [ -z "${1+x}" ] || [ -z "${1}" ]; then
	echo "[:(] arg 'cluster-name' is empty" >&1
	exit 1
fi
name="${1}"

cloud_provider=`must_env_val "${env}" 'tidb-cloud.serverless-regional.cloud-provider'`
region_name=`must_env_val "${env}" 'tidb-cloud.serverless-regional.region-name'`
region="${cloud_provider}-${region_name}"

api_addr=`must_env_val "${env}" 'tidb-cloud.api.addr'`

echo "==> CreateServerlessCluster(region: ${region}, cluster name: ${name})"
echo "    curl -s -X POST --data '{\"displayName\":\"${name}\",\"region\":\"regions/${region}\"}' http://${api_addr}/serverless/v1/clusters"
curl -s -X POST --data "{\"displayName\":\"${name}\",\"region\":\"regions/${region}\"}" "http://${api_addr}/serverless/v1/clusters"
echo
