#!/bin/bash
set -ex
read  -n 1 -p "Press enter to fresh-rebuild docs: "
rm -f docs/build.log || echo 'No previous build log at: docs/build.log'
(time stack build --haddock --haddock-deps --haddock-internal --haddock-arguments="-o ../docs" 2>&1 | tee -a ../docs/build.log)
