#pragma once

using namespace std;

class PID {
public:
	int P;
	int I;
	int D;

	PID() {
		P = 0;
		I = 0;
		D = 0;
	}

	PID(int prop, int integ, int deriv) {
		P = prop;
		I = integ;
		D = deriv;
	}

	int updateVals(float newe) {
		//update array
		for (int i = 0; i < 20; i++) {
			e[i] = e[i + 1];
		}
		//update sum
		e[49] = newe;
		sum += newe;
		if (sum > 255) {
			sum = 255;
		}
		//update slope (Taking 2 sets of 10 terms)
		//Refer to slideshow for math
		//NOTE!!! we may not need to be this fancy if we downsample with 0-order holds when we get each error value
		slope = slope + (newe + e[0] - 2 * e[10]) / 10;
	}

	int getDutyCycle() {
		int DC = P * e[20] + I * sum - D * slope;
		if (DC > 255) {
			return 255;
		}
		return DC;
	}

private:
	float e[21] = { 0 };
	float sum = 0;
	float slope = 0;
};
