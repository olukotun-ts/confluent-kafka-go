#!/bin/bash
#
#
# Downloads, builds and installs librdkafka into <install-dir>
#

set -e

VERSION=$1
PREFIXDIR=$2

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <librdkafka-version> [<install-dir>]" 1>&2
    exit 1
fi

if [[ -z "$PREFIXDIR" ]]; then
    PREFIXDIR=tmp-build
fi

if [[ $PREFIXDIR != /* ]]; then
    PREFIXDIR="$PWD/$PREFIXDIR"
fi

mkdir -p "$PREFIXDIR/librdkafka"
pushd "$PREFIXDIR/librdkafka"

test -f configure ||
curl -sL "https://github.com/edenhill/librdkafka/archive/${VERSION}.tar.gz" | \
    tar -xz --strip-components=1 -f -

if [[ "$(uname -s)" == Darwin ]]; then
    export PATH="/usr/local/opt/openssl/bin:$PATH"
    echo "export PATH=$PATH" >> $BASH_ENV
    ./configure --prefix="$PREFIXDIR" \
        --CPPFLAGS="-I/usr/local/opt/openssl/include" \
        --LDFLAGS="-L/usr/local/opt/openssl/lib"
else
    ./configure --prefix="$PREFIXDIR"
fi

make -j
make install
popd
