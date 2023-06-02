set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`

grpc_port=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.grpc.port'`
http_port=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.http.port'`

db_path=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.db-path'`
if [ "${db_path:0:1}" != '/' ] && [ "${db_path:0:1}" != '\' ]; then
	db_path="${repo_dir}/${db_path}"
fi

create_ver=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.cluster-create-version'`
region=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.region-name'`
region_display=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.region-display-name'`
cloud_provider=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.cloud-provider'`

create_secs=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.sim-secs.create'`
update_secs=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.sim-secs.update'`
delete_secs=`must_env_val "${env}" 'tidb-cloud.serverless-regional.mock.sim-secs.delete'`

conf_file="${repo_dir}/.ticat/data/serverless-regional-service/mock/conf.yaml"
mkdir -p "`dirname ${conf_file}`"

cat << EOF > "${conf_file}"
server:
  grpc:
    port: ${grpc_port}
  http:
    port: ${http_port}
  db: ${db_path}
  cluster_create_version: ${create_ver}
  region:
    name: ${region}
    display_name: ${region_display}
    cloud_provider: ${cloud_provider}
  simulative_cost:
    create_secs: ${create_secs}
    update_secs: ${update_secs}
    delete_secs: ${delete_secs}
EOF


mock_bin="${repo_dir}/bin/mock-serverless-regional"
if [ ! -f "${mock_bin}" ]; then
	(
		cd "${repo_dir}/mock/serverless_regional_service"
		make build
	)
fi

mkdir -p "`dirname ${db_path}`"
"${mock_bin}" -config "${conf_file}"
