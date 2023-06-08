set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`
svc_bin="${repo_dir}/bin/tidb-mgmt-portal/cmd"
cd "${repo_dir}/tidb-mgmt-portal"
make build
