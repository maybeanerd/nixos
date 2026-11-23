# Udev rules so Wootility can access Wooting keyboards as a regular user.
# The rules live in 70-wooting.rules, kept verbatim from Wooting's instructions
# so they can be updated and diffed independently of the Nix code.
#
# The file is installed via udev.packages (not extraRules) to keep the 70- prefix:
# systemd's 73-seat-late.rules applies the uaccess ACL, so TAG+="uaccess" must be
# set before it, unlike rules in 99-local.rules.
{
  pkgs,
  ...
}:

{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "wooting-udev-rules";
      destination = "/etc/udev/rules.d/70-wooting.rules";
      text = builtins.readFile ./70-wooting.rules;
    })
  ];
}
