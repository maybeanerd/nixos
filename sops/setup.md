The secret key is stored outside of this repo. To decrypt secrets, add it following these steps:

1. Download the age-key.txt file
2. Create the directory to store it 
```bash
    sudo mkdir -p /etc/age
```

3. Move the file there
```bash
    sudo mv age-key.txt /etc/age/keys.txt 
```

4. Set file permissions
```bash
    sudo chmod 600 /etc/age/keys.txt
```

5. Set system owner
```bash
  if [ "$(uname)" = "Darwin" ]; then
    sudo chown root:wheel /etc/age/keys.txt
  else
    sudo chown root:root /etc/age/keys.txt
  fi
```
