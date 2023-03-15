$KeyFile = ".\AES.key"
$Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

$PasswordFile = ".\EncryptedMPPassword.txt"
$KeyFile = ".\AES.key"
$Key = Get-Content $KeyFile
$Password = "mpconnect" | ConvertTo-SecureString -AsPlainText -Force
$Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile