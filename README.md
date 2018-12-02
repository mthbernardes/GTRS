# GTRS - Google Translator Reverse Shell

This tools uses [Google Translator](https://translate.google.com) as a proxy to send arbitrary commands to an infected machine.
```
[INFECTED MACHINE] ==HTTPS==> [GOOGLE TRANSLATE] ==HTTP==> [C2] 
```

# Environment Configuration
First you need a VPS and a domain, for the domain you can get a free one on [Freenom](https://freenom.com/). With your VPS and domain, just edit the client script, and set your domain on line 5.

# Usage
Start the server.py on your VPS
```bash
python2.7 server.py
```
Execute the client on a computer with access to [Google Translator](https://translate.google.com).
```bash
bash client.sh
```
Now you have an interactive shell using named pipe files, **YES** you can `cd` into directories.

# Poc 
[![CODE_IS_CHEAP_SHOW_ME_THE_DEMO](http://img.youtube.com/vi/02CFsE0k96E/0.jpg)](http://www.youtube.com/watch?v=02CFsE0k96E)

# Known issues 
 * ~~Google translate does not forward POST data, so there's a limit on the amount of data that your server can receive, for example, you'll probably not being able to read a big file like `.bashrc`.~~ `Problem fixed using User-Agent header to sent data`.
 * It's not a problem, but I just don't know if there's a rate limit on Google Translator
 * The client script works on Mac an Linux, but on Linux you need to install the `xmllint` which is on `libxml2-utils`
