#!/usr/bin/env python3
import socket

def check_port(host, port):
    """
    Checks if a specific port is open on a host.
    Returns True if open, False otherwise.
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    
    sock.settimeout(2.0)
    
    try:
        
        result = sock.connect_ex((host, port))
        
        
        return result == 0
    except socket.error:
        
        return False
    finally:
        
        sock.close()
