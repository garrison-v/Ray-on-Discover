import os
import socket
import time
import ray

ray.init(address=os.environ["ip_head"])

print("Nodes in the Ray cluster:")
for node in ray.nodes():
    for k, v in node.items():
        print(k, v)

    print("-----")

@ray.remote
def f():
    hostname = socket.gethostname()
    msg = f"Hello from: {hostname}"
    return msg

for i in range(10):
    print(f"Starting epoch: {i}")
    messages = ray.get([f.remote() for _ in range(10)])
    for msg in messages:
        print(msg)
    time.sleep(1)
print("DONE")