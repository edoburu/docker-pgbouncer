The [generate-userlist](https://github.com/edoburu/docker-pgbouncer/blob/master/examples/generate-userlist) script generated MD5 encrypted passwords for the userlist.txt file.

Usage:

```
$ ./generate-userlist
Enter username: admin
Enter password:
"admin" "md5f6fdffe48c908deb0f4c3bd36c032e72"
```

Quickly amend a file with multiple users:

```
$ ./generate-userlist admin >> userlist.txt
Enter password:

$ cat userlist.txt
"admin" "md5f6fdffe48c908deb0f4c3bd36c032e72"
```
