# GOPATH/caches dentro del workspace (el GOPATH global es de solo lectura en este entorno).
export GOPATH="$PWD/.cache/gopath"
export GOMODCACHE="$GOPATH/pkg/mod"
export GOCACHE="$PWD/.cache/build"
export GOFLAGS="-mod=mod"
