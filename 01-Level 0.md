# Krypton Level 0 → Level 1
```
Welcome to Krypton! The first level is easy. The following string encodes the password using Base64:

S1JZUFRPTklTR1JFQVQ=

Use this password to log in to krypton.labs.overthewire.org with username krypton1 using SSH on port 2231. You can find the files for other levels in /krypton/
```

La resolución de este nivel es muy sencilla ya que nos indica cómo se ha "encriptado" el mensaje. 
```bash
echo "S1JZUFRPTklTR1JFQVQ=" | base64 --decode
```

