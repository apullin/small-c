int prev_err;
int integ;
int setpoint;
int measurement;
int kp;
int ki;
int kd;
int scale;

pid_step()
{
        int err, deriv, out;
        err = setpoint - measurement;
        integ = integ + err;
        deriv = err - prev_err;
        prev_err = err;
        out = err*kp + integ*ki + deriv*kd;
        out = out / scale;
        return out;
}

main()
{
        int out, step;
        setpoint = 1000;
        measurement = 0;
        kp = 120;
        ki = 10;
        kd = 30;
        scale = 100;
        prev_err = 0;
        integ = 0;
        step = 0;
        while(step < 5)
        {
                out = pid_step();
                measurement = measurement + out/10;
                step = step + 1;
        }
        return measurement;
}
