set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`
mock_bin="${repo_dir}/bin/serverless-regional-service/mock-serverless-regional-service"
cd "${repo_dir}/serverless-regional-service/mock"
make build
