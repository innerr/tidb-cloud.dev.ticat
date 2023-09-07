set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env=`cat "${1}/env"`
shift

cluster_id=`must_env_val "${env}" 'tidb-cloud.test.current-cluster.id'`

job_type="${2}"
if [ "${job_type}" == 'restore' ]; then
	job_type='9'
elif [ "${job_type}" == 'cdc' ]; then
	job_type='5'
else
	echo "[:(] arg job-type "${job_type}" is invalid" >&2
	exit 1
fi

job_name="${cluster_id}-${job_type}"

core_svc_proxy_addr=`must_env_val "${env}" 'tidb-cloud.core-svc.proxy.addr'`
set -x
grpcurl -plaintext -d "{\"cluster_id\":${cluster_id}, \"job_type\":${job_type}, \"name\":\"${job_name}\"}" \
	"${core_svc_proxy_addr}" core.CoreService/CreateClusterJob
