# To Do List

- Line 14 add comment to tell user that ~ is already assumed and no trailing slash.

- Line 18 inform user that this is the username on the remote server

- Line 108 - Self installer whoami test - this checks for 'pi' user, make this more generic, perhaps a test that checks that the user is NOT root instead?

- Can sudo be removed on Mac check?

- Check MAC address check - I think it may only be checking for WiFi Macs? - Not all Pi's have this

- In the self-installer routine add loop detection and break-out, incase install fails, increment a variable and then provide user with appropriate error code and explination.

- sudo access will be required in order to install things to /usr/local/bin/ - Explain to the user why sudo password is required first.

- add test to see if program has been installed to /usr/local/bin/ and if cron is there, highlight in green.

- Consider moving logging to /var/log/

- Fix number logic when it downloads update files from the remote server to calculate how many files there are and what it should number the next file.
