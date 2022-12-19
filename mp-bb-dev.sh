# bootstrap flux https://repo1.dso.mil/platform-one/big-bang/bigbang/-/blob/master/docs/guides/deployment-scenarios/quickstart.md#step-8-install-flux
bash bigbang-upstream/scripts/install_flux.sh -u $REGISTRY1_USERNAME -p $REGISTRY1_PASSWORD

# login to registry
echo $REGISTRY1_PASSWORD | docker login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin

## set creds
#cp -pfv ib_creds.yaml{,.bak}
#cat << EOF > ib_creds.yaml
#registryCredentials:
#  registry: registry1.dso.mil
#  username: "$REGISTRY1_USERNAME"
#  password: "$REGISTRY1_PASSWORD"
#EOF

# install bb
#    -f bigbang-upstream/chart/values.yaml \
helm upgrade -i bigbang --create-namespace oci://registry.dso.mil/platform-one/big-bang/bigbang/bigbang --version 1.45.0 \
    -n bigbang \
    -f ib_creds.yaml \
    -f issue-values.yaml \
    -f override-values.yaml
