apply-docker-image() {
  base_name=$1
  tag=$2
  name=$3
  folder=~/src/go/src/github.com/rook/rook/.work
  dockerfile=$folder/rook-$name-dev.docker
  #cp $folder/quay.io-rook-$name-$tag.aci $folder/quay.io-rook-$name-dev.aci
  #cp $folder/rook-$name-$tag.docker $dockerfile
  echo "applying $name at $base_name:$tag"

  docker tag $base_name:$tag rook/$name:dev
  docker save rook/$name:dev -o $dockerfile
  #~/Downloads/docker2aci $folder/rook-$name-dev.docker
  #cp rook-$name-dev.aci $folder/

  for vm in default ; do vagrant scp $dockerfile $vm:~/. ; done
  for vm in default ; do vagrant ssh $vm -- docker load -i rook-$name-dev.docker; done
  for vm in default ; do vagrant ssh $vm -- docker tag rook/$name:$tag rook/$name:dev; done
}

docker rmi rook/rook:dev
docker rmi rook/toolbox:dev
image_name=$(docker images -a | grep "rook-amd64" -m 1 | awk '{print $2}')
base_name=$(docker images -a | grep "rook-amd64" -m 1 | awk '{print $1}')
base_toolbox_name=$(docker images -a | grep "toolbox" -m 1 | awk '{print $1}')
echo "image = $image_name"
time apply-docker-image $base_name $image_name rook
time apply-docker-image $base_toolbox_name $image_name toolbox
