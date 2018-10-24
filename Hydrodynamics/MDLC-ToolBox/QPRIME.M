function qp = qprime(t,y,flag,K,tinp,qinp);
   inp 	= interp1(tinp,qinp,t);
   qp		= 1/K*(inp-y);

