TEMPLATE = app
TARGET = experts_gui
CONFIG += debug

QT += core gui
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

INCLUDEPATH = include /usr/include/scilab
INCLUDEPATH += "C:\Program Files\Git\scilab-5.5.2\modules\core\includes" \
               "C:\Program Files\Git\scilab-5.5.2\modules\call_scilab\includes"
LIBS += -Wl,--no-as-needed -L/usr/lib/scilab -lscilab -lscicall_scilab

OBJECTS_DIR = src
MOC_DIR     = src

SOURCES = src/experts_gui.cpp \
    src/evaluation_data.cpp \
    src/evaluation_gui.cpp

HEADERS = include/QtIncludes.h \
          include/experts_gui.h \
    include/evaluation_data.h \
    include/evaluation_gui.h

FORMS   = ui/mainwindow.ui
