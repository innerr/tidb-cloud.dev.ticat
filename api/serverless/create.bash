set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env_file="${1}/env"
env=`cat "${env_file}"`
shift

name=`env_val "${env}" 'tidb-cloud.test.current-cluster.name'`
if [ -z "${name}" ]; then
	echo "[:(] arg 'cluster-name' is empty, and also not in env, exit" >&1
	exit 1
fi

cloud_provider=`must_env_val "${env}" 'tidb-cloud.serverless-regional.cloud-provider'`
region_name=`must_env_val "${env}" 'tidb-cloud.serverless-regional.region-name'`
region="${cloud_provider}-${region_name}"

api_addr=`must_env_val "${env}" 'tidb-cloud.api.addr'`

echo "==> CreateServerlessCluster(region: ${region}, cluster_display_name: ${name})"
echo "    ***"
echo "    curl -s -X POST --data '{\"displayName\":\"${name}\",\"region\":{\"name\":\"regions/${region}\"}}' http://${api_addr}/serverless/v1beta1/clusters"

response=`curl -s -w ' %{http_code}' -X POST --data "{\"displayName\":\"${name}\",\"region\":{\"name\":\"regions/${region}\"}}" "http://${api_addr}/serverless/v1beta1/clusters" 2>&1`

echo "    ***"
echo "${response}" | awk '{print "    "$0}'

http_code=`echo "${response}" | awk '{print $NF}'`
if [ "${http_code}" != '200' ]; then
	exit 1
fi

cluster_id=`echo "${response}" | { grep 'cluster_id":"' || test $? = 1; } | awk -F 'cluster_id":"' '{print $2}' | awk -F '"' '{print $1}'`
if [ -z "${cluster_id}" ]; then
	cluster_id=`echo "${response}" | { grep 'clusterId":"' || test $? = 1; } | awk -F 'clusterId":"' '{print $2}' | awk -F '"' '{print $1}'`
fi
if [ ! -z "${cluster_id}" ]; then
	echo "tidb-cloud.test.current-cluster.id=${cluster_id}" >> "${env_file}"
else
	echo "[:(] can't get cluster id from response" >&1
fi
