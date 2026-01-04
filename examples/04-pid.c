#define SCALE 100
#define KP 120
#define KI 10
#define KD 30

int prev_err;
int integ;

pid_step(set, meas)
int set, meas;
{
        int err, deriv, out;
        err = set - meas;
        integ = integ + err;
        deriv = err - prev_err;
        prev_err = err;
        out = err*KP + integ*KI + deriv*KD;
        out = out / SCALE;
        return out;
}

main()
{
        int set, meas, out, step;
        set = 1000;
        meas = 0;
        prev_err = 0;
        integ = 0;
        step = 0;
        while(step < 5)
        {
                out = pid_step(set, meas);
                meas = meas + out/10;
                step = step + 1;
        }
        return meas;
}
