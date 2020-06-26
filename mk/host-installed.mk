%-provision-host.sh:
	cp $(PROVISION_HOST_SCRIPT) $@

%-host-installed.qcow2: %-host-deps-installed.qcow2 %-provision-host.sh
	qemu-img create -f qcow2 -F qcow2 -b $*-host-deps-installed.qcow2 $@.tmp
#	See the remark above aboud chmod.
	chmod 666 $@.tmp
	virt-customize \
		-a $@.tmp \
		$(foreach repo, $(EXTRA_REPOS), --run-command "dnf config-manager --add-repo $(repo)") \
		--run "$*-provision-host.sh" \
		--run-command "rpm -qa | sort > $(_PKGLIST_PATH)/$(@:.qcow2=-pkglist.txt)" \
		--selinux-relabel
	mv $@.tmp $@