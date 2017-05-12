apply-docker-image() {
  tag=$1
  name=$2
  folder=~/src/go/src/github.com/rook/rook/release
  dockerfile=$folder/rook-$name-dev.docker
  cp $folder/quay.io-rook-$name-$tag.aci $folder/quay.io-rook-$name-dev.aci
  cp $folder/rook-$name-$tag.docker $dockerfile
  echo "applying $name"

  docker tag quay.io/rook/$name:$tag quay.io/rook/$name:dev

  for vm in c1 w1  ; do vagrant scp $dockerfile $vm:~/. ; done
  for vm in c1 w1 ; do vagrant ssh $vm -- docker load -i rook-$name-dev.docker; done
  for vm in c1 w1 ; do vagrant ssh $vm -- docker tag quay.io/rook/$name:$tag quay.io/rook/$name:dev; done
}

docker rmi quay.io/rook/rookd:dev
docker rmi quay.io/rook/rook:dev
docker rmi quay.io/rook/toolbox:dev
image_name=$(docker images -a | grep "rookd" -m 1 | awk '{print $2}')
echo "image = $image_name"
apply-docker-image $image_name rookd
apply-docker-image $image_name rook
apply-docker-image $image_name toolbox
