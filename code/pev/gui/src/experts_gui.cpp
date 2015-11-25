// vi: ts=4 sw=4 et ai aw

#include "experts_gui.h"
#include "evaluation_data.h"
#include "ui_mainwindow.h"
#include "settings.h"
#include "stack-c.h"
#include "call_scilab.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdio>
#include <map>

using namespace std;

static int width = 800, height = 600;

static int QPARAM = 16;
static int QLEVEL = 4;

SettingsDialog *WinSettings;

const char *tempfile = tmpnam(NULL);

int main(int argc, char **argv) {
    // Start the application
    QApplication app(argc, argv);

    // Show the main window
    QRect screen_size = QApplication::desktop()->availableGeometry();
    if (width > screen_size.width()) width = screen_size.width();
    if (height > screen_size.height()) height = screen_size.height();

    MainWindow      main_window;
    SettingsDialog  settings_window;
    WinSettings = &settings_window;

    main_window.resize(width, height);
    main_window.show();

    // Scilab INITIALIZATION
#ifdef _MSC_VER
    if (StartScilab(NULL, NULL, 0) == FALSE)
#else
    if (StartScilab(getenv("SCI"), NULL, 0) == FALSE)
#endif
    {
        fprintf(stderr,"Error while calling StartScilab\n");
        return -1;
    }
    // TODO (kiraboris): why is this path hard-coded?
    string sAppRoot = QApplication::applicationDirPath().toUtf8().data();
    string scicommand = string("cd ") + sAppRoot + "/../..";
    if (SendScilabJob((char *)scicommand.c_str())) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return -1;
    }
    if (SendScilabJob((char *)"exec('loader.sce');")) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return -1;
    }

    // Start the event loop
    int ret_code = app.exec();

    // Scilab TERMINATION
    if (TerminateScilab(NULL) == FALSE) {
        fprintf(stderr,"Error while calling TerminateScilab\n");
        return -2;
    }

    return ret_code;
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    mActiveTech = -1;

    // IO buttons
    connect(ui->techMdiArea,SIGNAL(subWindowActivated(QMdiSubWindow*)),
            this,SLOT(onActiveTechChanged(QMdiSubWindow*)));
    connect(ui->addTech, SIGNAL(clicked()), this, SLOT(onAddTech()));
    connect(ui->saveTech, SIGNAL(clicked()), this, SLOT(onSaveAllTech()));
    connect(ui->saveOneTech, SIGNAL(clicked()), this, SLOT(onSaveSingleTech()));
    connect(ui->loadTech, SIGNAL(clicked()), this, SLOT(onLoadTechFile()));

    connect(ui->closeAll, SIGNAL(clicked()), this, SLOT(onCloseAll()));
    connect(ui->duplicate, SIGNAL(clicked()), this, SLOT(onDuplicate()));
    connect(ui->tile, SIGNAL(clicked()), this, SLOT(onTile()));

    // ADVANCED buttons
     connect(ui->settingsButton, SIGNAL(clicked()), this, SLOT(onShowSettings()));

    // SCILAB buttons
    connect(ui->evaluate, SIGNAL(clicked()), this, SLOT(onEvaluate()));
}

void MainWindow::onCloseAll() {
    if( ! ui->techMdiArea->subWindowList().isEmpty() ) {
         int ret = QMessageBox::warning(this, tr("Close all windows"),
                                   tr("All windows will be now closed."),
                                   QMessageBox::Ok | QMessageBox::Cancel);
         if( ret != QMessageBox::Ok )
              return;
    }

    ui->techMdiArea->closeAllSubWindows();
}

void MainWindow::onShowSettings() {

    if( ! ui->techMdiArea->subWindowList().isEmpty() ) {
         int ret = QMessageBox::warning(this, tr("Close all windows"),
                                   tr("All windows will be closed after this dialog."),
                                   QMessageBox::Ok | QMessageBox::Cancel);
         if( ret != QMessageBox::Ok )
              return;
    }

    WinSettings->exec();
    ui->techMdiArea->closeAllSubWindows();

    QPARAM = WinSettings->getQPARAM();
    QLEVEL = WinSettings->getQLEVEL();

}

void MainWindow::onTile() {
    ui->techMdiArea->tileSubWindows();
}



MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::onActiveTechChanged(QMdiSubWindow* win)
{
    if(win != NULL)
    {
      mActiveTech = dynamic_cast<TechEvWindow *>((win)->widget())->getNumber();
      ui->labelActiveTech->setText("Active tech: #" +
              QString::number(mActiveTech));
    }
    else
    {
      ui->labelActiveTech->setText("Active tech: none");\
      mActiveTech = -1; // !! FileSave dialog steals focus
    }
}


int  MainWindow::findSmallestUnusedTechNumber() {

    QList<QMdiSubWindow *> lst = ui->techMdiArea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;
    vector<int> usedNumbers(lst.length());

    int i=0;
    for (it = lst.begin(); it != lst.end(); ++it, ++i)
        usedNumbers.at(i) = dynamic_cast<TechEvWindow *>((*it)->widget())->getNumber();

    std::sort(usedNumbers.begin(), usedNumbers.end()); // in-place

    int smallestUnusedNumber = 1; i=0;
    while( i < usedNumbers.size() &&
           smallestUnusedNumber == usedNumbers.at(i) ) {
            ++i; ++smallestUnusedNumber;
    }

    return smallestUnusedNumber;
}

void MainWindow::onAddTech() {

    int smallestUnusedNumber = findSmallestUnusedTechNumber();

    QMdiSubWindow *subwnd = ui->techMdiArea->addSubWindow(new
               TechEvWindow(smallestUnusedNumber, QPARAM, QLEVEL));
    subwnd->show();
}

void MainWindow::onSaveAllTech() {

    // TODO (kiraboris): as template/for evaluation differs from all/one
    if( ! ui->checkSaveCout->isChecked() )  {
        // then use file dialog
        QString filename = QFileDialog::getSaveFileName(this, "Save all techs for evaluation",
                       QApplication::applicationDirPath()+"/../data/sample.txt", "*.txt");
        if( filename.isEmpty() ) return;

         ofstream of(filename.toUtf8().data(), ios::trunc);
          writeHeaders(of);
       //  int nSaved = saveToStream(mActiveTech-1, of);
         int nSaved = saveToStream(-1, of);
         of << "*******************************************" << endl;
         of << "File contains " << nSaved << " technology entries, each " << QPARAM << " lines long.";
         of.close();

         cout << nSaved << " techs saved." << endl;
    }
    else    {
         int nSaved = saveToStream(-1, cout);
             // mActiveTech indexing from 1, ntech indexing from 0
            cout << nSaved << " techs saved." << endl;
    }
}

void MainWindow::onSaveSingleTech() {

    if( mActiveTech <= 0 ) return;
    int tnActiveTech = mActiveTech; // !! FileSave dialog steals focus

    if( ! ui->checkSaveCout->isChecked() )  {
        // then use file dialog
        QString filename = QFileDialog::getSaveFileName(this, "Save single tech as temlate:",
                       QApplication::applicationDirPath()+"/../data/sample.txt", "*.txt");
        if( filename.isEmpty() ) return;

         ofstream of(filename.toUtf8().data(), ios::trunc);
        //  writeHeaders(of);
         of << "Machine-generated file. Intended as technology TEMPLATE for UI only!" << endl;
         of << "*******************************************" << endl;
         int nSaved = saveToStream(tnActiveTech-1, of);
        // int nSaved = saveToStream(-1, of);
         of << "*******************************************" << endl;
         of << "File contains " << nSaved << " technology entries, each " << QPARAM << " lines long.";
         of.close();

         cout << nSaved << " techs saved." << endl;
    }
    else    {
         int nSaved = saveToStream(mActiveTech-1, cout);
             // mActiveTech indexing from 1, ntech indexing from 0
            cout << nSaved << " techs saved." << endl;
    }
}

void MainWindow::onDuplicate() {
    if( mActiveTech <= 0 ) return;

    // **** the code snippet below is used only 2 times
    QList<QMdiSubWindow *> lst = ui->techMdiArea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;


    int maxNumber = lst.length();
    map<int, TechEval> sortedTechs;

    for (it = lst.begin(); it != lst.end(); it++) {
        int number =  dynamic_cast<TechEvWindow *>((*it)->widget())->getNumber();
        sortedTechs[number-1] =  // that's vector<Eval>::operator=
                 dynamic_cast<TechEvWindow *>((*it)->widget())->getData(QLEVEL);
    }
    // **** end snippet

    int next_number = findSmallestUnusedTechNumber();
    QMdiSubWindow *subwnd =  ui->techMdiArea->addSubWindow(
                new TechEvWindow(next_number, sortedTechs.at(mActiveTech-1), QLEVEL));
    subwnd->show();
}

void MainWindow::onLoadTechFile() {
    QString filename = QFileDialog::getOpenFileName(this, "Load tech data file:",
                   QApplication::applicationDirPath()+"/../data", "*.txt");
    if( filename.isEmpty() ) return;

    ifstream file(filename.toUtf8().data(), ios::in);
    if( ! file.is_open() ) return;

    string sbuf; string sdata;
    bool fInterpret = false; int qLines = 0;

    while( getline(file, sbuf) ) {
        // separator lines
        if( sbuf[0] == '*' && fInterpret ) {
            fInterpret = false;
            continue; // otherwise the tail check will switch on again
        }

        if( fInterpret ) {
          sdata += (sbuf += "\r\n");  // store to data stream
          ++qLines;
        }

        // separator lines
        if( sbuf[0] == '*' && !fInterpret )
            fInterpret = true;
    }

    if( qLines % QPARAM ) {
        cerr << "=========================" << endl;
        cerr << "(Data lines read) % (lines per tech) not zero. File corrupt or QPARAM set wrong?" << endl;
        cerr << "QPARAM = " << QPARAM << endl;
        cerr << "========================="  << endl;
        return;
    }

    if( !qLines ) {
        cout << "File contains no data (or no asterix)." << endl;
        return;
    }

    // **NOW reading data from file into new tech windows
    // opened tech windows will be now closed
    if( ! ui->checkAppend->isChecked() )
        ui->techMdiArea->closeAllSubWindows();

    cout << "==============================" << endl;
    cout << "WARNING: a uniform scale with " << QLEVEL << " different values is assumed in file!" << endl;

    istringstream ssdata(sdata);
    TechEval teval(QPARAM, QLEVEL);
    for(int i=0; i < qLines / QPARAM; ++i) {

        ssdata >> teval;
        int new_number = i+1;
        if( ui->checkAppend->isChecked() )
            new_number =  findSmallestUnusedTechNumber();

        QMdiSubWindow *subwnd = ui->techMdiArea->addSubWindow(
                    new TechEvWindow(new_number, teval, QLEVEL));
        subwnd->show();
    }  // end of windows creation

    cout << "Loaded " << qLines / QPARAM << " entries." << endl;
    cout.flush();
    file.close();
}

// saveToStream: outputs given tech or all techs (ntech= -1)
//              to pstream via operator<<
// returns count of saved techs
// **this func and the next one actually belong to a Saver class
int MainWindow::saveToStream(int ntech, ostream &pstream)
{
    // **** the code snippet below is used only 2 times
    QList<QMdiSubWindow *> lst = ui->techMdiArea->subWindowList();
    QList<QMdiSubWindow *>::iterator it;

    int maxNumber = lst.length();
    map<int, TechEval> sortedTechs;

    for (it = lst.begin(); it != lst.end(); it++) {
        int number =  dynamic_cast<TechEvWindow *>((*it)->widget())->getNumber();
        sortedTechs[number-1] =  // that's vector<Eval>::operator=
                 dynamic_cast<TechEvWindow *>((*it)->widget())->getData(QLEVEL);
    }
    // **** end snippet

    if( ntech < 0 )             // save all
    {
       for (auto& el : sortedTechs) // el has type pair<int,TechEval>
          pstream << el.second;
       return maxNumber;
    }
    else if(sortedTechs.find(ntech) != sortedTechs.end())  // save single
    {
       pstream << sortedTechs.at(ntech);
       return 1;
    }
    else
    {
       cerr << "Out of bounds";
       return 0;
    }

}

// writes headers to data file for pevSelectF()
void MainWindow::writeHeaders(ostream &of) {
    of << "qParam= " << QPARAM << " (parameters per 1 object)" << endl;
    of <<  WinSettings->getQualFun() << endl;
    of << "Machine-generated file. The above is intended for 'pevSelectF( filename )', see file select.sce." << endl;
    of << "The next separator line must begin with an asterix." << endl;
    of << "*******************************************" << endl;
}

void MainWindow::onEvaluate() {

    ofstream of(tempfile, ios::trunc);
    writeHeaders(of);
    int numTechs = saveToStream(-1, of);
    of << "*******************************************" << endl;
    of << "File contains " << numTechs << " technology entries, each " << QPARAM << " lines long.";
    of.close();

    if (!numTechs) return;

    cout << endl;
    cout << "==============================" << endl;
    cout << "Evaluating " << numTechs << " technologies" << endl;
    cout << "==============================" << endl;

    string scicommand = string("[sel, ploser] = pevSelectF('") + tempfile + "');";
    if (SendScilabJob((char *)scicommand.c_str())) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return;
    }
    if (SendScilabJob((char *)"pevPrintResult(sel);")) {
        cerr << __FILE__ << ": " << __LINE__ << " " << "Scilab error" << endl;
        return;
    }

    cout << "==============================" << endl;
}
