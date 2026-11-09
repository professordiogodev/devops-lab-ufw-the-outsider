#!/usr/bin/env python3
"""usage: listener.py PORT NAME. Answers every connection with a banner (HTTP on 8080)."""
import socketserver, sys
port, name = int(sys.argv[1]), sys.argv[2]
class H(socketserver.BaseRequestHandler):
    def handle(self):
        try:
            self.request.settimeout(1); data = b""
            try: data = self.request.recv(200)
            except Exception: pass
            if data.startswith(b"GET"):
                body = f"{name}\n".encode()
                self.request.sendall(b"HTTP/1.1 200 OK\r\nContent-Length: %d\r\nConnection: close\r\n\r\n" % len(body) + body)
            else:
                self.request.sendall(f"{name}\n".encode())
                self.request.settimeout(600)
                while self.request.recv(100): pass   # keep the "session" open until the client leaves
        except Exception:
            pass
class S(socketserver.ThreadingTCPServer): allow_reuse_address = True; daemon_threads = True
S(("0.0.0.0", port), H).serve_forever()
