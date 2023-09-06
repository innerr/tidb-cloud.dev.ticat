set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

port="${1}"

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`

svr_bin="${repo_dir}/bin/tempo-proxy/mock-core-svc"
if [ ! -f "${svr_bin}" ]; then
	(
		cd "${repo_dir}/tempo-proxy/mock-core-svc"
		make build
	)
fi

kill_old_service_process 'mock-core-svc' "${port}"
"${svr_bin}" --port "${port}"
