import os
import sys
import argparse
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.backends import default_backend
import secrets
import string

def generate_strong_password(length=64):
    """Generate a strong random password with mixed characters"""
    characters = string.ascii_letters + string.digits + string.punctuation
    while True:
        password = ''.join(secrets.choice(characters) for _ in range(length))
        # Ensure password contains at least one of each character type
        if (any(c.islower() for c in password)
                and any(c.isupper() for c in password)
                and any(c.isdigit() for c in password)
                and any(c in string.punctuation for c in password)):
            return password

def generate_key(password: bytes, salt: bytes) -> bytes:
    """Derive a 256-bit key from the password using PBKDF2"""
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=100000,
        backend=default_backend()
    )
    return kdf.derive(password)

def encrypt_file(input_path: str, output_path: str, password: bytes):
    """Encrypt a file to .meow format"""
    # Generate random salt and nonce
    salt = secrets.token_bytes(16)
    nonce = secrets.token_bytes(12)
    
    # Derive key
    key = generate_key(password, salt)
    
    # Create cipher
    cipher = Cipher(
        algorithms.AES(key),
        modes.GCM(nonce),
        backend=default_backend()
    )
    encryptor = cipher.encryptor()
    
    # Read input file
    with open(input_path, 'rb') as f:
        plaintext = f.read()
    
    # Encrypt and get tag
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()
    tag = encryptor.tag
    
    # Write output file with format: salt (16) + nonce (12) + tag (16) + ciphertext
    with open(output_path, 'wb') as f:
        f.write(salt)
        f.write(nonce)
        f.write(tag)
        f.write(ciphertext)

def process_file(path: str, password: bytes):
    """Process a single file, encrypting it to .meow format"""
    if not os.path.isfile(path):
        print(f"Warning: {path} is not a file, skipping")
        return
    
    if path.endswith('.meow'):
        print(f"Warning: {path} is already encrypted, skipping")
        return
    
    output_path = path + '.meow'
    try:
        encrypt_file(path, output_path, password)
        print(f"Encrypted {path} to {output_path}")
        # Remove original file after successful encryption
        os.remove(path)
    except Exception as e:
        print(f"Error encrypting {path}: {str(e)}")

def process_directory(path: str, password: bytes):
    """Recursively process all files in a directory"""
    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            process_file(file_path, password)

def main():
    parser = argparse.ArgumentParser(description='Encrypt files to .meow format')
    parser.add_argument('target', help='Target file or directory to encrypt')
    parser.add_argument('-r', '--recursive', action='store_true', 
                        help='Recursively encrypt files in directories')
    args = parser.parse_args()

    # Generate strong 64-character password
    password_str = generate_strong_password(64)
    password = password_str.encode('utf-8')
    
    print("\nGenerated strong 64-character password:")
    print(password_str)
    print("\nIMPORTANT: Save this password in a secure location.")
    print("Without it, your encrypted files cannot be recovered.\n")
    
    target = args.target
    
    if args.recursive and os.path.isdir(target):
        process_directory(target, password)
    elif os.path.isfile(target):
        process_file(target, password)
    else:
        print(f"Error: Target {target} not found or invalid")
        sys.exit(1)

if __name__ == "__main__":
    main()
