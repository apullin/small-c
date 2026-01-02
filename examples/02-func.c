int addend;

add(a)
int a;
{
        return a+addend;
}

main()
{
        int x,y,z;
        x=10;
        y=32;
        addend=y;
        z=add(x);
        return z;
}
