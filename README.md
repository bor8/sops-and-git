# sops-and-git

## Securing Git workflows with Age and SOPS

Enhance the security of your Kubernetes and Helm charts by using Age and SOPS for managing sensitive data. Age (pronounced "ah-geh") generates keys that SOPS uses to encrypt YAML and JSON files. This setup automates decryption upon checkout and re-encryption upon check-in, seamlessly integrating with Git workflows. With Age and SOPS, you can ensure secure and efficient secret management in your Git repositories.

### Requirements

* Bash: The command-line shell used to execute scripts and automate tasks.
* Age: For key generation and encryption.
* SOPS: To encrypt and decrypt YAML and JSON files.
* Git: For version control and workflow integration.
* Basic regex knowledge: Useful for configuring patterns in encryption rules.

A common requirement may be to encrypt only specific keys, like usernames and passwords, while keeping the rest of the file visible in the Git repository. Unlike `git-crypt`, which encrypts entire files, this approach ensures that only sensitive information is hidden, leaving non-sensitive data accessible.

For added security, consider setting up Git hooks to automatically decrypt files on checkout and encrypt them on check-in. Additionally, using an encrypted hard drive is recommended to protect sensitive data at rest.

### Installation

#### Ubuntu

```
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install age, git, sops
```

The provided installation commands should work for Ubuntu 18.04 (Bionic Beaver) and later versions, such as 20.04 (Focal Fossa), 22.04 (Jammy Jellyfish), and newer.

### Setup

#### Age

This is the recommended method for generating keys with Age for use with SOPS:

```
age-keygen 
```

Be sure to save both keys in your password manager!

Or you can also save the credentials in a file (encrypted hard drive recommended):

```
mkdir -p ~/.config/sops/age/
age-keygen -o ~/.config/sops/age/key.txt
```

#### SOPS

Edit the file named `~/.sops.yaml` and add your Age public key:

```
creation_rules:
  - encrypted_regex: '^(user.*|pass.*)$'
    filename_regex: '\.(yaml|yml|json)$'
    key_groups:
      - age:
        - <YOUR_AGE_PUBLIC_KEY>
stores:
  yaml:
    indent: 2
  json:
    indent: 2
```

### Test it

Create or edit a file named `test.yaml`:

```
version: 1.0.0
username: abcd
password: abcd
```

Encrypt in place:

```
sops --config ~/.sops.yaml -e -i test.yaml
```

Show the contents of the encrypted file:

```
cat test.yaml
```

```
version: 1.0.0
username: ENC[AES256_GCM,data:Xok...==,iv:E+A...=,tag:1jN...==,type:str]
password: ENC[AES256_GCM,data:I7I...==,iv:LnU...=,tag:gwD...==,type:str]
sops:
  kms: []
  gcp_kms: []
  azure_kv: []
  hc_vault: []
  age:
    - recipient: age1xq6...
      enc: |
        -----BEGIN AGE ENCRYPTED FILE-----
        YWd...==
        -----END AGE ENCRYPTED FILE-----
  lastmodified: "2024-09-15T12:23:25Z"
  mac: ENC[AES256_GCM,data:1Nb...=,iv:xLG...=,tag:lze...==,type:str]
  pgp: []
  encrypted_regex: ^(user.+|pass.+)$
  version: 3.9.0
```

It has some necessary overhead at the end.

---

Decrypt to plain text in place (requires the Age secret key):

```
export SOPS_AGE_KEY=AGE-SECRET-KEY-1EG...
sops --config ~/.sops.yaml -d -i test.yaml
```

Note the `-d` for decrypt instead of `-e` for encrypt!

You can omit the first export line of the environment variable if you have the file `~/.config/sops/age/key.txt`.

Show the contents of the plain text file:

```
cat test.yaml
```

```
version: 1.0.0
username: abcd
password: abcd
```

### Automatic decryption and encryption

A local Git hook is a script that automatically executes predefined actions on your repository during specific Git events, such as commits, merges, or pulls.

Follow these steps to activate the Git hooks:

```
mkdir -p ~/.githooks/
git config --global core.hooksPath ~/.githooks
cd  # go to your home directory or wherever you want
git clone https://github.com/bor8/sops-and-git
cd sops-and-git
cp ./.githooks/ ~/
```

You can now securely push YAML or JSON files to Git, and they will be automatically encrypted. When you check them out, they will be automatically decrypted. To encrypt other or additional keys, update the `~/.sops.yaml` file.

---

Here are additional instructions for using the Git aliases to explicitly encrypt and decrypt files:

### Instructions to Use Git Aliases for Encryption and Decryption

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

#### Additional Notes

- Ensure that the `encrypt_files.sh` and `decrypt_files.sh` scripts are executable and properly configured in the `~/.githooks` directory.
- These scripts should handle the specific encryption and decryption logic for your YAML, YML, and JSON files.

By following these instructions, you can easily encrypt and decrypt files in your Git repository using simple Git commands.
