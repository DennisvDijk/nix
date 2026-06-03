---
name: networking-fundamentals
description: Computer networking fundamentals including TCP/IP, DNS, HTTP/HTTPS, load balancing, VPNs, and network security. Use when designing, troubleshooting, or reviewing network architectures and configurations.
---

## What I do
- Explain networking concepts
- Troubleshoot connectivity issues
- Design network architectures
- Review security configurations
- Optimize network performance

## When to use me
Use this skill when:
- Troubleshooting network issues
- Designing network architectures
- Configuring firewalls/ACLs
- Reviewing DNS configurations
- Setting up VPNs

## Core Principles

### TCP/IP Stack
- Understand OSI model layers
- Know TCP vs UDP differences
- Understand IP addressing (IPv4/IPv6)
- Know common ports and protocols
- Understand subnetting

### DNS
```
Common DNS Record Types:
A     - IPv4 address
AAAA  - IPv6 address
CNAME - Canonical name (alias)
MX    - Mail exchange
TXT   - Text record
NS    - Name server
PTR   - Pointer (reverse DNS)
SRV   - Service record
```

### HTTP/HTTPS
- Understand request/response cycle
- Know common status codes
- Understand headers
- Know TLS/SSL handshake
- Understand CORS

### Load Balancing
```yaml
# Types:
Layer 4 (Transport): TCP/UDP load balancing
Layer 7 (Application): HTTP/HTTPS load balancing

# Algorithms:
- Round Robin
- Least Connections
- IP Hash
- Weighted
```

### Network Security
- Use Defense in Depth
- Implement principle of least privilege
- Use TLS 1.2+ for encryption
- Implement proper firewall rules
- Monitor network traffic
- Use VPNs for remote access

## Common Patterns

### Subnetting Example
```
CIDR: 10.0.0.0/24
Network: 10.0.0.0
Broadcast: 10.0.0.255
Usable: 10.0.0.1 - 10.0.0.254
Netmask: 255.255.255.0
```

### Firewall Rules
```
Principle: Default deny, explicit allow

Example:
ALLOW TCP 80,443 FROM 0.0.0.0/0 TO web-servers
ALLOW TCP 22 FROM bastion-host TO admin-servers
DENY ALL FROM 0.0.0.0/0 TO 0.0.0.0/0
```

### VPN Types
- **Site-to-Site**: Connects entire networks
- **Remote Access**: Individual client connections
- **SSL VPN**: Web-based access
- **IPsec**: Standard VPN protocol

## Troubleshooting

### Common Commands
```bash
# Connectivity
curl -I https://example.com
ping -c 4 8.8.8.8
traceroute example.com

# DNS
dig example.com
nslookup example.com
host example.com

# Network info
ip addr
netstat -tuln
ss -tuln
```

### Debug Steps
1. Check physical/virtual connectivity
2. Verify IP configuration
3. Test with ping
4. Check DNS resolution
5. Test port connectivity
6. Review firewall rules
7. Check routing tables

## Anti-patterns to Avoid
- Don't use default passwords
- Don't expose management ports publicly
- Don't use outdated protocols (Telnet, FTP)
- Don't ignore encryption
- Don't use overly permissive firewall rules
- Don't skip network monitoring

## Tools
- curl/httpie
- dig/nslookup
- ping/traceroute/mtr
- tcpdump/Wireshark
- nmap
- iperf
- netstat/ss
