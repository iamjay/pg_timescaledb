#!/bin/sh
#

set -e

POSTGRES_VERSION=$1
TIMESCALEDB_VERSIONS=$2

if [ "$TIMESCALEDB_VERSIONS" = "" ]; then
   echo "Error: Must specify desired TimescaleDB versions."
   exit 1
fi

LATEST_TIMESCALEDB_VERSION=$(echo "${TIMESCALEDB_VERSIONS##*,}")

echo ""
echo "Using PostgreSQL version ${POSTGRES_VERSION}, Timescale version ${TIMESCALEDB_VERSIONS}."
echo "=============================================================================="

for timescaledb_version in $(echo $TIMESCALEDB_VERSIONS | sed "s/,/ /g"); do
  echo ""
  echo "=============================================================================="
  echo "Starting TimescaleDB ${timescaledb_version} build..."
  rm -r /tmp
  mkdir /tmp

  wget https://github.com/timescale/timescaledb/archive/${timescaledb_version}.zip -P /tmp/
  unzip /tmp/${timescaledb_version}.zip -d /tmp/
  cd /tmp/timescaledb-${timescaledb_version}

  # Bootstrap the build system
  ./bootstrap -DCMAKE_FIND_ROOT_PATH="/usr/local/lib/postgresql" -DREGRESS_CHECKS=OFF

  # To build the extension
  cd build && make

  # To install
  make install
done

{
  echo "shared_preload_libraries = 'timescaledb'"
  echo "timescaledb.telemetry_level=off"
  echo "timescaledb.max_background_workers = 3"
} >> /usr/local/share/postgresql/postgresql.conf.sample

echo ""
echo "=============================================================================="
echo "Build complete."
