set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

port="${1}"

tidb_mgmt_addr=`must_env_val "${env}" 'tidb-cloud.tidb-mgmt.service.addr'`
repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`

conf_file="${repo_dir}/.ticat/data/tidb-mgmt-portal/conf.yaml"
mkdir -p "`dirname ${conf_file}`"

cat << EOF > "${conf_file}"
tiinf:
  localMode: true
  grpc:
    enable: false
  gin:
    enable: true
    port: ${port}
  metrics:
    enable: true
    port: 9091
  trace:
    enable: true
  logger:
    enable: true
    sentryDsn:
    sentryEnv: nightly-ms
tidbMgmtService:
  address: ${tidb_mgmt_addr}
accountService:
  localMode: true
auth:
  localMode: true
EOF

svc_bin="${repo_dir}/bin/tidb-mgmt-portal/cmd"
if [ ! -f "${svc_bin}" ]; then
	(
		cd "${repo_dir}/tidb-mgmt-portal"
		make build
	)
fi

# TODO: better bin name
kill_old_service_process 'cmd' "${port}"
"${svc_bin}" --config "${conf_file}"
