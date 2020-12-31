{
  #imports = [ ./common.nix ];

  #networking.hostName = "example-nixos-system";

  users.users.kyle = {
    isNormalUser = true;
    # todo: change
    initialHashedPassword =
      "$6$hYiIwvTIv$2Z3lBfOQYi4IymaU2CLW2UwJcLfAvtEt1zAw5LJ/qtWQ/rnDEVLmwtaTJW4iUfRAH9QjzV10rHm06wgqvSXWt1";
  };
}
