load -ascii votes.txt;
x = int32(votes');
save("-ascii", "votest.txt", "x");
