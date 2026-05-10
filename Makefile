VAGRANT := vagrant

.PHONY: make clean re up halt destroy status ssh reload provision

make:
	$(VAGRANT) up

install: 	
	bash install.sh
	$(VAGRANT) up
up:
	$(VAGRANT) up

down:
	$(VAGRANT) halt

clean:
	$(VAGRANT) destroy -f

re: clean
	$(VAGRANT) up

reload:
	$(VAGRANT) reload --provision

provision:
	$(VAGRANT) provision

status:
	$(VAGRANT) status

ssh:
	$(VAGRANT) ssh