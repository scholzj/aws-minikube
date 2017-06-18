# Steps ...

* Install Docker

```bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum install -y docker-ce
```

* Install kubectl
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

* Install kubeadm & kubelet
```bash
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo setenforce 0
sudo yum install -y kubelet kubeadm kubernetes-cni
sudo systemctl enable docker && sudo systemctl start docker
sudo systemctl enable kubelet && sudo systemctl start kubelet
```

* Set cloud provider for Kubelet
  * Add `Environment="KUBELET_CLOUD_ARGS=--cloud-provider=aws"` to `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
  * Change cgroup config
  * Restart kubelet `sudo systemctl daemon-reload && sudo systemctl restart kubelet`

* Create kubeadm.yaml
```yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
token: abcdef.abcdefghijklmnop
cloudProvider: aws
kubernetesVersion: v1.6.4
apiServerCertSANs:
- ip-10-112-49-21.eu-central-1.compute.internal
- ip-10-112-49-21
- 10.112.49.21
- en341-aws-minikube.dev.dbgcloud.io
```

* Init kubeadm
```bash
sudo kubeadm init --config ./kubeadm.yaml
```

* Export `export KUBECONFIG=/etc/kubernetes/admin.conf` for kubectl usage
* Label node as master `kubectl label node "$(hostname -f)" "kubernetes.io/role=master"`
* Create admin roles for the admin user `kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin`
* Create network `kubectl apply -f {{NetworkingProviderUrl}}`
* Generate kubectl config for admin
```bash
KUBECONFIG_OUTPUT=/home/ubuntu/kubeconfig
kubeadm alpha phase kubeconfig client-certs \
  --client-name admin \
  --server "https://${LB_DNS}" \
  >$KUBECONFIG_OUTPUT
```
