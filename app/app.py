from flask import Flask, jsonify
import socket
import netifaces

app = Flask(__name__)

@app.route('/')
def host_info():
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)

    # Collect IPv4 addresses of all network interfaces
    interfaces = netifaces.interfaces()
    interface_info = {}
    for iface in interfaces:
        try:
            iface_addrs = netifaces.ifaddresses(iface)
            ipv4 = iface_addrs.get(netifaces.AF_INET, [{}])[0].get('addr', 'N/A')
            interface_info[iface] = ipv4
        except:
            interface_info[iface] = 'Error'

    return jsonify({
        "project": "project05",
        "hostname": hostname,
        "local_ip": local_ip,
        "interfaces": interface_info
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)