set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

cluster_id=`must_env_val "${env}" 'tidb-cloud.test.current-cluster.id'`
api_addr=`must_env_val "${env}" 'tidb-cloud.api.addr'`

echo "==> DeleteServerlessCluster(cluster_id: ${cluster_id})"
echo "    ***"
echo "    curl -s -X DELETE http://${api_addr}/serverless/v1beta1/clusters/${cluster_id}"

response=`curl -s -w ' %{http_code}' -X DELETE "http://${api_addr}/serverless/v1beta1/clusters/${cluster_id}" 2>&1`

echo "    ***"
echo "${response}" | awk '{print "    "$0}'

http_code=`echo "${response}" | awk '{print $NF}'`
if [ "${http_code}" != '200' ]; then
	exit 1
fi
