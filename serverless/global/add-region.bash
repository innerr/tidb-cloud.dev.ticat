set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`
provider=`must_env_val "${env}" 'tidb-cloud.serverless-regional.cloud-provider'`
addr=`must_env_val "${env}" 'tidb-cloud.serverless-regional.addr'`

cli_bin="${repo_dir}/serverless-global-service/local/cli.sh"

echo "==> ${cli_bin}" provider add --provider="${provider}"
"${cli_bin}" provider add --provider="${provider}"
echo "==> ${cli_bin}" region add --region-svc-addr "http://${addr}"
"${cli_bin}" region add --region-svc-addr "http://${addr}"
