build:
	mkdir -p `pwd`/bin
	GOOS=windows GOARCH=amd64 go build -o `pwd`/bin/client_Windows64.exe client.go
	GOOS=windows GOARCH=386 go build -o `pwd`/bin/client_Windows.exe client.go
	GOOS=darwin GOARCH=386 go build -o `pwd`/bin/client_Mac client.go
	go build -o `pwd`/bin/client_Linux client.go

clean:
	rm  -Rf `pwd`/bin
