# sops-and-git

## Learn how to use this repository

Please refer to the following link for detailed information.

[Secure Git workflows: Git hooks for JSON/YAML encryption/decryption](https://thebitcoffee.wordpress.com/2024/07/03/securing-git-workflows-age-sops-and-the-art-of-secret-management/)

You can now securely push YAML or JSON files to Git, and they will be automatically encrypted. When you check them out, they will be automatically decrypted. To encrypt other or additional keys, update the ~/.sops.yaml file.

---

Here are additional instructions for using the Git aliases to explicitly encrypt and decrypt files:

## Instructions to Use Git Aliases for Encryption and Decryption

1. **Configure Git Aliases**

   Open your terminal and run the following commands to set up the aliases:

   ```sh
   git config --global alias.encrypt '!encrypt() { ~/.githooks/encrypt_files.sh; }; encrypt'
   git config --global alias.decrypt '!decrypt() { ~/.githooks/decrypt_files.sh; }; decrypt'
   ```

2. **Encrypt Files**

   To encrypt files in your repository, run:

   ```sh
   git encrypt
   ```

   This command executes the `encrypt_files.sh` script located in your `~/.githooks` directory, encrypting the specified files.

3. **Decrypt Files**

   To decrypt files in your repository, run:

   ```sh
   git decrypt
   ```

   This command executes the `decrypt_files.sh` script located in your `~/.githooks` directory, decrypting the specified files.

### Additional Notes

- Ensure that the `encrypt_files.sh` and `decrypt_files.sh` scripts are executable and properly configured in the `~/.githooks` directory.
- These scripts should handle the specific encryption and decryption logic for your YAML, YML, and JSON files.

By following these instructions, you can easily encrypt and decrypt files in your Git repository using simple Git commands.