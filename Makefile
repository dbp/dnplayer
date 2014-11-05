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
	scp dn.js host@lab.positiondev.com:positiondev-lab/dn/static/dn.js
	scp main.css host@lab.positiondev.com:positiondev-lab/dn/static/main.css

deploy: production deploy-static
	scp dn-production.exe host@lab.positiondev.com:positiondev-lab/dn/dn-new.exe
	ssh host@lab.positiondev.com /var/www/positiondev-lab/dn/reload.sh
