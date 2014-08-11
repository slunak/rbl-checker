rbl-checker
===========

Tool allows you to check your MTAs IP addresses against known blacklists.

##This tool can

- display the result
- send result to email

##Settings

###Configuration vars

- `$path_to_sendmail` - your email program, e.g. '/usr/sbin/sendmail'
- `$email_to - email` address where tool will send results
- `$email_from - email` from which tool will send results
- `$email_subject` - subject of such an email, e.g. 'RBL'

###list-of-ips-to-check.txt

File contains a list of MTAs IP addresses that will be checked accross known blacklists. Please modify this file before usage.

###blacklist.txt

File contains list of known blacklists which will be checked for MTAs IP addresses.

##Usage

`~> perl rbl-checker.pl [list-of-ips-to-check.txt] [blacklist.txt] [action]`

Arguments:

- `list-of-ips-to-check.txt`: path to file with list of IP addresses to check againts RBLs
- `blacklist.txt`: path to file with list of known RBLs
- `action`: can be `display` or `email` (for email please modify configuration vars in the script)

Example:

`~> perl rbl-checker.pl list-of-ips-to-check.txt blacklist.txt display`

##Cron

Add this tool to your crontab schedule and get results by email.

#Bugs

Please submit an issue if found a bug

#Known Blacklists

To add a blacklist, please modify file `blacklist.txt`.

To request a new blacklist to be added here, please submit an issue.