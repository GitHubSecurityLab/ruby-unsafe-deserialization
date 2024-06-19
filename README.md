# Proof of Concepts for unsafe deserialization in Ruby

Companion repository to blog post (link).

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

* The **detection gadget chain** calls an URL when flowing into a vulnerable sink. For this to work the placeholder `{CALLBACK_URL}` has to be replaced with an URL which should be called (preferably under the control of the tester).
* The **remote code execution (RCE) gadget chain** makes use of the `zip` command line util to run arbitrary commands (see [GTFObins](https://gtfobins.github.io/gtfobins/zip/)). Replace the placeholder `{ZIP_PARAM}` with a zip parameter that executes a command such as `-TmTT=\"$(id>/tmp/deser-poc)\"any.zip` (which will write the output of `id` to `/tmp/deser-poc`).


See the Ruby files in the respective subfolders for more information.
