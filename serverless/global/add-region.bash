set -euo pipefail
. "`cd $(dirname ${BASH_SOURCE[0]}) && pwd`/../../helper/helper.bash"
env=`cat "${1}/env"`

repo_dir=`must_env_val "${env}" 'tidb-cloud.dev.tidb-mgmt.repo-dir'`
provider=`must_env_val "${env}" 'tidb-cloud.serverless-regional.cloud-provider'`
addr=`must_env_val "${env}" 'tidb-cloud.serverless-regional.addr'`

cli_bin="${repo_dir}/bin/serverless-global-service/cli"
if [ ! -f "${cli_bin}" ]; then
	(
		cd "${repo_dir}/serverless-global-service"
		make
	)
fi

cli_sh="${repo_dir}/serverless-global-service/local/cli.sh"

for ((i=0;i<9;++i)); do
	echo "==> ${cli_sh}" provider add --provider="${provider}"
	set +e
	"${cli_sh}" provider add --provider="${provider}"
	rtc="$?"
	set -e
	if [ "${rtc}" == '0' ]; then
		echo "    done"
		break
	else
		echo "    failed"
		sleep 1
	fi
done

for ((i=0;i<9;++i)); do
	echo "==> ${cli_sh}" region add --region-svc-addr "http://${addr}"
	set +e
	"${cli_sh}" region add --region-svc-addr "http://${addr}"
	rtc="$?"
	set -e
	if [ "${rtc}" == '0' ]; then
		echo "    done"
		break
	else
		echo "    failed"
		sleep 1
	fi
done
