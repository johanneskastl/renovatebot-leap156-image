# Renovatebot on openSUSE Leap 15.6

The official renovate images are based on Ubuntu, where git is linked to gnutls.
This breaks in some cases and environments (including mine), which renders the
image useless.

Instead of rebuilding git against openSSL, this image is based on Leap 15.6 that
has a proper git package and works even in my environment... :-)

## LICENSE

The Dockerfile is released under the MIT license, the packages themselves use
different licenses.
