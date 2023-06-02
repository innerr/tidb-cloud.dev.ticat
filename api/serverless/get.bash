set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

cluster_id=`must_env_val "${env}" 'tidb-cloud.test.current-cluster.id'`
api_addr=`must_env_val "${env}" 'tidb-cloud.api.addr'`

echo "==> GetServerlessCluster(cluster id: ${cluster_id})"
echo "    curl -s http://${api_addr}/serverless/v1/clusters/${cluster_id}"
curl -s "http://${api_addr}/serverless/v1/clusters/${cluster_id}"
echo
