#ifndef SETTINGS_H
#define SETTINGS_H

#include <QDialog>
#include <string>

namespace Ui {
class SettingsDialog;
}

class SettingsDialog : public QDialog
{
    Q_OBJECT

public:
    explicit SettingsDialog(QWidget *parent = 0);
    std::string  getQualFun();
    int     getQPARAM();
    int     getQLEVEL();
    ~SettingsDialog();

private:
    Ui::SettingsDialog *ui;

private slots:
    void clickPushRosatom();
    void clickPushSingle();
    void clickPushDouble();

};

#endif // SETTINGS_H
