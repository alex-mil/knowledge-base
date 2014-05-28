##### Connect to remote server to fetch some file, for example database dump file
> sftp (user-name)@(server-ip)<br>
> get (file-path)

##### Select n random records from table most efficient way
> <-- MySQL --> <br>
> User.limit(n).order('RAND()') <br>
> <-- Postgres --> <br>
> User.limit(n).order('RANDOM()')

##### Ignore certain fields that are too long in Hirb
> When you open up hirb, run this:<br>
> table projects, :fields => [:name]

`sudo apt-get install libmagickcore-dev libmagickwand-dev` - run this command before installation of RMagick
`mysqldump -u (user, e.g. root) -p(password) (database-name) > ~/(some-name)-dump.sql` - MySQL dump process
`tail -f log/development.log | grep '...'` - output in console relate info from a log
