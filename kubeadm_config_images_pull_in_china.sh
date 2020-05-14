#!/bin/sh
kubeadm config images list | while read line;
do
    imageName=$(echo $line | sed -e 's/k8s.gcr.io\///g')
    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
