# Disclaimer:
# This software has been created purely for the purposes of academic research and for the development of effective defensive techniques, 
# and is not intended to be used to attack systems except where explicitly authorized.
# Project maintainers are not responsible or liable for misuse of the software. Use responsibly.

require "yaml"
require "uri" # Works without this import in Ruby 3.3.0, not loaded anymore in Ruby 3.3.1 and later => already loaded in web frameworks such as Ruby on Rails.

# Standalone usage:
# Replace {CALLBACK_URL} placeholder in yaml-detection-ruby-3.3.yml with URL for callback, such as test.example.org/path, url should not have a query (?) component.
# ruby yaml_unsafe_load.rb yaml-detection-ruby-3.3.yml

YAML.unsafe_load File.read(ARGV[0]) # Attention: this triggers the execution of the gadget chain in the file provided.