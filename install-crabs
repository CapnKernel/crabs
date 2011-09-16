CRABS=/home/mjd/crabs
SYSROUTES=/etc/openvpn/vpn1/routes
LOCALLIST=$(CRABS)/crabs.txt
CRABS_SCRIPT:=$(CRABS)/crabs.awk

all:
	wget -O crabs.tar.gz https://github.com/CapnKernel/crabs/tarball/master
	tar --strip-components=1 -xzvf crabs.tar.gz
	su -c '$(CRABS_SCRIPT) < $(LOCALLIST) > $(SYSROUTES)
