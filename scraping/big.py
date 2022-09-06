import subprocess

rc = subprocess.call('/home/bitnami/python/daily.sh', shell=True)

print("Done with subprocess")