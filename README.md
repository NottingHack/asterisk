# Asterisk

Nottinghack's Asterisk PBX server docker file.

## Running On a Local Machine

### Sipcord-bridge

This is for integrating between Asterisk and Discord.
You can comment it out in the docker-compose file using the `#` comment character if it fails to docker-compose.

### Network Mode

`docker.errors.InvalidArgument: "host" network_mode is incompatible with port_bindings`

Comment this out if it shows up and you just want to run this locally.
It shows up when running the docker-compose in ChromeOS's weird chroot environment.
If you just want Asterisk available on localhost, you don't need it.

### Host

Open config/pjsip.conf and set:
```default-realm=localhost```

### Permit

You have to permit localhost to connect to the PBX
In the `[acl]` block add:

```
permit=localhost
```

### Auth Users

For a user with extension `1111` add the following to 
`config/pjsip-auth.conf`

```
[1111]
type=auth
auth_type=userpass
username=1111
password=2583
```

Add a corresponding block to `config/pjsip.conf`

```
[1111]
type=endpoint
context=hack
allow=all
aors=1111

[1111](aor-single)
```

### Connecting from a SoftPhone client

Get the IP address of your docker container:

```
docker inspect asterisk
```

Find the 'Network' segment, and copy the 'IPAddress.

Using 'localhost' does work to connect the softphone to the PBX,
but no audio comes through when dialing ( maybe it does for you? ).

Using a soft phone client ( like Zoiper ):

Username: 1111@[the IP you copied earlier]
Password: 1111

Domain: [The IP you copied earlier]

Dial '600' for the echo service to test your connection!
