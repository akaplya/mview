@ echo off
echo Enter host:
set /p host=
echo Enter port:
set /p port=
echo Enter user name
set /p user=
echo Enter password
set /p password=
cls
mysql -h%host% -P%port% -u%user%  -p%password% < ./demo/schema.sql
echo Demo schema created
pause