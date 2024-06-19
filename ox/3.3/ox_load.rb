# Disclaimer:
# This software has been created purely for the purposes of academic research and for the development of effective defensive techniques, 
# and is not intended to be used to attack systems except where explicitly authorized.
# Project maintainers are not responsible or liable for misuse of the software. Use responsibly.

require "ox"
require "uri" # Works without this import in Ruby 3.3.0, not loaded anymore in Ruby 3.3.1 and later => already loaded in web frameworks such as Ruby on Rails.

# Standalone usage:
# gem install ox
# Replace {CALLBACK_URL} placeholder in ox-detection-ruby-3.3.xml with URL for callback, such as test.example.org/path, url should not have a query (?) component. (might require the usage of entities such as &gt;)
# ruby ox_load.rb ox-detection-ruby-3.3.xml

Ox.parse_obj(File.read(ARGV[0])) # Attention: this triggers the execution of the gadget chain in the file provided.
