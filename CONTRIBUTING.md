# Contributors

Thank you for investing your time in contributing to our project!

## Conventions

Because how bash script works, we need to set some convention
to make our code clean and easy to read.

1. Function name must matches regex: `[_]{0,2}kcs_(?<namespace>[a-z]+)(?<name>_[a-z]+)?_(?<action>[a-z_]+)`
2. Variable name must matches regex: `[_]{0,2}KCS_(?<namespace>[A-Z]+)_(?<name>[A-Z_]+)`
3. The namespace must be single noun and single form
4. The function name must end with action verb (e.g. **get**, **set**, **list**, **delete**)
5. Core and plugin files name must be plural form
6. Core and plugin functions should sorted as public -> private -> callback

There are 2 parts for naming convention: **variables** and **functions**.

### Variables

- For configure core settings, should use either `KCS_CORE_<NAME>` template
    - On some variables, you can use `<NAME>` alias instead (e.g. **_KCS_CORE_DEBUG** -> **DEBUG**)
- For **read** core settings or information use `_KCS_CORE_<NAME>` template
- For publicly **read-write** variables, should use `KCS_<NS>_<NAME>` template
- For publicly **read-only** variables, should use `_KCS_<NS>_<NAME>` template
- For internal **read-write** variables, should use `__KCS_<NS>_<NAME>` template
- Special variables for testing `KCT_<NAME>`

### Functions

- For Public functions, should use `kcs_<ns>[_<name>]_<action>` template
- For Private functions, should use `_kcs_<ns>[_<name>]_<action>` template
- For callback functions, should use `__kcs_<ns>[_<name>]_<action>` template
