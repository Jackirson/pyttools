TEMPLATE = app
TARGET = experts_gui
DESTDIR = .
CONFIG += debug

INCLUDEPATH = include /usr/include/scilab
LIBS += -Wl,--no-as-needed -L/usr/lib/scilab -lscilab -lscicall_scilab

OBJECTS_DIR = src
MOC_DIR     = src

SOURCES = src/experts_gui.cpp

HEADERS = include/QtIncludes.h \
          include/experts_gui.h

FORMS = ui/mainwindow.ui
