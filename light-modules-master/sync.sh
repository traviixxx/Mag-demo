export KUBECTL_NAMESPACE=base
export LIGHT_MODULES_CONTAINER_PATH=/mgnl-home/modules
kubectl -n $KUBECTL_NAMESPACE get pods -l "release=$KUBECTL_NAMESPACE,tier=app" -o name | sed 's/^pod\///' > pods.txt
for pod in `cat pods.txt`; do
  devspace sync --local-path light-modules/ --container-path=$LIGHT_MODULES_CONTAINER_PATH -n $KUBECTL_NAMESPACE --pod $pod -c $KUBECTL_NAMESPACE  --initial-sync mirrorLocal --no-watch --upload-only
done
rm pods.txt
