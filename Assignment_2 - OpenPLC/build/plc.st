TYPE
  LOGLEVEL : (CRITICAL, WARNING, INFO, DEBUG) := INFO;
END_TYPE

FUNCTION_BLOCK LOGGER
  VAR_INPUT
    TRIG : BOOL;
    MSG : STRING;
    LEVEL : LOGLEVEL := INFO;
  END_VAR
  VAR
    TRIG0 : BOOL;
  END_VAR

  IF TRIG AND NOT TRIG0 THEN
  {{
   LogMessage(GetFbVar(LEVEL),(char*)GetFbVar(MSG, .body),GetFbVar(MSG, .len));
  }}
  END_IF;
  TRIG0:=TRIG;
END_FUNCTION_BLOCK



FUNCTION_BLOCK python_eval
  VAR_INPUT
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    STATE : DWORD;
    BUFFER : STRING;
    PREBUFFER : STRING;
    TRIGM1 : BOOL;
    TRIGGED : BOOL;
  END_VAR

  {extern void __PythonEvalFB(int, PYTHON_EVAL*);__PythonEvalFB(0, data__);}
END_FUNCTION_BLOCK

FUNCTION_BLOCK python_poll
  VAR_INPUT
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    STATE : DWORD;
    BUFFER : STRING;
    PREBUFFER : STRING;
    TRIGM1 : BOOL;
    TRIGGED : BOOL;
  END_VAR

  {extern void __PythonEvalFB(int, PYTHON_EVAL*);__PythonEvalFB(1,(PYTHON_EVAL*)(void*)data__);}
END_FUNCTION_BLOCK

FUNCTION_BLOCK python_gear
  VAR_INPUT
    N : UINT;
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    py_eval : python_eval;
    COUNTER : UINT;
    ADD10_OUT : UINT;
    EQ13_OUT : BOOL;
    SEL15_OUT : UINT;
    AND7_OUT : BOOL;
  END_VAR

  ADD10_OUT := ADD(COUNTER, 1);
  EQ13_OUT := EQ(N, ADD10_OUT);
  SEL15_OUT := SEL(EQ13_OUT, ADD10_OUT, 0);
  COUNTER := SEL15_OUT;
  AND7_OUT := AND(EQ13_OUT, TRIG);
  py_eval(TRIG := AND7_OUT, CODE := CODE);
  ACK := py_eval.ACK;
  RESULT := py_eval.RESULT;
END_FUNCTION_BLOCK


PROGRAM program0
  VAR
    Start : BOOL;
    Stop : BOOL;
    ConveyorBelt : BOOL;
    A : BOOL;
    B : BOOL;
    TON0 : TON;
    TON1 : TON;
    DetectCan : BOOL;
    DetectCap : BOOL;
    Wait1 : BOOL;
    TON2 : TON;
    Stop1 : BOOL;
    Detect : BOOL;
    ShootInkJet : BOOL;
    Wait2 : BOOL;
    TON3 : TON;
    Stop2 : BOOL;
    CountCan : BOOL;
    CTU0 : CTU;
    StartPalletizer : BOOL;
    CTU1 : CTU;
    R_TRIG1 : R_TRIG;
    R_TRIG2 : R_TRIG;
  END_VAR

  ConveyorBelt := Start AND NOT(Stop);
  TON0(IN := A AND ConveyorBelt AND NOT(Stop), PT := T#100ms);
  B := TON0.Q;
  TON1(IN := NOT(B) AND ConveyorBelt AND NOT(Stop), PT := T#5000ms);
  DetectCan := TON0.Q OR TON1.Q;
  DetectCap := TON0.Q OR TON1.Q;
  A := TON1.Q;
  Wait1 := NOT(Stop1) AND (DetectCap AND DetectCan OR Wait1) AND NOT(Stop);
  TON2(IN := NOT(Stop1) AND (DetectCap AND DetectCan OR Wait1) AND NOT(Stop), PT := T#5000ms);
  Detect := TON2.Q;
  Stop1 := TON2.Q;
  ShootInkJet := Detect AND NOT(Stop);
  Wait2 := NOT(Stop2) AND (Detect AND NOT(Stop) OR Wait2 AND NOT(Stop));
  TON3(IN := NOT(Stop2) AND (Detect AND NOT(Stop) OR Wait2 AND NOT(Stop)), PT := T#5000ms);
  CountCan := TON3.Q;
  Stop2 := TON3.Q;
  R_TRIG1(CLK := CountCan AND NOT(Stop));
  CTU0(CU := R_TRIG1.Q, R := StartPalletizer AND NOT(Stop), PV := 3);
  StartPalletizer := CTU0.Q;
  R_TRIG2(CLK := CTU0.Q);
  CTU1(CU := R_TRIG2.Q, PV := 100);
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : program0;
  END_RESOURCE
END_CONFIGURATION
