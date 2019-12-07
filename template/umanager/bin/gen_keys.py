#!<:install_root:>/supervisord/altenv/bin/python2.7

import ConfigParser
import fileinput
import gnupg
import os
import sys

config_path = os.path.join('<:install_root:>/umanager/config/umanager.conf')

config = ConfigParser.SafeConfigParser()
config.read(config_path)
home = config.get('dirs', 'gnupg_home')
name = sys.argv[1]
email = sys.argv[2]

gpg = gnupg.GPG(gnupghome=home)

input_data = gpg.gen_key_input(key_type="RSA", key_length=1024, name_real=name, name_email=email)
key = gpg.gen_key(input_data)

# update umanager.conf with this new key
with open(config_path, "r") as f:
    data = f.read()
data = data.replace("<signing_key>", str(key))
with open(config_path, "w") as f:
    f.write(data)

sys.exit(0)
