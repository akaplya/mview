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
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/schema.sql
echo Mview schema created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/create.sql
echo Procedure mview.create created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/drop.sql
echo Procedure mview.drop created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/refresh.sql
echo Procedure mview.refresh created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/refresh_force.sql
echo Procedure mview.refresh_force created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/refresh_safe.sql
echo Procedure mview.refresh_safe created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/set_rule_column.sql
echo Procedure mview.set_rule_column created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/refresh_row.sql
echo Procedure mview.refresh_row created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/enable_changelog.sql
echo Procedure mview.enable_changelog created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/get_changelog_triggers_body.sql
echo Procedure mview.get_changelog_triggers_body created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/refresh_changelog.sql
echo Procedure mview.refresh_changelog created
mysql -h%host% -P%port% -u%user%  -p%password% < ./source/refresh_changelog_safe.sql
echo Procedure mview.refresh_changelog_safe created
pause