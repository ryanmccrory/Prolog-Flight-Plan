% Ryan McCrory
% rmccrory@ucsc.edu
% asg5 functions.pl

% this is the export
  % export PATH=$PATH:/afs/cats.ucsc.edu/courses/cmps112-wm/usr/gprolog/bin

% this is how to run in directory with functions
  % gprolog <.score/group0.tests
% ----------------------------------------------------------------------

% Prolog version of not, from examples
not( X ) :- X, !, fail.
not( _ ).

%fly procedure, aka main method
fly(Depart, Arrive) :-
  %Recursive call to find connecting flights
  listpath(Depart, Arrive, List),
  %prints flight schedule
  nl,
  writepath(List),
  true.

%==============fly methods to deal with invalid input (tests 3, 4, 5)================

%for test3
fly(Depart, Depart) :-
  !, nl,
  write('Error: Depart and/or Arrival airports are invalid.'),
  !, fail.

%fly procedure to deal with invalid Arrive or Depart 
fly(_, _) :-
  !, nl,
  write('Error: Depart and/or Arrival airports are invalid.'),
  !, fail.

%------------------------------------------------------------------------------------





% ==================== Recursive function to find connecting flights ===============

%top level 
listpath( Node, End, [flight(Node, Next, Dtime)|Outlist] ) :-
   not(Node = End),
   flight(Node, Next, Dtime),
   listpath( Next, End, [flight(Node, Next, Dtime)], Outlist ).

%base case
listpath( Node, Node, _, [] ).

%recursively finds flight paths
listpath( Node, End, 
  [flight(Depart, Arrive, time(Hrs, Mins))|Visited], 
  [flight(Node, Next, time(Hours, Minutes))|List] ) :-
  flight(Node, Next, time(Hours, Minutes)),
  arrivetime(flight(Depart, Arrive, time(Hrs, Mins)), Arr_time),
  %makes sure flight is valid
  is_thirtymin(Arr_time, Hours, Minutes),
  arrivetime(flight(Node, Next, time(Hours, Minutes)), Arrive_time),
  %makes sure trip takes less than a day
  Arrive_time < 24,
  %makes sure we dont go to airports we have already been to
  not(Depart = Next),
  %recursive call
  listpath( Next, End, [flight(Node, Next, time(Hours, Minutes))|Visited], List ).

%------------------------------------------------------------------------------------





%======================= Time functions / conversions =============================================

%finds depart time given hours and minutes
departtime(Hours, Minutes, Depart_time) :-
  Mins is Minutes / 60,
  Depart_time is Hours + Mins.

%finds arrival time
arrivetime(flight(Depart, Arrive, time(Hours, Minutes)), Arrive_time) :-
  departtime(Hours, Minutes, Depart_time),
  flighttime(Depart, Arrive, Flight_time),
  Arrive_time is Depart_time + Flight_time.

%finds total time of flight
flighttime(Depart, Arrive, Flight_time) :-
  airport(Depart, _, Lat1, Lon1),
  airport(Arrive, _, Lat2, Lon2),
  degmin_rad(Lat1, Rads1),
  degmin_rad(Lon1, Rads2),
  degmin_rad(Lat2, Rads3),
  degmin_rad(Lon2, Rads4),
  haversine_radians(Rads1, Rads2, Rads3, Rads4, Distance),
  % divide by 500 bc we fly at 500 mph
  Flight_time is Distance / 500.

%makes sure new Depart is 30 min after previous arrival
is_thirtymin(Arrive_time, Hours, Minutes) :-
  Depart_time is Hours + Minutes / 60,
  Check is Arrive_time + 0.5,
  Check < Depart_time.

%converts degrees/minutes to radians by calling haversine_radians
degmin_rad(degmin(Degrees, Minutes), Rads) :-
  Degs is Degrees + Minutes / 60,
  Rads is Degs * pi / 180.

% from functions.pl example
haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
   Dlon is Lon2 - Lon1,
   Dlat is Lat2 - Lat1,
   A is sin( Dlat / 2 ) ** 2
      + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
   Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
   Distance is Dist * 3961.

%-----------------------------------------------------------------------------------





%========================= Print Functions =========================================

%print time in correct format when given in a decimal, ex 12.91 = 12:54
print_time(Time) :-
  Hours is floor(Time),
  Minutes is Time - Hours,
  Mins is Minutes * 60,
  Minss is floor(Mins),
  need_zero(Hours),
  print(':'),
  need_zero(Minss).

%prints time if < 10
need_zero(Time) :-
  Time < 10,
  %prints a 0 it the time is under 10, so 8 is 08
  print(0),
  print(Time).

%prints time if time is  >= 10
need_zero(Time) :-
  Time >= 10,
  print(Time).

%converts lower case to upper case, from examples
to_upper( Lower, Upper) :-
   atom_chars( Lower, Lowerlist),
   maplist( lower_upper, Lowerlist, Upperlist),
   atom_chars( Upper, Upperlist).

%base case for writepath
writepath([]).

%prints path from Depart to Arrive
writepath([flight(Depart, Arrive, time(Hours, Minutes))|List]) :-
   %get airport extensions to print
   airport(Depart, Depart_Ext, _, _),
   airport(Arrive, Arrive_Ext, _, _),
   %get depart time
   departtime(Hours, Minutes, Depart_time),
   %get arrive time
   arrivetime(flight(Depart, Arrive, time(Hours, Minutes)), Arrive_time),
   %print the Depart info on one line
   write('Depart '), to_upper(Depart, Depart_upper), write(Depart_upper), write(' '),
   write(Depart_Ext), write(' '),
   print_time(Depart_time), nl,
   %print the arrive info on next line
   write('Arrive '), to_upper(Arrive, Arrive_upper), write(Arrive_upper), write(' '),
   write(Arrive_Ext), write(' '),
   print_time(Arrive_time), nl,
   %recursive call if there are connecting flights
   writepath(List),
   !, true.

% --------------end of code -----------------
