set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`
shift

port="${1}"

timeout=`must_env_val "${env}" 'tidb-cloud.serverless-global.conn-regional.timeout-secs'`
retry=`must_env_val "${env}" 'tidb-cloud.serverless-global.conn-regional.retry'`
db_host=`must_env_val "${env}" 'tidb-cloud.global.db.host'`
db_port=`must_env_val "${env}" 'tidb-cloud.global.db.port'`
db_user=`must_env_val "${env}" 'tidb-cloud.global.db.user'`
db_name=`must_env_val "${env}" 'tidb-cloud.serverless-global.db.name'`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`

conf_file="${repo_dir}/.ticat/data/serverless-global-service/conf.yaml"
mkdir -p "`dirname ${conf_file}`"

cat << EOF > "${conf_file}"
tiinf:
  localMode: true
  grpc:
    enable: true
    port: ${port}
    withDefault: true
  gin:
    enable: false
  metrics:
    enable: true
    port: 9093
  trace:
    enable: true
  logger:
    enable: true
    sentryDsn:
    sentryEnv: nightly-ms

infra:
  cmkArn: sdf

regionalserver:
  requestTimeoutInSec: ${timeout}
  retryWaitTimeoutInSec: 1
  retryCount: ${retry}

mysql:
  host: ${db_host}
  user: ${db_user}
  port: ${db_port}
  database: ${db_name}
  tlsConfigKey: skip-verify

proxy:
  auth0Domain: domain
  auth0ClientID: id
  auth0ClientSecret: auth
  auth0Audience: auth
aws:
  pcaArn: arn
EOF

svr_bin="${repo_dir}/bin/serverless-global-service/cmd"
if [ ! -f "${svr_bin}" ]; then
	(
		cd "${repo_dir}/serverless-global-service"
		make build
	)
fi

create_db_sql="CREATE DATABASE IF NOT EXISTS ${db_name}"
retry_times='9'
for ((i=1; i < ${timeout}; i++)); do
	set +e
	mysql -h "${db_host}" -P "${db_port}" -u "${db_user}" -e "${create_db_sql}"
	ret="$?"
	set -e
	if [ "${ret}" == '0' ]; then
		echo "[:)] database is accessible" >&2
		break
	fi
	if [ "${i}" == "${retry_times}" ]; then
		echo "[:(] failed to connect to database" >&2
		exit 1
	else
		echo "[:(] failed to connect to database, retry" >&2
	fi
	sleep 1
done

# TODO: better bin name
kill_old_service_process 'cmd' "${port}"
"${svr_bin}" serve --mock=true --config="${conf_file}"
