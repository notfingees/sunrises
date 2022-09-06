import subprocess

rc = subprocess.call('/home/bitnami/python/weekly.sh', shell=True)

print("Done with subprocess")