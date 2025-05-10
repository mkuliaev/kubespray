#!/bin/bash
set -euxo pipefail

<<<<<<< HEAD
if [[ -v TESTCASE ]]; then
    TESTCASE_FILE=files/${TESTCASE}.yml
else
    TESTCASE_FILE=common_vars.yml
    TESTCASE=default
fi

echo "TESTCASE is $TESTCASE"

source tests/files/$TESTCASE || true

# Check out latest tag if testing upgrade
if [ "${UPGRADE_TEST}" != "false" ]; then
  git fetch --all && git checkout $(git describe --tags --abbrev=0)
  # Checkout the current tests/ directory ; even when testing old version,
  # we want the up-to-date test setup/provisionning
  git checkout "${CI_COMMIT_SHA}" -- tests/
fi

export ANSIBLE_BECOME=true
export ANSIBLE_BECOME_USER=root
=======
echo "CI_JOB_NAME is $CI_JOB_NAME"
CI_TEST_ADDITIONAL_VARS=""

if [[ "$CI_JOB_NAME" =~ "upgrade" ]]; then
  if [ "${UPGRADE_TEST}" == "false" ]; then
    echo "Job name contains 'upgrade', but UPGRADE_TEST='false'"
    exit 1
  fi
else
  if [ "${UPGRADE_TEST}" != "false" ]; then
    echo "UPGRADE_TEST!='false', but job names does not contain 'upgrade'"
    exit 1
  fi
fi

# needed for ara not to complain
export TZ=UTC

export ANSIBLE_REMOTE_USER=$SSH_USER
export ANSIBLE_BECOME=true
export ANSIBLE_BECOME_USER=root
export ANSIBLE_CALLBACK_PLUGINS="$(python -m ara.setup.callback_plugins)"

cd tests && make create-${CI_PLATFORM} -s ; cd -
ansible-playbook tests/cloud_playbooks/wait-for-ssh.yml

# Flatcar Container Linux needs auto update disabled
if [[ "$CI_JOB_NAME" =~ "coreos" ]]; then
  ansible all -m raw -a 'systemctl disable locksmithd'
  ansible all -m raw -a 'systemctl stop locksmithd'
  mkdir -p /opt/bin && ln -s /usr/bin/python /opt/bin/python
fi

if [[ "$CI_JOB_NAME" =~ "opensuse" ]]; then
  # OpenSUSE needs netconfig update to get correct resolv.conf
  # See https://goinggnu.wordpress.com/2013/10/14/how-to-fix-the-dns-in-opensuse-13-1/
  ansible all -m raw -a 'netconfig update -f'
  # Auto import repo keys
  ansible all -m raw -a 'zypper --gpg-auto-import-keys refresh'
fi

if [[ "$CI_JOB_NAME" =~ "ubuntu" ]]; then
  # We need to tell ansible that ubuntu hosts are python3 only
  CI_TEST_ADDITIONAL_VARS="-e ansible_python_interpreter=/usr/bin/python3"
fi

ENABLE_020_TEST="true"
ENABLE_030_TEST="true"
ENABLE_040_TEST="true"
if [[ "$CI_JOB_NAME" =~ "macvlan" ]]; then
  ENABLE_020_TEST="false"
  ENABLE_030_TEST="false"
  ENABLE_040_TEST="false"
fi

if [[ "$CI_JOB_NAME" =~ "hardening" ]]; then
  # TODO: We need to remove this condition by finding alternative container
  # image instead of netchecker which doesn't work at hardening environments.
  ENABLE_040_TEST="false"
fi

# Check out latest tag if testing upgrade
test "${UPGRADE_TEST}" != "false" && git fetch --all && git checkout "$KUBESPRAY_VERSION"
# Checkout the CI vars file so it is available
test "${UPGRADE_TEST}" != "false" && git checkout "${CI_COMMIT_SHA}" tests/files/${CI_JOB_NAME}.yml
test "${UPGRADE_TEST}" != "false" && git checkout "${CI_COMMIT_SHA}" ${CI_TEST_REGISTRY_MIRROR}
test "${UPGRADE_TEST}" != "false" && git checkout "${CI_COMMIT_SHA}" ${CI_TEST_SETTING}

# Create cluster
ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} -e @${CI_TEST_VARS} -e local_release_dir=${PWD}/downloads --limit "all:!fake_hosts" cluster.yml

# Repeat deployment if testing upgrade
if [ "${UPGRADE_TEST}" != "false" ]; then
  test "${UPGRADE_TEST}" == "basic" && PLAYBOOK="cluster.yml"
  test "${UPGRADE_TEST}" == "graceful" && PLAYBOOK="upgrade-cluster.yml"
  git checkout "${CI_COMMIT_SHA}"
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} -e @${CI_TEST_VARS} -e local_release_dir=${PWD}/downloads --limit "all:!fake_hosts" $PLAYBOOK
fi

# Test control plane recovery
if [ "${RECOVER_CONTROL_PLANE_TEST}" != "false" ]; then
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} -e @${CI_TEST_VARS} -e local_release_dir=${PWD}/downloads --limit "${RECOVER_CONTROL_PLANE_TEST_GROUPS}:!fake_hosts" -e reset_confirmation=yes reset.yml
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} -e @${CI_TEST_VARS} -e local_release_dir=${PWD}/downloads -e etcd_retries=10 --limit "etcd:kube_control_plane:!fake_hosts" recover-control-plane.yml
fi
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))

# Test collection build and install by installing our collection, emptying our repository, adding
# cluster.yml, reset.yml, and remote-node.yml files that simply point to our collection's playbooks, and then
# running the same tests as before
<<<<<<< HEAD
if [[ "${TESTCASE}" =~ "collection" ]]; then
=======
if [[ "${CI_JOB_NAME}" =~ "collection" ]]; then
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
  # Build and install collection
  ansible-galaxy collection build
  ansible-galaxy collection install kubernetes_sigs-kubespray-$(grep "^version:" galaxy.yml | awk '{print $2}').tar.gz

  # Simply remove all of our files and directories except for our tests directory
  # to be absolutely certain that none of our playbooks or roles
  # are interfering with our collection
<<<<<<< HEAD
  find -mindepth 1 -maxdepth 1 ! -regex './\(tests\|inventory\)' -exec rm -rfv {} +

=======
  find -maxdepth 1 ! -name tests -exec rm -rfv {} \;

  # Write cluster.yml
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
cat > cluster.yml <<EOF
- name: Install Kubernetes
  ansible.builtin.import_playbook: kubernetes_sigs.kubespray.cluster
EOF

<<<<<<< HEAD
cat > upgrade-cluster.yml <<EOF
- name: Install Kubernetes
  ansible.builtin.import_playbook: kubernetes_sigs.kubespray.upgrade-cluster
EOF

=======
  # Write reset.yml
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
cat > reset.yml <<EOF
- name: Remove Kubernetes
  ansible.builtin.import_playbook: kubernetes_sigs.kubespray.reset
EOF

<<<<<<< HEAD
cat > remove-node.yml <<EOF
- name: Remove node from Kubernetes
  ansible.builtin.import_playbook: kubernetes_sigs.kubespray.remove_node
=======
  # Write remove-node.yml
cat > remove-node.yml <<EOF
- name: Remove node from Kubernetes
  ansible.builtin.import_playbook: kubernetes_sigs.kubespray.remote-node
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
EOF

fi

<<<<<<< HEAD
run_playbook () {
playbook=$1
shift
ansible-playbook \
    -e @tests/common_vars.yml \
    -e @tests/${TESTCASE_FILE} \
    -e local_release_dir=${PWD}/downloads \
    "$@" \
    ${playbook}
}



## START KUBESPRAY

# Create cluster
run_playbook cluster.yml

# Repeat deployment if testing upgrade
if [ "${UPGRADE_TEST}" != "false" ]; then
  git checkout "${CI_COMMIT_SHA}"

  case "${UPGRADE_TEST}" in
    "basic")
        run_playbook cluster.yml
        ;;
    "graceful")
        run_playbook upgrade-cluster.yml
        ;;
    *)
        ;;
  esac
fi

# Test control plane recovery
if [ "${RECOVER_CONTROL_PLANE_TEST}" != "false" ]; then
    run_playbook reset.yml --limit "${RECOVER_CONTROL_PLANE_TEST_GROUPS}" -e reset_confirmation=yes
    run_playbook recover-control-plane.yml -e etcd_retries=10 --limit "etcd:kube_control_plane"
fi

# Tests Cases
## Test Control Plane API
run_playbook tests/testcases/010_check-apiserver.yml
run_playbook tests/testcases/015_check-nodes-ready.yml

## Test that all nodes are Ready

if [[ ! ( "$TESTCASE" =~ "macvlan" ) ]]; then
    run_playbook tests/testcases/020_check-pods-running.yml
    run_playbook tests/testcases/030_check-network.yml
    if [[ ! ( "$TESTCASE" =~ "hardening" ) ]]; then
      # TODO: We need to remove this condition by finding alternative container
      # image instead of netchecker which doesn't work at hardening environments.
      run_playbook tests/testcases/040_check-network-adv.yml
    fi
fi

## Kubernetes conformance tests
run_playbook tests/testcases/100_check-k8s-conformance.yml

# Test node removal procedure
if [ "${REMOVE_NODE_CHECK}" = "true" ]; then
  run_playbook remove-node.yml -e skip_confirmation=yes -e node=${REMOVE_NODE_NAME}
=======
# Tests Cases
## Test Master API
ansible-playbook --limit "all:!fake_hosts" -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} tests/testcases/010_check-apiserver.yml $ANSIBLE_LOG_LEVEL

## Test that all nodes are Ready
ansible-playbook --limit "all:!fake_hosts" -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} tests/testcases/015_check-nodes-ready.yml $ANSIBLE_LOG_LEVEL

## Test that all pods are Running
if [ "${ENABLE_020_TEST}" = "true" ]; then
ansible-playbook --limit "all:!fake_hosts" -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} tests/testcases/020_check-pods-running.yml $ANSIBLE_LOG_LEVEL
fi

## Test pod creation and ping between them
if [ "${ENABLE_030_TEST}" = "true" ]; then
ansible-playbook --limit "all:!fake_hosts" -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} tests/testcases/030_check-network.yml $ANSIBLE_LOG_LEVEL
fi

## Advanced DNS checks
if [ "${ENABLE_040_TEST}" = "true" ]; then
  ansible-playbook --limit "all:!fake_hosts" -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} tests/testcases/040_check-network-adv.yml $ANSIBLE_LOG_LEVEL
fi

## Kubernetes conformance tests
ansible-playbook -i ${ANSIBLE_INVENTORY} -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} --limit "all:!fake_hosts" tests/testcases/100_check-k8s-conformance.yml $ANSIBLE_LOG_LEVEL

if [ "${IDEMPOT_CHECK}" = "true" ]; then
  ## Idempotency checks 1/5 (repeat deployment)
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} ${CI_TEST_ADDITIONAL_VARS} -e @${CI_TEST_VARS} -e local_release_dir=${PWD}/downloads --limit "all:!fake_hosts" cluster.yml

  ## Idempotency checks 2/5 (Advanced DNS checks)
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} --limit "all:!fake_hosts" tests/testcases/040_check-network-adv.yml

  if [ "${RESET_CHECK}" = "true" ]; then
    ## Idempotency checks 3/5 (reset deployment)
    ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR}  -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} -e reset_confirmation=yes --limit "all:!fake_hosts" reset.yml

    ## Idempotency checks 4/5 (redeploy after reset)
    ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} -e local_release_dir=${PWD}/downloads --limit "all:!fake_hosts" cluster.yml

    ## Idempotency checks 5/5 (Advanced DNS checks)
    ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR} -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} --limit "all:!fake_hosts" tests/testcases/040_check-network-adv.yml
  fi
fi

# Test node removal procedure
if [ "${REMOVE_NODE_CHECK}" = "true" ]; then
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR}  -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} -e skip_confirmation=yes -e node=${REMOVE_NODE_NAME} --limit "all:!fake_hosts" remove-node.yml
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
fi

# Clean up at the end, this is to allow stage1 tests to include cleanup test
if [ "${RESET_CHECK}" = "true" ]; then
<<<<<<< HEAD
  run_playbook reset.yml -e reset_confirmation=yes
=======
  ansible-playbook ${ANSIBLE_LOG_LEVEL} -e @${CI_TEST_SETTING} -e @${CI_TEST_REGISTRY_MIRROR}  -e @${CI_TEST_VARS} ${CI_TEST_ADDITIONAL_VARS} -e reset_confirmation=yes --limit "all:!fake_hosts" reset.yml
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
fi
