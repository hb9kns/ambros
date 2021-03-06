#!/bin/sh
# calculate Morse code character length in dit units from graphic form
# and store in table
chartab=chartab.txt
calclen() {
# stdin: character table (char form comment)
# stdout: character table with added length (char length form)
 while read char form rem
 do
  # convert dits into "2 +" and dahs into "4 +" and append "2", because
  # inter-character pause at end is 2 dits longer than inter-unit pause
  # _ will be used as inter-word pause
  f1=`echo "$form 2"|sed -e 's/\./2 + /g;s/\-/4 + /g;s/_/2 + /g'`
  # do the addition with expr
  echo "_$char	" `expr $f1` "	$form"
 done
}
# third column in following table is comment and will be ignored by calclen
cat <<EOT | calclen >$chartab
_ _ inter-word pause
A .-
B -...
C -.-.
D -..
E .
F ..-.
G --.
H ....
I ..
J .---
K -.-
L .-..
M --
N -.
O ---
P .--.
Q --.-
R .-.
S ...
T -
U ..-
V ...-
W .--
X -..-
Y -.--
Z --..
a .-
b -...
c -.-.
d -..
e .
f ..-.
g --.
h ....
i ..
j .---
k -.-
l .-..
m --
n -.
o ---
p .--.
q --.-
r .-.
s ...
t -
u ..-
v ...-
w .--
x -..-
y -.--
z --..
@ .-.- ae Umlaut
* ---. oe Umlaut
^ ..-- ue Umlaut
# ---- ch
0 -----
1 .----
2 ..---
3 ...--
4 ....-
5 .....
6 -....
7 --...
8 ---..
9 ----.
+ .-.-. AR
& ..-.. e aigu
= -...- BT
/ -..-.
% .-... AS or EB, pause
> -.-.- KN, beginning
( -.--.
) -.--.-
< ...-.- SK, end
? ..--..
, --..--
' .----.
. .-.-.-
: ---...
- -....-
EOT
