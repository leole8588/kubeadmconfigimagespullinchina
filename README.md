# kubeadmconfigimagespullinchina
解决 kubeadm config images pull 中国无法访问问题

在Ubantu或者Debain安装kubeadm 之后，需要运行kubeadm init 初始化kubeadm环境 ，但是会发现，kubeadm init 失败的情况.

查看错误信息，发现时国内对k8s.gcr.io 的访问有限制.

但是在失败信息中发现“You can also perform this action in beforehand using 'kubeadm config images pull'”.

可以提前将需要的images pull下来.

深入研究kubeadm config 发现并没有更换源的方式，却提供了kubeadm config images list指令，执行之后效果是这样:

```sh
W0514 11:24:58.943805    8634 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
k8s.gcr.io/kube-apiserver:v1.18.2
k8s.gcr.io/kube-controller-manager:v1.18.2
k8s.gcr.io/kube-scheduler:v1.18.2
k8s.gcr.io/kube-proxy:v1.18.2
k8s.gcr.io/pause:3.2
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.7
```

经过研究，发现阿里云的源包含这些镜像 registry.cn-hangzhou.aliyuncs.com/google_containers/

docker 的image是可以通过tag 指令“调包”的

结合这些指令，写一个方便的脚本[kubeadm_config_images_pull_in_china.sh](https://github.com/leole8588/kubeadmconfigimagespullinchina/blob/master/kubeadm_config_images_pull_in_china.sh)解决这个问题.

查看 images

```sh
root@leo-debian:~# docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy                v1.18.2             0d40868643c6        3 weeks ago         117MB
k8s.gcr.io/kube-controller-manager   v1.18.2             ace0a8c17ba9        3 weeks ago         162MB
k8s.gcr.io/kube-scheduler            v1.18.2             a3099161e137        3 weeks ago         95.3MB
k8s.gcr.io/kube-apiserver            v1.18.2             6ed75ad404bd        3 weeks ago         173MB
k8s.gcr.io/pause                     3.2                 80d28bedfe5d        2 months ago        683kB
k8s.gcr.io/coredns                   1.6.7               67da37a9a360        3 months ago        43.8MB
k8s.gcr.io/etcd                      3.4.3-0             303ce5db0e90        6 months ago        288MB
```
全有了,执行kubeadm init 
```sh
root@leo-debain:~# kubeadm init
W0514 11:47:43.280111   10292 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.2
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [leo-debian kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.99]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [leo-debian localhost] and IPs [192.168.1.99 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [leo-debian localhost] and IPs [192.168.1.99 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0514 11:47:53.331104   10292 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0514 11:47:53.333215   10292 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 45.512297 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node qin-local as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node qin-local as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: zx08dk.97494vjd4sk3e44q
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.99:6443 --token zx08dk.97494vjd4sk3e44q \
    --discovery-token-ca-cert-hash sha256:660a0691126c84cd146f92b9a36a1acc054ee31b60d43650a272f29e0708c6ee 
```
    
非常顺利
