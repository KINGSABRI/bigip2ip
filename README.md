BigipIP
========
Extracts the real(Private) IP from F5 cookies


How to use?
===
When you find HTTP headers contains something like

```
BIGipServerpool=rd4o00000000000000000000ffffc0a80411o80
```

or

```
BIGipServerPool=252029120.10499.0000
```
that means the headers have been encoded by F5 encoders.

```
printf 'GET / HTTP/1.0\nHOST:domain.com\n\n' | ncat domain.com 80  | grep -i bigip
```

***BIG-IP persistence cookie decoder***

http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

***To search for F5 Cookies***

https://tools.digitalpoint.com/cookie-search?name=BigIP

