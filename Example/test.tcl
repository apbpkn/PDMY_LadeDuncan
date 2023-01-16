wipe;
wipe all;
 

foreach CSR {0.2} {
model BasicBuilder -ndm 3 -ndf 4
set pConf -100.0

set dT 0.001
set numCycle 11.5
set numSteps [expr 2000*$numCycle]

node 1	1.0	0.0	0.0
node 2	1.0	1.0	0.0
node 3 	0.0	1.0	0.0	
node 4	0.0	0.0	0.0

node 5	1.0	0.0	1.0
node 6 	1.0	1.0	1.0
node 7 	0.0	1.0	1.0
node 8 	0.0	0.0	1.0
 
fix 1 	0 1 1 1
fix 2 	0 0 1 1
fix 3	1 0 1 1
fix 4 	1 1 1 1

fix 5	0 1 0 1
fix 6 	0 0 0 1
fix 7	1 0 0 1
fix 8 	1 1 0 1

set pR  0.4
set G 2.e+004
set K [expr 2.0*$G*(1.0+$pR)/3.0/(1-2.0*$pR)]
nDMaterial LadeDuncanMultiYield 1  3  2.04  $G $K   40.0  0.1   101.0  0.5   26.0  0.15  0.1  0.15  0.3   20  100.0   3.0   1.0   0.0  0.585 0.9  0.02  0.7  101. 0.3 2.0 2 1.1 0.3


element SSPbrickUP   1     1 2 3 4 5 6 7 8  1  2.2e6   1.0  1.1e-4 1.1e-4 1.1e-4  0.585   [expr 1.0/(4*($G + (4/3)*$K))] 

set pNode [expr $pConf / 4.0]
pattern Plain 1 {Series -time {0 10000 1e10} -values {0 1 1} -factor 1} {
    load 1  $pNode  0.0    0.0    0.0
    load 2  $pNode  $pNode 0.0    0.0
    load 3  0.0     $pNode 0.0    0.0
    load 4  0.0     0.0    0.0    0.0
    load 5  $pNode  0.0    $pNode 0.0
    load 6  $pNode  $pNode $pNode 0.0
    load 7  0.0     $pNode $pNode 0.0
    load 8  0.0     0.0    $pNode 0.0
}

updateMaterials -material 1 shearModulus  1.8e5
updateMaterials -material 1 bulkModulus   2.6e6
	
constraints Penalty 1.0e18 1.0e18
test        NormDispIncr 1.0e-6 20 0
algorithm   KrylovNewton
numberer    RCM
system      BandGeneral
integrator Newmark 1.5  [expr pow(1.5+0.5, 2)/4]
analysis VariableTransient 
analyze 150 100 1 100  15

for {set x 1} {$x<9} {incr x} {
   remove sp $x 4
}

updateMaterialStage -material  1   -stage 1
updateMaterials -material 1 shearModulus $G 
updateMaterials -material 1 bulkModulus  $K
analyze 50 100 1 100  15

wipeAnalysis
remove recorders
recorder Node    -file disp.out   -time -precision 16 -nodeRange 1 8 -dof 1 2 3  disp
recorder Node    -file press.out  -time -precision 16 -nodeRange 1 8 -dof 4    vel
recorder Element -file stress.out -time -precision 16  stress
recorder Element -file strain.out -time -precision 16  strain

timeSeries Trig 3 20000 40000 2 
set P_max [expr -200.0*$CSR]
pattern Plain  2 3 {  
	load  5  0.0 0.0  [expr $P_max/4.0] 0   
	load  6  0.0 0.0  [expr $P_max/4.0] 0    
	load  7  0.0 0.0  [expr $P_max/4.0] 0    
	load  8  0.0 0.0  [expr $P_max/4.0] 0   
}

set gamma  0.600;
constraints Transformation
test EnergyIncr 1.0e-4 50  0
numberer   RCM
algorithm Newton
system    ProfileSPD
rayleigh 0.0  0.0  0.02 0.0
integrator Newmark $gamma  [expr pow($gamma+0.5, 2)/4] 
analysis VariableTransient 

set i 0
set ok 0
set stop 1;
while {$ok == 0 && $i < $numSteps && $stop==1} {
	analyze 1 $dT [expr $dT/100] $dT  15	
	set i [expr $i + 1];
}
	
wipe all;
wipe;	
}

