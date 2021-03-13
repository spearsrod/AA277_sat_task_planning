function a_nil = get_nil_action(t)
a_start.t = t;
a_end.t = t;
a_general.type = "NIL";
a_general.dpdt = 0;%-0.0001;
a_general.dddt = 0.000001;
a_nil.start = a_start;
a_nil.end = a_end;
a_nil.general = a_general;
end