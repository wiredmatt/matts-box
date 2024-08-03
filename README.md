# matts-box

Files and scripts I use in my daily driver.

## Instructions

### Setup

Login as root user and clone this repo

```bash
sudo su -
cd ~
git clone git@github.com:wiredmatt/matts-box.git
```

### Blocking weird stuff

Believe it or not, my ISP doesn't allow me to change the DNS at a router level. This is the workaround I've found, without using a reverse proxy on a Raspberry Pi (I'm sorry gamers but it made too much noise, can't keep that thing on for +12h)

```bash
cat ~/matts-box/system_files/dns_servers.conf > /etc/systemd/resolved.conf.d/dns_servers.conf
chattr +i /etc/systemd/resolved.conf.d/dns_servers.conf # make the file immutable
cat ~/matts-box/system_files/fallback_dns.conf > /etc/systemd/resolved.conf.d/fallback_dns.conf
```

Of course, your network resolution should work with systemd-resolved. If you use something else, there's surely a way to implement the equivalent of this, gl.

### Blocking distractions

```bash
cat ~/matts-box/system_files/hosts > /etc/hosts
```

#### NOTE

This file can be changed with sudo.

Some of my clients work with social media integrations, so I often find myself turning these on and off.
If you want to NEVER access these sites, you can make the file immutable in the same way we did with `dns_servers.conf` in the previous step, as root user (`chattr +i /etc/hosts`).

### Applying DNS changes

```bash
sudo systemctl restart systemd-resolved.service
```

### Making sure we can't log in as root as any user

```bash
cat ~/matts-box/system_files/sudoers > /etc/sudoers
```

If you don't want to replace the entire file, just copy this to the end of the file (before the line containing `#includedir /etc/sudoers.d`):

```bash
Cmnd_Alias DENY_WRITE_DNS = /bin/nano /etc/systemd/resolved.conf.d/dns_servers.conf, /usr/bin/vim /etc/systemd/resolved.conf.d/dns_servers.conf, /usr/bin/vi /etc/systemd/resolved.conf.d/dns_servers.conf
Cmnd_Alias DENY_CHATTR = /usr/bin/chattr
Cmnd_Alias DENY_SU = /usr/bin/su, /usr/bin/su root, /usr/bin/su -
Cmnd_Alias DENY_PASSWD= /usr/bin/passwd root
ALL ALL=(ALL) !DENY_WRITE_DNS, !DENY_CHATTR, !DENY_SU, !DENY_PASSWD
```

This will prevent us from doing stuff like `sudo su`, `sudo su -`, `sudo su root`.

### Forgetting about the root user

This should be the last step!

```bash
cd ~
./random_password.sh
cat root_$(hostname) # store this file or its contents somewhere safe
# exit -> after backing up the file!
```

After running the script, store the generated credentials file somewhere safe, we won't keep track of this password. I recommend either another box of your choice or encrypted hard drive.
For example I have an external encrypted SSD with credential files for all my boxes, but a more convenient option might be the cloud, or even a password manager like 1Password, LastPass, whatever. The point is, not even you should know this password, and it'll be smart to rotate it everytime you log on and off as root user (run the script again and update the credential file).

#### NOTE

For increased security, you can use any other way to generate this random password, and in fact, you should! I always use a different strategy, I chose openssl for this because it's always present in every distro I've come accross.

### Recovery

If you ever want to change things from the protected files:

1. login as root (`su root`), input the password you saved.
2. remove the immutable attribute from the file, for example: `chattr -i /etc/hosts`
3. make whatever changes
4. set the immutable flag again `chattr +i /etc/hosts`
5. (optional) [reset the password and logout](#forgetting-about-the-root-user)

### If you're very dumb

If you mess up the part about backing up the password, don't fret. You can still modify the sudoers file as a regular user using sudo, `sudo EDITOR=vim visudo`. Temporarily delete `!DENY_SU, !DENY_PASSWD`, do what you will (`sudo su root`), and restore things when you're done.

### If you're a true gamer

In the same way we restricted the sudo users from using `su` and `chattr`, we can do the same with `visudo`.

```bash
Cmnd_Alias DENY_VISUDO=/usr/sbin/visudo
```

and then add `, !DENY_VISUDO` next to `!DENY_PASSWD`

You can additionally or otherwise make the sudoers file immutable:

```bash
chattr +i /etc/sudoers
```

This last approach would be inviolable, but can also get you soft-locked if you also lost the root password.
