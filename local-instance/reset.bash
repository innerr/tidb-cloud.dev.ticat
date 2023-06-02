set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`
data_dir="${repo_dir}/.ticat/data"

echo "[:-] rm -rf ${data_dir}"
rm -rf "${data_dir}"
echo '[:)] done'
