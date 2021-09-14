pgsql: postgres -D /home/linuxbrew/.linuxbrew/var/postgres
# It's brew formula postgresql from Linuxbrew
#       `pg_ctl -D | |-| |  start` can't handle termination signal well.
mci_app: bundle exec rails server -p 3000 -b 0.0.0.0
tmuxinator: /home/linuxbrew/.linuxbrew/bin/tmuxinator start -p=./.tmuxinator.yml
