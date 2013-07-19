all: librandom.a app

librandom.a: librandom.o
	ar rcs $@ $<

librandom.o: random.c
	gcc -I/usr/local/include/urweb -g -c -o $@ $<

app: dn.ur dn.urs dn.urp
	urweb -dbms sqlite -db dn.db dn

production: dn.ur dn.urs dn-production.urp
	urweb -dbms sqlite -db dn.db -static dn-production

.PHONY: clean

clean:
	rm -f librandom.a librandom.o

deploy-static: dn.js main.css
	scp dn.js host@dbpmail.net:dbpmail/dn/dn.js
	scp main.css host@dbpmail.net:dbpmail/dn/main.css

deploy: production deploy-static
	scp dn-production.exe host@dbpmail.net:dbpmail/dn/dn-new.exe
	ssh host@dbpmail.net /var/www/dbpmail/dn/reload.sh
