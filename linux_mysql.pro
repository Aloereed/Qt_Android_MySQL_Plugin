TARGET = qsqlmysql

HEADERS += $$PWD/qsql_mysql_p.h
SOURCES += $$PWD/qsql_mysql.cpp $$PWD/main.cpp
OTHER_FILES += mysql.json
INCLUDEPATH += /usr/include/mysql
LIBS+=-L/usr/lib/x86_64-linux-gnu -lmysqlclient_r

PLUGIN_CLASS_NAME = QMYSQLDriverPlugin
include(../qsqldriverbase.pri)
