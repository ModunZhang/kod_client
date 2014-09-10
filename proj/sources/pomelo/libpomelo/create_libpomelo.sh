#!/bin/sh

cp -fR include ${LIBPOMELO_ROOT}

mkdir -p ${LIBPOMELO_ROOT}/deps/jansson/
cp -fR deps/jansson/src ${LIBPOMELO_ROOT}/deps/jansson

mkdir -p ${LIBPOMELO_ROOT}/deps/uv/
cp -fR deps/uv/include ${LIBPOMELO_ROOT}/deps/uv

mkdir -p ${LIBPOMELO_ROOT}/lib
cp -fR build/Default/libpomelo.a ${LIBPOMELO_ROOT}/lib/libpomelo.a
cp -fR deps/jansson/build/Default/libjansson.a ${LIBPOMELO_ROOT}/lib/libjansson.a
cp -fR deps/uv/build/Default/libuv.a ${LIBPOMELO_ROOT}/lib/libuv.a