# Setup

Before using this script, you need to compile it.
Add a file `ApiKey` with the following content.
```
let API_KEY = "you api key"
```

Now let Xcode compile the script and have fun.

# Usage

First, export all localization from Xcode into a folder.
This folder should then contain `.xcloc` files.
Use this folder path for the script.

```
xcloc-translator path-to-folder
```

# Output

The script creates `.xliff` files in the localization folder under `output`.
You can then import these files inside Xcode
