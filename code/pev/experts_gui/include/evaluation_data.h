#ifndef __EVALUATION_DATA_H__
#define __EVALUATION_DATA_H__

#include <vector>
#include <iostream>

using namespace std;

class SingleEv : public vector<unsigned int> {
    protected:
        int numLevels, maxPoint;

    public:
        SingleEv(int numLevels = 4, int maxPoint = 10);
        double operator() (int i);
        void change(int i);
        int getNumLevels();
        int getMaxPoint();

        friend ostream & operator<< (ostream &out, SingleEv &eval);
};

#endif // __EVALUATION_DATA_H__
