set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../../../helper/helper.bash"
env=`cat "${1}/env"`
shift

file=`must_env_val "${env}" 'tidb-cloud.tidb-mgmt.portal.logfile'`
cat "${file}"
