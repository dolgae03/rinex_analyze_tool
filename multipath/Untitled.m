aa=[0	0
0	0
0	0
1	0
1	1
0	0
0	0
1	1
1	0
0	0
0	0
0	0
0	0
1	1
0	0
0	0
0	0
0	0
0	0
0	0
1	1
1	0
0	0
0	0
0	0
0	0
0	1
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
1	1
1	1
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
1	0
0	0
0	0
0	1
0	0
0	1
1	1
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
1	0
1	0
1	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
0	0
1	0
1	0
0	0
];

logical_aa=aa(:,1)==aa(:,2);
acc=sum(logical_aa)/length(logical_aa);
cc=aa(aa(:,1)|aa(:,2),:);
logical_cc=cc(:,1)==cc(:,2);
