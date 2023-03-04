#!/bin/bash

TERRAFORM="terraform -chdir=terraform"
INVENTORY="./ansible/inventory"

echo "Create VM..."
$TERRAFORM apply -auto-approve

echo "Get VM IP..."
NODES=$($TERRAFORM output | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
readarray -t IP_LIST <<<"$NODES"

MASTER=${IP_LIST[0]}
WORKER=${IP_LIST[1]}

echo "Check SSH availability..."
NOT_AVAIABLE=1
while [ $NOT_AVAIABLE -eq 1 ]
do
   nc -w5 -z "$MASTER" 22 && nc -w5 -z "$WORKER" 22
   NOT_AVAIABLE=$?
done

echo "Master node will be $MASTER, worker node will be $WORKER. Make inventory..."
sed -i "s/master ansible_host=.*/master ansible_host=$MASTER/g" $INVENTORY
sed -i "s/worker ansible_host=.*/worker ansible_host=$WORKER/g" $INVENTORY

cat $INVENTORY

echo "Apply playbook..."
export ANSIBLE_CONFIG=./ansible/ansible.cfg && ansible-playbook ansible/setup-k8s.yml -i $INVENTORY

echo "Wait just a bit..."
sleep 60
ssh -i ~/.ssh/appuser ubuntu@"$MASTER" kubectl get nodes
