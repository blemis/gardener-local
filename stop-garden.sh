SRC="$HOME/gardener"
cd $SRC
sudo sed -i '/.local.gardener.cloud/d' /etc/hosts
sudo sed -i '/cluster/d' /etc/hosts
sudo sed -i '/garden/d' /etc/hosts
make kind-down
export KUBECONFIG=$HOME/.kube/config
