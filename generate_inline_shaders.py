#!usr/bin/env python

from __future__ import print_function

from glob import glob
from os import path
from os import makedirs

import sys

SHADERS_HPP_TEMPLATE = """#pragma once
%s"""

SHADER_TEMPLATE = """
const char *shader_source_%s = R"GLSL(%s)GLSL";
"""

BASE_DIR = sys.argv[1] if len(sys.argv) >= 2 else ''
INCLUDE_DIR = path.join(BASE_DIR, 'include/')
ASSETS_DIR = path.join(BASE_DIR, 'assets/')
OUTPUT_DIR = path.join(INCLUDE_DIR, 'app/')

if not path.exists(OUTPUT_DIR):
    makedirs(OUTPUT_DIR)

shader_paths = []
for ext in ['*.glsl']:
    shader_paths.extend(glob(ASSETS_DIR + ext))

shaders_hpp_contents = ''

for shader_path in shader_paths:
    print('Processing ' + shader_path)
    path_root, _ = path.splitext(shader_path)
    slug = '_'.join(path.split(path_root)[1:])
    with open(shader_path, 'r') as file:
        shaders_hpp_contents += SHADER_TEMPLATE % (slug, file.read())

shaders_hpp_path = OUTPUT_DIR + 'shaders.hpp'
print('Generating ' + shaders_hpp_path)
with open(shaders_hpp_path, 'w') as hpp_file:
    hpp_file.write(SHADERS_HPP_TEMPLATE % shaders_hpp_contents)
