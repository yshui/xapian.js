#! /bin/bash

# skip version="1.4.17"
version="1.4.26"
name="xapian-core-$version"
exports='["_prepare", "_commit", "_key", "_add", "_clean", "_query", "_percent", "_languages", "_snippet", "_compact", "_release"]'

[ -e $name.tar.xz ] || wget https://oligarchy.co.uk/xapian/$version/$name.tar.xz
tar -xf $name.tar.xz

if [ ! -f ./$name/.libs/libxapian.so ]; then
  # make libxapian.a
  pushd $name
  emconfigure ./configure CPPFLAGS='-DFLINTLOCK_USE_FLOCK' CXXFLAGS='-Oz -s USE_ZLIB=1' --disable-backend-remote
  emmake make
  popd
fi

FLAGS=(-Oz \
  -s ALLOW_MEMORY_GROWTH=1
  -s USE_ZLIB=1 \
  -s EXPORTED_RUNTIME_METHODS='["cwrap"]' \
  -s EXPORTED_FUNCTIONS='["_prepare", "_commit", "_key", "_add", "_clean", "_query", "_percent", "_languages", "_snippet", "_compact", "_release"]' \
  -std=c++11 \
  -I./$name \
  -I./$name/include \
  -I./$name/common)

# with exceptions and wasm
em++ "${FLAGS[@]}" \
  -s DISABLE_EXCEPTION_CATCHING=0 \
  xapian.cc ./$name/.libs/libxapian.so -o xapian_exception_wasm.js

# with exceptions and wasm with indexedDB support
em++ "${FLAGS[@]}" \
  -s DISABLE_EXCEPTION_CATCHING=0 \
  -lidbfs.js \
  xapian.cc ./$name/.libs/libxapian.so -o xapian_exception_wasm_db.js

# without exceptions and wasm
em++ "${FLAGS[@]}" \
  xapian.cc ./$name/.libs/libxapian.so -o xapian_noexception_wasm.js

# without exceptions and wasm with indexedDB support
em++ "${FLAGS[@]}" \
  -lidbfs.js \
  xapian.cc ./$name/.libs/libxapian.so -o xapian_noexception_wasm_db.js

ls
