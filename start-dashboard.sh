#!/usr/bin/env bash

SRC="$HOME/dashboard"
REPO="git@github.com:gardener/dashboard.git"
BACK_PORT="9050"
FRONT_PORT="3030"
HTTP_PORT="8080"

function clone() {
  cd $HOME
  printf "\n\n⏳ ${MAG}Checking ${CYAN}for Gardener Dashboard Repo.\n"
  if [ ! -d "$SRC" ]; then
    printf "\n❌ ${CYAN}$SRC ${RED}does not exist.\n"
  else 
    cd $SRC
    if git rev-parse --git-dir > /dev/null 2>&1; then    
      printf "\n✅${CYAN} Repository ${GREEN}OK.${NO_COLOR}\n"
      return 0
    else 
      printf "\n❌ ${CYAN}Gardener Dashboard Repo ${RED}doesnt look right.\n"
    fi
  fi
  cd $HOME
  if [ -d "$SRC" ]; then
   printf "\n⏳ ${MAG}Backing up ${CYAN}old Gardener Dashboard Repo to $SRC.old .\n"
   mv $SRC $SRC.old > /dev/null 2>&1
   rm -rf $SRC
  fi
   printf "\n⏳ ${MAG}Cloning ${CYAN}Gardener Repo.\n"
  if ! (git clone $REPO); then
    printf "\n❌ ${RED}Clone not successful.  Check your Git config. Exiting...${NO_COLOR}\n"
    exit 0
  fi
  cd $SRC
}

function free_port() {
  lsof -ti tcp:$1| xargs kill -9
}



cd ${HOME}/.gardener
mv config.yaml config.old > /dev/null 2>&1

# get the garden cluster api server
api_url=$(kubectl config view --minify -ojsonpath='{.clusters[].cluster.server}')

cat <<EOF >> config.yaml
port: 3030
logLevel: debug
logFormat: text
apiServerUrl: $api_url # garden cluster kube-apiserver url - kubectl config view --minify -ojsonpath='{.clusters[].cluster.server}'
sessionSecret: c2VjcmV0                # symmetric key used for encryption
frontend:
  dashboardUrl:
    pathname: /api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/
  defaultHibernationSchedule:
    evaluation:
    - start: 00 17 * * 1,2,3,4,5
    development:
    - start: 00 17 * * 1,2,3,4,5
      end: 00 08 * * 1,2,3,4,5
    production: ~
EOF

clone
free_port $BACK_PORT > /dev/null 2>&1 
printf "\n\nStarting Gardener Dashboard Backend...\n"
cd ${HOME}/dashboard/backend
yarn > /dev/null 2>&1 
(yarn serve > /dev/null 2>&1 &)
free_port $FRONT_PORT > /dev/null 2>&1 
free_port $HTTP_PORT > /dev/null 2>&1
printf "Starting Gardener Dashboard Frontend...\n\n"
cd ${HOME}/dashboard/frontend
yarn > /dev/null 2>&1 
(yarn serve > /dev/null 2>&1 &)

cd ${HOME}/.gardener
kubectl -n garden create serviceaccount dashboard-user > /dev/null 2>&1
kubectl set subject clusterrolebinding cluster-admin --serviceaccount=garden:dashboard-user
printf "Copy this token to login...\n\n"
echo $(kubectl -n garden create token dashboard-user --duration 24h) > token && cat token
cat token | pbcopy > /dev/null 2>&1
printf "\nToken copied to clipboard...\n\n"
printf "You can manually open the dashboard with http://localhost:$HTTP_PORT\n\n"
printf "Opening Dashboard on default browser...\n"
open http://localhost:$HTTP_PORT
cd -
