build-win:
	docker build --force-rm=true -t thumbtest  .
	docker create  --name dummy thumbtest
	docker cp dummy:/bin/thumbtest.exe thumbtest.exe
	docker rm -f dummy
