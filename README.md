# sops-and-git

Secure Git workflows with Age and SOPS: Git hooks to decrypt and encrypt YAML files, ensuring sensitive data protection:

https://thebitcoffee.wordpress.com/2024/07/03/securing-git-workflows-age-sops-and-the-art-of-secret-management/

To explicitly decrypt - after git rebase:

```
git config --global alias.encrypt '!fe() { ~/.githooks/encrypt_files.sh --all; }; fe'
git config --global alias.decrypt '!fd() { ~/.githooks/decrypt_files.sh; }; fd'
```

