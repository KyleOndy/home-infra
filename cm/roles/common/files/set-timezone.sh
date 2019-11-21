# Set time zone and time 
echo "America/New_York" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
