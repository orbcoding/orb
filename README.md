#_orb_extensions
if folder _orb_extensions exists above in file system (orb utils upfind). Script files can hook into main `orb` namespace or create/extend other namespaces. Eg:

- `orb_extensions/orb.sh` extends the main namespace. Sourced functions can be called by `orb function_name`
- `orb_extensions/namespace.sh` extends `orb namespace function_name`
