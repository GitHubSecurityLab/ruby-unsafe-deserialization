# Proof of Concepts for unsafe deserialization in Ruby

Companion repository to the blog post: [Execute commands by sending JSON? Learn how unsafe deserialization vulnerabilities work in Ruby projects](https://github.blog/2024-06-20-execute-commands-by-sending-json-learn-how-unsafe-deserialization-vulnerabilities-work-in-ruby-projects/).

The proof of concept exploits contained in this repository are largely based on the [universal gadget chain](https://devcraft.io/2022/04/04/universal-deserialisation-gadget-for-ruby-2-x-3-x.html) published by [William Bowling](https://github.com/wbowling) (aka vakzz).

## Disclaimer

This software has been created purely for the purposes of academic research and for the development of effective defensive techniques, and is not intended to be used to attack systems except where explicitly authorized. Project maintainers are not responsible or liable for misuse of the software. Use responsibly.

## Supported Libraries

This repo contains detection and RCE PoCs for following deserialization libraries:
* Oj (JSON)
* Ox (XML)
* Psych (YAML)
* Marshall

The Oj, Ox and Psych proof of concepts were observed to work up to the current Ruby 3.3.3 (released in June 2024). The PoC for Marshall was observed to work up to Ruby 3.2.4 (released in April 2024).


## Usage

The subfolders for Oj, Ox and YAML contain gadget chains for the detection of an exploitable sink and remote code execution.

* The **detection gadget chain** calls an URL when flowing into a vulnerable sink. For this to work the placeholder `{CALLBACK_DOMAIN}` has to be replaced with a domain which should be called (preferably under the control of the tester).
* The **remote code execution (RCE) gadget chain**:
    * makes use of the `zip` command line util to run arbitrary commands (see [GTFObins](https://gtfobins.github.io/gtfobins/zip/)). Replace the placeholder `{ZIP_PARAM}` with a zip parameter that executes a command such as `-TmTT=\"$(id>/tmp/deser-poc)\"any.zip` (which will write the output of `id` to `/tmp/deser-poc`).
    * for chain <= 3.0.2, replace the placeholder `{COMMAND}` with a system command like `id`.

See the Ruby files in the respective subfolders for more information.
