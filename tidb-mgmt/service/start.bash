set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

port="${1}"

db_host=`must_env_val "${env}" 'tidb-cloud.global.db.host'`
db_port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`
db_user=`must_env_val "${env}" 'tidb-cloud.global.db.user'`
db_name=`must_env_val "${env}" 'tidb-cloud.tidb-mgmt.db.name'`
serverless_global=`must_env_val "${env}" 'tidb-cloud.serverless-global.addr'`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`

conf_file="${repo_dir}/.ticat/data/tidb-mgmt-service/conf.yaml"
mkdir -p "`dirname ${conf_file}`"

cat << EOF > "${conf_file}"
tiinf:
  localMode: true
  grpc:
    enable: true
    port: ${port}
    withDefault: true
  gin:
    enable: true
    port: 8081
  metrics:
    enable: false
  trace:
    enable: true
  logger:
    enable: true

serverless:
  url: ${serverless_global}
billing:
  url: http://localhost:8081
  local: true

db:
  host: ${db_host}
  port: ${db_port}
  database: ${db_name}
  user: ${db_user}
EOF

svc_bin="${repo_dir}/bin/tidb-mgmt-service/cmd"
if [ ! -f "${svc_bin}" ]; then
	(
		cd "${repo_dir}/tidb-mgmt-service"
		make build
	)
fi

create_db_sql="CREATE DATABASE IF NOT EXISTS ${db_name}"
mysql -h "${db_host}" -P "${db_port}" -u "${db_user}" -e "${create_db_sql}"

# TODO: better bin name
kill_old_service_process 'cmd' "${port}"
"${svc_bin}" --config "${conf_file}"
