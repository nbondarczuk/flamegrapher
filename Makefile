all: flamegrapher-image trace-namespace flamegrapher-pod

flamegrapher-image:
	cp Dockerfile-ubuntu Dockerfile
	docker build -t flamegrapher .
	#docker login https://ger-is-registry.caas.intel.com/
	docker tag flamegrapher ger-is-registry.caas.intel.com/cno/flamegrapher
	#docker push ger-is-registry.caas.intel.com/cno/flamegrapher

flamegrapher-pod:
	kubectl create -f flamegrapher-pod.yaml

volume:
	mkdir -p /var/run/flamegraph
	rm -f /var/run/flamegraph/*

trace-namespace:
	kubectl create -f trace-namespace.yaml

clean:
	rm -f *~
	kubectl delete -f trace-namespace.yaml

purge:
	kubectl delete -f trace-namespace.yaml

tar:
	tar -cvf ~/flamegrapher.tar *

show:
	@echo ">>>>>>"
	docker images
	@echo ">>>>>>"
	kubectl get pods --all-namespaces
	@echo ">>>>>>"
	kubectl describe pod flamegrapher --namespace=trace
	@echo ">>>>>>"
	kubectl logs flamegrapher --namespace=trace
	@echo ">>>>>>"
