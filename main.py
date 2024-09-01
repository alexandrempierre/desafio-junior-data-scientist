import os
import subprocess


if __name__ == "__main__":
    subprocess.Popen(["streamlit", "run", "Home.py", os.devnull])
