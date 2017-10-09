# Update and Upgrade [Jenkins](https://jenkins.io/)

## Download
In the first step, download new vertion `.war` file from [Jenkins Download page](http://mirrors.jenkins.io/war/latest/jenkins.war)
```bash
cd ~/downloads
wget http://mirrors.jenkins.io/war/latest/jenkins.war
```

## Replace file
Go to the `/usr/share/jenkins` and create a copy form old `.war` file.
```bash
cd /usr/share/jenkins
cp jenkins.war jenkins.war$(date +"%Y%m%d")
```

Transfer downloaded file to here.
```bash
cp ~/downloads/jenkins.war .
```

## Reload Jenkins
For last step, reload jenkins service.
```bash
systemctl status jenkins
systemctl restart jenkins
systemctl status jenkins # verify health of service
```
