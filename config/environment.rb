# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Upload::Application.initialize!
#AUTH_METHOD can be LDAP, PLAIN (login:pass) or HTAUTH (with crypt, not md5) only
#AUTH_METHOD = 'HTAUTH'
HTAUTH_FILE = 'config/htpasswd'
AUTH_METHOD = 'PLAIN'
PLAIN_FILE = 'config/plainpasswd'
#AUTH_METHOD = 'LDAP'
LDAP_HOST = 'hostname'
LDAP_PORT = 389
LDAP_BASE = 'ou=Users,dc=company,dc=com'