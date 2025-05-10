#!/usr/bin/env python

import sys
<<<<<<< HEAD
import traceback
from jinja2 import Environment
from jinja2.exceptions import TemplateSyntaxError


env = Environment()
errors = False
for template in sys.argv[1:]:
    try:
        with open(template) as t:
            env.parse(t.read())
    except TemplateSyntaxError as e:
        print (template)
        traceback.print_exc()
        errors = True
if errors:
    exit (1)
=======
from jinja2 import Environment

env = Environment()
for template in sys.argv[1:]:
    with open(template) as t:
        env.parse(t.read())
>>>>>>> 2cb8c8544 (Fix logical error when checking for boostrap-os (#10867) (#10953))
