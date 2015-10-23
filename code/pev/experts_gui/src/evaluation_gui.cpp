#include "evaluation_gui.h"
#include <math.h>
#include <iostream>

using namespace std;

QColor baseColor(0, 0, 255 * 0.7);

QColor colorOne (0, 0, 255 * 0.5);
QColor colorHigh(255 * 0.4, 255 * 0.4, 255);
QColor colorLow (255 * 0.8, 255 * 0.8, 255);
QColor colorZero(255, 255, 255);

EvBar::EvBar(int numLevels, int maxPoint) :
    eval(numLevels, maxPoint)
{
    pressPoint = -1;
    W = 220;
    H = 15;
    HMargin = VMargin = 3;
    setMinimumWidth(W + 2 * HMargin);
    setMinimumHeight(H + 2 * VMargin);
}

void EvBar::paintEvent(QPaintEvent *event) {
    QPainter painter(this);

    // Points
    for (int i = 0; i <= eval.getMaxPoint(); i++) {
        QColor color;

        if (eval.getNumLevels() != 4) {
            color.setRed(eval(i) * baseColor.red() + (1 - eval(i)) * colorZero.red());
            color.setGreen(eval(i) * baseColor.green() + (1 - eval(i)) * colorZero.green());
            color.setBlue(eval(i) * baseColor.blue() + (1 - eval(i)) * colorZero.blue());
        } else {
            switch (eval[i]) {
            case 0:
                color = colorZero; break;
            case 1:
                color = colorLow; break;
            case 2:
                color = colorHigh; break;
            case 3:
                color = colorOne; break;
            }
        }

        if (eval[i]) painter.setPen(colorZero);
        else painter.setPen(colorHigh);

        double dx = double(W) / (eval.getMaxPoint() + 1);
        double x1 = HMargin + i * dx;
        double w;
        if (i < eval.getMaxPoint()) w = dx + 1;
        else w = HMargin + W - x1;
        painter.fillRect(x1, VMargin, w, H, color);
        painter.drawRect(x1, VMargin, w, H);
    }

    // Border
    painter.setPen(colorHigh);
    painter.drawRect(HMargin, VMargin, W, H);
}

int EvBar::getPoint(int x, int y) {
    if (x < HMargin || HMargin + W - 1 < x) return -1;
    if (y < VMargin || VMargin + H < y) return -1;
    return floor((double)(x - HMargin) / W * (eval.getMaxPoint() + 1));
}

void EvBar::mousePressEvent(QMouseEvent *event) {
    int point = getPoint(event->x(), event->y());
    if (event->button() == Qt::LeftButton && point >= 0) {
        eval.change(point);
        update();
    }
    if (event->button() == Qt::RightButton && point >= 0) {
        eval[point] = 0;
        update();
    }
}
