#!/bin/bash

# Install and run the tests for GMT/Python to make sure the package was built
# properly.

pip install https://github.com/GenericMappingTools/gmt-python/archive/master.zip
python -c "import gmt; gmt.test()"
