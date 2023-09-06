set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

port="${1}"

core_svc_addr=`must_env_val "${env}" 'tidb-cloud.core-svc.addr'`
mgmt_svc_addr=`must_env_val "${env}" 'tidb-cloud.tidb-mgmt.service.addr'`
serverless_global_addr=`must_env_val "${env}" 'tidb-cloud.serverless-global.addr'`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`

conf_file="${repo_dir}/.ticat/data/tempo-proxy/conf.yaml"
mkdir -p "`dirname ${conf_file}`"

cat << EOF > "${conf_file}"
tiinf:
  localMode: true
  grpc:
    enable: true
    port: ${port}
  metrics:
    enable: false
  gin:
    enable: false
  trace:
    enable: true
  logger:
    enable: true
    sentryDsn:
    sentryEnv: tidb-management-service
server:
  coreSvcAddr: "${core_svc_addr}"
  tiDBMgmtAddr: "${mgmt_svc_addr}"
  serverlessGlobalAddr: "${serverless_global_addr}"
  k8sNamespacePrefix: "nightly-ms"
  allowList:
    oneConfigName: dummy
    reloadInterval: 60
  toTiDBMgmtMethods:
    - "ChangeClusterPasswd"
    - "CreateDBUser"
    - "UpdateDBUser"
    - "ListDBUsers"
    - "DeleteDBUser"
    - "GetDBUser"
    - "IsDBUserExisting"
    - "CreateDBRole"
    - "UpdateDBRole"
    - "SetClusterAuthPubKey"
    - "ListClusters"
    - "GetClusterConfidentialInfo"
    - "CreateClusterJob"
    - "DeleteClusterJob"
    - "IsClusterJobRegistered"
    - "ListClusterJobs"
EOF

svr_bin="${repo_dir}/bin/tempo-proxy/tempo-proxy"
if [ ! -f "${svr_bin}" ]; then
	(
		cd "${repo_dir}/tempo-proxy"
		make build
	)
fi

kill_old_service_process 'tempo-proxy' "${port}"
"${svr_bin}" --config="${conf_file}"
