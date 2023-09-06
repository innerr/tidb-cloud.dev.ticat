set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`
svr_bin="${repo_dir}/tempo-proxy/tempo-proxy"
cd "${repo_dir}/tempo-proxy"
make build
