# Easy Clone

`easy_clone.sh` is a simple script that lets you clone multiple files with a single command

## Prerequisites

Before you begin, ensure you have met the following requirement:
- You have `rsync` installed on your machine. If not, you can install it using your package manager.

## Installation

1. Clone the repository:
    ```
    git clone https://github.com/yourusername/easy-copy.git
    ```
2. Navigate to the project directory:
    ```
    cd easy-copy
    ```
3. Make the script executable:
    ```
    chmod 755 easy_clone.sh
    ```

### Adding to Shortcut (macOS version)

To make the script easily accessible from anywhere on your Mac, you can create a symbolic link:

1. Move the script to a directory that's in your PATH, for example `/usr/local/bin`, and rename it to `ezclone`:
    ```
    sudo mv easy_clone.sh /usr/local/bin/ezclone
    ```
2. Ensure the directory is in your PATH:
    ```
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile
    source ~/.bash_profile
    ```
    If you are using zsh, update your `.zshrc` file instead:
    ```
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ```

Now you can run the script from anywhere using:
```
ezclone <source_directory> <destination_directory> <pattern-or-item> [pattern-or-item]...
```

## Usage

To use the `easy_clone.sh` script, run the following command:
```sh
./easy_clone.sh <source_directory> <destination_directory> <pattern-or-item> [pattern-or-item]...
```
## Example
```sh
 ./easy_clone.sh /path/to/resource /path/to/destination "*file.txt" "file.txt" "*.sh"
 ./easy_clone.sh /path/to/resource /path/to/destination "subdir/file.txt"
 ./easy_clone.sh /path/to/resource /path/to/destination "subdir" "anotherdir/"
```

This will clone the specified repository into the current directory.

## Contributing

If you want to contribute to this project, please fork the repository and create a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.