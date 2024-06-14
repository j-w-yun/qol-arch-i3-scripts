#!/usr/bin/env python

import i3
import re
import subprocess
import sys

def find_parent(window_id):
    root_window = i3.get_tree()
    result = [None]
    def finder(nodes, p=None):
        if result[0]:
            return
        for node in nodes:
            if node['id'] == window_id:
                result[0] = p
                return
            if len(node['nodes']):
                finder(node['nodes'], node)
    finder(root_window['nodes'])
    return result[0]

def set_layout():
    try:
        current_window = i3.filter(nodes=[], focused=True)
        for window in current_window:
            parent = find_parent(window['id'])
            if (not parent or
                'rect' not in parent or
                parent['layout'] in ['tabbed', 'stacked']):
                continue
            new_layout = (
                'vertical'
                if parent['rect']['height'] > parent['rect']['width'] else
                'horizontal'
            )
            i3.split(new_layout)
    except:
        pass

def main():
    process = subprocess.Popen(
        ['xprop', '-root', '-spy'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    regex = re.compile(b'^_NET_CLIENT_LIST_STACKING|^_NET_ACTIVE_WINDOW')
    last_line = ''
    while True:
        line = process.stdout.readline()
        if line == b'':
            break
        if line == last_line:
            continue
        if regex.match(line):
            set_layout()
        last_line = line
    process.kill()
    sys.exit()

if __name__ == '__main__':
    main()
