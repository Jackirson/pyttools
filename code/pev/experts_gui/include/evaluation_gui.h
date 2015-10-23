#ifndef __EVALUATION_GUI_H__
#define __EVALUATION_GUI_H__

#include "QtIncludes.h"
#include "evaluation_data.h"

extern QColor baseColor, colorOne, colorHigh, colorLow, colorZero;

class EvBar : public QFrame {
    protected:
        SingleEv eval;
        int W, H, HMargin, VMargin;
        int pressPoint;

        int getPoint(int x, int y);

        virtual void paintEvent(QPaintEvent *event);
        virtual void mousePressEvent(QMouseEvent *event);

    public:
        EvBar(int numLevels = 4, int maxPoint = 10);
};

#endif // __EVALUATION_GUI_H__
