#!/usr/bin/env python3
import os
import shutil

# Backup original wsl.conf
src = '/tmp/wsl.conf'
dst = '/etc/wsl.conf'

if os.path.exists(dst):
    shutil.copy(dst, dst + '.bak')

shutil.copy(src, dst)
print(f"Updated {dst}")
