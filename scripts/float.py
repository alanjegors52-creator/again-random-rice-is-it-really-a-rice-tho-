#!/usr/bin/env python3
import json
import subprocess

def hyprctl(args):
    result = subprocess.run(['hyprctl', '-j'] + args, capture_output=True, text=True)
    return json.loads(result.stdout)

def toggle_workspace_floating():
    # 1. Get the current workspace ID
    active_workspace = hyprctl(['activeworkspace'])['id']
    
    # 2. Get all windows
    clients = hyprctl(['clients'])
    
    # 3. Filter windows to only those on the current workspace
    workspace_windows = [c for c in clients if c['workspace']['id'] == active_workspace]
    
    if not workspace_windows:
        return

    # 4. Determine logic: If at least one window is tiling, we float all.
    # Otherwise (if all are already floating), we tile all.
    any_tiling = any(not c['floating'] for c in workspace_windows)
    action = "setfloating" if any_tiling else "settiled"

    # 5. Apply the action to every window in the workspace
    for client in workspace_windows:
        address = client['address']
        subprocess.run(['hyprctl', 'dispatch', action, f'address:{address}'])

if __name__ == "__main__":
    toggle_workspace_floating()
