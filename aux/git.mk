# vim:ft=make

.git/hooks/$(dirstamp):
	@$(MKDIR_P) .git/hooks
	@$(TOUCH) $@

.git/hooks/pre-commit: aux/git/hooks/pre-commit .git/hooks/$(dirstamp)
	@$(INSTALL) -m 0755 $< $@

PREREQ+= .git/hooks/pre-commit
